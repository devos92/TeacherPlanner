-- Check what year level values exist in the database
SELECT 
    year_level,
    COUNT(*) as count
FROM curriculum_content_descriptions 
GROUP BY year_level
ORDER BY year_level;

-- Check a few sample records to see the year level format
SELECT 
    year_level,
    subject_code,
    strand_id,
    LEFT(description, 100) as sample_description
FROM curriculum_content_descriptions 
ORDER BY year_level, subject_code
LIMIT 10; 