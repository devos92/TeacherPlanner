-- Comprehensive analysis of curriculum data to find year categorization patterns

-- 1. Check all table structures
SELECT 
    'Table Structure Analysis' as section,
    table_name,
    column_name,
    data_type
FROM information_schema.columns 
WHERE table_name LIKE 'curriculum_%'
ORDER BY table_name, ordinal_position;

-- 2. Check what's in each table
SELECT 'Content Descriptions Count' as info, COUNT(*) as count FROM curriculum_content_descriptions
UNION ALL
SELECT 'Strands Count', COUNT(*) FROM curriculum_strands
UNION ALL
SELECT 'Subjects Count', COUNT(*) FROM curriculum_subjects
UNION ALL
SELECT 'Elaborations Count', COUNT(*) FROM curriculum_elaborations
UNION ALL
SELECT 'Achievement Standards Count', COUNT(*) FROM curriculum_achievement_standards;

-- 3. Analyze content descriptions for year patterns
SELECT 
    'Year Level Patterns' as section,
    year_level,
    COUNT(*) as count,
    MIN(LEFT(description, 50)) as sample_description
FROM curriculum_content_descriptions 
GROUP BY year_level
ORDER BY year_level;

-- 4. Look for year references in descriptions
SELECT 
    'Year References in Descriptions' as section,
    CASE 
        WHEN description ILIKE '%Foundation%' THEN 'Foundation'
        WHEN description ILIKE '%Year 1%' THEN 'Year 1'
        WHEN description ILIKE '%Year 2%' THEN 'Year 2'
        WHEN description ILIKE '%Year 3%' THEN 'Year 3'
        WHEN description ILIKE '%Year 4%' THEN 'Year 4'
        WHEN description ILIKE '%Year 5%' THEN 'Year 5'
        WHEN description ILIKE '%Year 6%' THEN 'Year 6'
        WHEN description ILIKE '%Year 7%' THEN 'Year 7'
        WHEN description ILIKE '%Year 8%' THEN 'Year 8'
        WHEN description ILIKE '%Year 9%' THEN 'Year 9'
        WHEN description ILIKE '%Year 10%' THEN 'Year 10'
        ELSE 'No specific year'
    END as detected_year,
    COUNT(*) as count
FROM curriculum_content_descriptions 
GROUP BY 
    CASE 
        WHEN description ILIKE '%Foundation%' THEN 'Foundation'
        WHEN description ILIKE '%Year 1%' THEN 'Year 1'
        WHEN description ILIKE '%Year 2%' THEN 'Year 2'
        WHEN description ILIKE '%Year 3%' THEN 'Year 3'
        WHEN description ILIKE '%Year 4%' THEN 'Year 4'
        WHEN description ILIKE '%Year 5%' THEN 'Year 5'
        WHEN description ILIKE '%Year 6%' THEN 'Year 6'
        WHEN description ILIKE '%Year 7%' THEN 'Year 7'
        WHEN description ILIKE '%Year 8%' THEN 'Year 8'
        WHEN description ILIKE '%Year 9%' THEN 'Year 9'
        WHEN description ILIKE '%Year 10%' THEN 'Year 10'
        ELSE 'No specific year'
    END
ORDER BY detected_year;

-- 5. Check if there are any other fields that might indicate year levels
SELECT 
    'Code Analysis' as section,
    code,
    COUNT(*) as count,
    MIN(LEFT(description, 50)) as sample_description
FROM curriculum_content_descriptions 
WHERE code IS NOT NULL
GROUP BY code
ORDER BY code
LIMIT 20;

-- 6. Check subject distribution
SELECT 
    'Subject Distribution' as section,
    subject_code,
    COUNT(*) as count,
    MIN(LEFT(description, 50)) as sample_description
FROM curriculum_content_descriptions 
GROUP BY subject_code
ORDER BY subject_code;

-- 7. Check strand distribution
SELECT 
    'Strand Distribution' as section,
    strand_id,
    COUNT(*) as count,
    MIN(LEFT(description, 50)) as sample_description
FROM curriculum_content_descriptions 
GROUP BY strand_id
ORDER BY strand_id
LIMIT 20;

-- 8. Look for any metadata or additional fields
SELECT 
    'All Fields Sample' as section,
    *
FROM curriculum_content_descriptions 
LIMIT 5;

-- 9. Check if there are any other tables with year information
SELECT 
    'Other Tables with Year Info' as section,
    table_name,
    column_name
FROM information_schema.columns 
WHERE column_name ILIKE '%year%' 
   OR column_name ILIKE '%level%'
   OR column_name ILIKE '%grade%'
ORDER BY table_name, column_name; 