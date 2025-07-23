// Download and Process RDF Files from Supabase Storage
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs').promises;
const path = require('path');

// Initialize Supabase client
const supabaseUrl = 'https://mwfsytnixlcpterxqqnf.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im13ZnN5dG5peGxjcHRlcnhxcW5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwNjc4OTgsImV4cCI6MjA2ODY0Mzg5OH0.UdMFlGMfBm_MiUDBB8f7bEAK57MVPaZ1vwXruhhXcq4';
const supabase = createClient(supabaseUrl, supabaseKey);

// Function to download RDF file from storage
async function downloadRdfFile(filename) {
    try {
        console.log(`Downloading ${filename}...`);
        
        const { data, error } = await supabase.storage
            .from('curriculum-data')
            .download(filename);
            
        if (error) {
            console.error(`Error downloading ${filename}:`, error);
            return null;
        }
        
        // Convert the file to text
        const text = await data.text();
        console.log(`Successfully downloaded ${filename} (${text.length} characters)`);
        return text;
        
    } catch (error) {
        console.error(`Error processing ${filename}:`, error);
        return null;
    }
}

// Function to extract curriculum data from RDF content
function extractCurriculumFromRdf(rdfContent, subjectCode) {
    const items = [];
    
    try {
        console.log(`\nAnalyzing ${subjectCode}.rdf structure...`);
        
        // Look for different patterns that might contain curriculum data
        const patterns = [
            // Pattern 1: rdf:about with dcterms:description (the actual structure)
            /rdf:about="([^"]*)"[^>]*>[\s\S]*?<dcterms:description[^>]*>([^<]*)<\/dcterms:description>/g,
            
            // Pattern 2: rdf:Description with about attribute and dcterms:description
            /<rdf:Description[^>]*rdf:about="([^"]*)"[^>]*>[\s\S]*?<dcterms:description[^>]*>([^<]*)<\/dcterms:description>/g,
            
            // Pattern 3: Look for any dcterms:description elements
            /<dcterms:description[^>]*>([^<]*)<\/dcterms:description>/g,
            
            // Pattern 4: Look for rdf:about attributes
            /rdf:about="([^"]*)"/g
        ];
        
        // Try each pattern
        patterns.forEach((pattern, index) => {
            const matches = rdfContent.match(pattern);
            if (matches) {
                console.log(`Pattern ${index + 1} found ${matches.length} matches`);
                if (matches.length > 0 && index < 3) { // Only show details for first 3 patterns
                    console.log('First few matches:');
                    matches.slice(0, 3).forEach(match => {
                        console.log('  -', match.substring(0, 200) + '...');
                    });
                }
            }
        });
        
        // More flexible extraction - look for any rdf:Description with dcterms:description
        const descriptionMatches = rdfContent.match(/<rdf:Description[^>]*>[\s\S]*?<\/rdf:Description>/g);
        if (descriptionMatches) {
            console.log(`Found ${descriptionMatches.length} rdf:Description elements`);
            
            descriptionMatches.forEach((desc, index) => {
                // Extract ID from rdf:about
                const aboutMatch = desc.match(/rdf:about="([^"]*)"/);
                const descriptionMatch = desc.match(/<dcterms:description[^>]*>([^<]*)<\/dcterms:description>/);
                
                if (aboutMatch && descriptionMatch) {
                    const id = aboutMatch[1];
                    const description = descriptionMatch[1].trim();
                    
                    // Skip if description is too short or contains metadata
                    if (description.length < 10 || 
                        description.toLowerCase().includes('corrected html') ||
                        description.toLowerCase().includes('copyright') ||
                        description.toLowerCase().includes('australian curriculum')) {
                        return;
                    }
                    
                    // Determine content type based on ID
                    let contentType = 'Content Description'; // default
                    if (id.toLowerCase().includes('elaboration')) {
                        contentType = 'Elaboration';
                    } else if (id.toLowerCase().includes('achievement')) {
                        contentType = 'Achievement Standard Component';
                    }
                    
                    items.push({
                        id: id,
                        description: description,
                        content_type: contentType,
                        subject_code: subjectCode
                    });
                }
            });
        }
        
        // If still no items, try a more aggressive approach
        if (items.length === 0) {
            console.log('Trying alternative extraction method...');
            
            // Look for any text that might be curriculum content
            const allDescriptions = rdfContent.match(/<dcterms:description[^>]*>([^<]*)<\/dcterms:description>/g);
            if (allDescriptions) {
                console.log(`Found ${allDescriptions.length} dcterms:description elements`);
                
                allDescriptions.forEach((desc, index) => {
                    const content = desc.replace(/<dcterms:description[^>]*>/, '').replace(/<\/dcterms:description>/, '').trim();
                    
                    // Skip metadata descriptions
                    if (content.length > 10 && 
                        !content.toLowerCase().includes('corrected html') &&
                        !content.toLowerCase().includes('copyright') &&
                        !content.toLowerCase().includes('australian curriculum')) {
                        
                        items.push({
                            id: `extracted_${subjectCode}_${index}`,
                            description: content,
                            content_type: 'Content Description',
                            subject_code: subjectCode
                        });
                    }
                });
            }
        }
        
    } catch (error) {
        console.error('Error extracting data from RDF:', error);
    }
    
    console.log(`Extracted ${items.length} items from ${subjectCode}.rdf`);
    return items;
}

