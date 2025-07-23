-- Debug script to see what's in the curriculum tables

-- 1. Check what's in curriculum_content_descriptions
SELECT 
    'Content Descriptions' as table_name,
    COUNT(*) as total_count,
    COUNT(DISTINCT subject_code) as unique_subjects,
    COUNT(DISTINCT year_level) as unique_years,
    COUNT(DISTINCT strand_id) as unique_strands
FROM curriculum_content_descriptions;

-- 2. Show sample content descriptions
SELECT 
    subject_code,
    year_level,
    strand_id,
    LEFT(description, 100) as sample_description
FROM curriculum_content_descriptions 
ORDER BY subject_code, year_level
LIMIT 10;

-- 3. Check what subjects we have
SELECT 
    subject_code,
    COUNT(*) as count
FROM curriculum_content_descriptions 
GROUP BY subject_code
ORDER BY subject_code;

-- 4. Check what year levels we have
SELECT 
    year_level,
    COUNT(*) as count
FROM curriculum_content_descriptions 
GROUP BY year_level
ORDER BY year_level;

-- 5. Check what strands we have
SELECT 
    strand_id,
    COUNT(*) as count
FROM curriculum_content_descriptions 
GROUP BY strand_id
ORDER BY strand_id
LIMIT 10;

-- 6. Check the strands table
SELECT 
    'Strands Table' as table_name,
    COUNT(*) as total_count
FROM curriculum_strands;

-- 7. Show sample strands
SELECT 
    id,
    name,
    subject_id,
    LEFT(description, 100) as sample_description
FROM curriculum_strands 
ORDER BY subject_id, name
LIMIT 10;

-- 8. Check the subjects table
SELECT 
    'Subjects Table' as table_name,
    COUNT(*) as total_count
FROM curriculum_subjects;

-- 9. Show all subjects
SELECT 
    code,
    name,
    description
FROM curriculum_subjects 
ORDER BY name;

-- 10. Check the actual table structure
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'curriculum_strands'
ORDER BY ordinal_position; 