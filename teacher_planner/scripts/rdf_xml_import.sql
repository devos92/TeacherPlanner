-- RDF/XML Curriculum Data Import Script
-- This script imports the MRAC RDF/XML data into your curriculum tables

-- Step 1: Create a temporary table to store the XML content
CREATE TEMP TABLE raw_xml_data (
    id SERIAL PRIMARY KEY,
    xml_content XML
);

-- Step 2: Insert your XML content (replace with your actual XML)
-- You'll need to copy your XML content and paste it here
-- INSERT INTO raw_xml_data (xml_content) VALUES ('<your_xml_content_here>');

-- Step 3: Extract Learning Areas (Subjects)
INSERT INTO curriculum_subjects (id, name, code, description)
SELECT DISTINCT
    -- Extract UUID from rdf:about
    SPLIT_PART(xpath('//rdf:Description/@rdf:about', xml_content)[1], '/', -1) as id,
    -- Extract title
    xpath('//dcterms:title/text()', xml_content)[1]::text as name,
    -- Extract statement notation as code
    xpath('//statementNotation/text()', xml_content)[1]::text as code,
    -- Extract description
    xpath('//dcterms:description/text()', xml_content)[1]::text as description
FROM raw_xml_data,
     unnest(xpath('//rdf:Description', xml_content)) as desc_elements
WHERE 
    -- Filter for Learning Areas (subjects)
    xpath('//dcterms:title/text()', desc_elements)[1]::text LIKE '%Learning Areas%'
    OR xpath('//statementNotation/text()', desc_elements)[1]::text = 'LA'
    OR xpath('//statementNotation/text()', desc_elements)[1]::text = 'ART'
ON CONFLICT (id) DO NOTHING;

-- Step 4: Extract Strands (Content Descriptions)
INSERT INTO curriculum_strands (id, subject_id, name, description)
SELECT DISTINCT
    -- Extract UUID from rdf:about
    SPLIT_PART(xpath('//@rdf:about', desc_elements)[1], '/', -1) as id,
    -- Extract parent subject ID from isChildOf relationship
    SPLIT_PART(
        xpath('//isChildOf/@rdf:resource', desc_elements)[1], 
        '/', 
        -1
    ) as subject_id,
    -- Extract title
    xpath('//dcterms:title/text()', desc_elements)[1]::text as name,
    -- Extract description
    xpath('//dcterms:description/text()', desc_elements)[1]::text as description
FROM raw_xml_data,
     unnest(xpath('//rdf:Description', xml_content)) as desc_elements
WHERE 
    -- Filter for strands (not subjects, not outcomes)
    xpath('//dcterms:title/text()', desc_elements)[1]::text NOT LIKE '%Learning Areas%'
    AND xpath('//statementNotation/text()', desc_elements)[1]::text NOT IN ('LA', 'root')
    AND xpath('//statementLabel/text()', desc_elements)[1]::text NOT LIKE '%Achievement%'
    AND xpath('//isChildOf/@rdf:resource', desc_elements)[1] IS NOT NULL
    AND xpath('//isChildOf/@rdf:resource', desc_elements)[1]::text LIKE '%/LA/%'
ON CONFLICT (id) DO NOTHING;

-- Step 5: Extract Achievement Standards (Outcomes)
INSERT INTO curriculum_outcomes (id, strand_id, code, description, elaboration, year_level)
SELECT DISTINCT
    -- Extract UUID from rdf:about
    SPLIT_PART(xpath('//@rdf:about', desc_elements)[1], '/', -1) as id,
    -- Extract parent strand ID from isChildOf relationship
    SPLIT_PART(
        xpath('//isChildOf/@rdf:resource', desc_elements)[1], 
        '/', 
        -1
    ) as strand_id,
    -- Extract statement notation as code
    xpath('//statementNotation/text()', desc_elements)[1]::text as code,
    -- Extract description
    xpath('//dcterms:description/text()', desc_elements)[1]::text as description,
    -- Extract elaboration (if available)
    COALESCE(xpath('//elaboration/text()', desc_elements)[1]::text, '') as elaboration,
    -- Extract year level from statement notation
    CASE 
        WHEN xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%FY%' THEN 'foundation'
        WHEN xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y1%' THEN 'year1'
        WHEN xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y2%' THEN 'year2'
        WHEN xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y3%' THEN 'year3'
        WHEN xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y4%' THEN 'year4'
        WHEN xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y5%' THEN 'year5'
        WHEN xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y6%' THEN 'year6'
        WHEN xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y7%' THEN 'year7'
        WHEN xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y8%' THEN 'year8'
        WHEN xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y9%' THEN 'year9'
        WHEN xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y10%' THEN 'year10'
        ELSE 'unknown'
    END as year_level
FROM raw_xml_data,
     unnest(xpath('//rdf:Description', xml_content)) as desc_elements
WHERE 
    -- Filter for Achievement Standards (outcomes)
    xpath('//statementLabel/text()', desc_elements)[1]::text LIKE '%Achievement%'
    OR xpath('//statementNotation/text()', desc_elements)[1]::text LIKE 'AS%'
    OR xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%FY%'
    OR xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y1%'
    OR xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y2%'
    OR xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y3%'
    OR xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y4%'
    OR xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y5%'
    OR xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Y6%'
ON CONFLICT (id) DO NOTHING;

-- Step 6: Extract Years (if any exist)
INSERT INTO curriculum_years (id, name, description)
SELECT DISTINCT
    -- Extract UUID from rdf:about
    SPLIT_PART(xpath('//@rdf:about', desc_elements)[1], '/', -1) as id,
    -- Extract title
    xpath('//dcterms:title/text()', desc_elements)[1]::text as name,
    -- Extract description
    xpath('//dcterms:description/text()', desc_elements)[1]::text as description
FROM raw_xml_data,
     unnest(xpath('//rdf:Description', xml_content)) as desc_elements
WHERE 
    -- Filter for years
    xpath('//dcterms:title/text()', desc_elements)[1]::text LIKE '%Year%'
    OR xpath('//dcterms:title/text()', desc_elements)[1]::text LIKE '%Foundation%'
    OR xpath('//statementNotation/text()', desc_elements)[1]::text LIKE '%Year%'
ON CONFLICT (id) DO NOTHING;

-- Step 7: Clean up
DROP TABLE raw_xml_data;

-- Step 8: Verify the import
SELECT 'Import Summary' as info, '' as details
UNION ALL
SELECT 'Subjects imported:', COUNT(*)::text FROM curriculum_subjects
UNION ALL
SELECT 'Strands imported:', COUNT(*)::text FROM curriculum_strands
UNION ALL
SELECT 'Outcomes imported:', COUNT(*)::text FROM curriculum_outcomes
UNION ALL
SELECT 'Years imported:', COUNT(*)::text FROM curriculum_years;

-- Step 9: Show sample data
SELECT 'Sample Subjects:' as info, '' as details
UNION ALL
SELECT name, code FROM curriculum_subjects LIMIT 5;

SELECT 'Sample Outcomes:' as info, '' as details
UNION ALL
SELECT code, LEFT(description, 100) || '...' FROM curriculum_outcomes LIMIT 5; 