// Function to insert data into database
async function insertCurriculumData(items) {
    if (items.length === 0) {
        console.log('No items to insert');
        return;
    }
    
    console.log(`Inserting ${items.length} items into database...`);
    
    // Group items by content type
    const contentDescriptions = items.filter(item => item.content_type === 'Content Description');
    const elaborations = items.filter(item => item.content_type === 'Elaboration');
    const achievementStandards = items.filter(item => item.content_type === 'Achievement Standard Component');
    
    // Insert Content Descriptions
    if (contentDescriptions.length > 0) {
        const { error } = await supabase
            .from('curriculum_content_descriptions')
            .upsert(contentDescriptions.map(item => ({
                id: item.id,
                strand_id: determineStrandFromContent(item.description, item.subject_code),
                code: item.content_type,
                description: cleanCurriculumText(item.description),
                year_level: 'Foundation to Year 10',
                subject_code: item.subject_code
            })));
            
        if (error) {
            console.error('Error inserting content descriptions:', error);
        } else {
            console.log(`Inserted ${contentDescriptions.length} content descriptions`);
        }
    }
    
    // Insert Elaborations
    if (elaborations.length > 0) {
        const { error } = await supabase
            .from('curriculum_elaborations')
            .upsert(elaborations.map(item => ({
                id: item.id,
                strand_id: determineStrandFromContent(item.description, item.subject_code),
                description: cleanCurriculumText(item.description),
                year_level: 'Foundation to Year 10',
                subject_code: item.subject_code
            })));
            
        if (error) {
            console.error('Error inserting elaborations:', error);
        } else {
            console.log(`Inserted ${elaborations.length} elaborations`);
        }
    }
    
    // Insert Achievement Standards
    if (achievementStandards.length > 0) {
        const { error } = await supabase
            .from('curriculum_achievement_standards')
            .upsert(achievementStandards.map(item => ({
                id: item.id,
                strand_id: determineStrandFromContent(item.description, item.subject_code),
                description: cleanCurriculumText(item.description),
                year_level: 'Foundation to Year 10',
                subject_code: item.subject_code
            })));
            
        if (error) {
            console.error('Error inserting achievement standards:', error);
        } else {
            console.log(`Inserted ${achievementStandards.length} achievement standards`);
        }
    }
}

// Helper functions (same as in SQL)
function cleanCurriculumText(inputText) {
    return inputText
        .replace(/Â/g, '')
        .replace(/â"/g, '"')
        .replace(/â/g, '"')
        .replace(/â/g, '"');
}

function determineStrandFromContent(contentText, subjectCode) {
    if (subjectCode === 'ART') {
        if (contentText.toLowerCase().includes('dance') || contentText.toLowerCase().includes('choreograph')) {
            return 'the_arts_dance';
        } else if (contentText.toLowerCase().includes('drama') || contentText.toLowerCase().includes('theatre')) {
            return 'the_arts_drama';
        } else if (contentText.toLowerCase().includes('media') || contentText.toLowerCase().includes('film') || contentText.toLowerCase().includes('television')) {
            return 'the_arts_media_arts';
        } else if (contentText.toLowerCase().includes('music') || contentText.toLowerCase().includes('compos') || contentText.toLowerCase().includes('perform')) {
            return 'the_arts_music';
        } else if (contentText.toLowerCase().includes('art') || contentText.toLowerCase().includes('visual')) {
            return 'the_arts_visual_arts';
        } else {
            return 'the_arts_music';
        }
    } else if (subjectCode === 'ENG') {
        return 'english_language';
    } else if (subjectCode === 'MAT') {
        return 'math_number_and_algebra';
    } else if (subjectCode === 'SCI') {
        return 'science_science_understanding';
    } else {
        return 'the_arts_music'; // fallback
    }
}

// Main processing function
async function processAllRdfFiles() {
    const files = [
        { filename: 'ART.rdf', subjectCode: 'ART' },
        { filename: 'ENG.rdf', subjectCode: 'ENG' },
        { filename: 'MAT.rdf', subjectCode: 'MAT' },
        { filename: 'SCI.rdf', subjectCode: 'SCI' },
        { filename: 'HASS.rdf', subjectCode: 'HASS' },
        { filename: 'HPE.rdf', subjectCode: 'HPE' },
        { filename: 'TEC.rdf', subjectCode: 'TEC' },
        { filename: 'LAN.rdf', subjectCode: 'LAN' }
    ];
    
    console.log('Starting RDF file processing...');
    
    for (const file of files) {
        const rdfContent = await downloadRdfFile(file.filename);
        if (rdfContent) {
            const items = extractCurriculumFromRdf(rdfContent, file.subjectCode);
            await insertCurriculumData(items);
        }
    }
    
    console.log('Processing complete!');
}

// Run the script
processAllRdfFiles().catch(console.error); 