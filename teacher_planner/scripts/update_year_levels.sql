-- Update year levels to extract individual years from content descriptions
-- This script will parse the content descriptions to find specific year references
-- and update the year_level field accordingly

-- First, let's see what we're working with
SELECT 
    'Current year_level values' as info,
    year_level,
    COUNT(*) as count
FROM curriculum_content_descriptions 
GROUP BY year_level;

-- Update Foundation year content
UPDATE curriculum_content_descriptions 
SET year_level = 'Foundation'
WHERE description ILIKE '%Foundation year%'
   OR description ILIKE '%By the end of the Foundation year%'
   OR description ILIKE '%Foundation students%';

-- Update Year 1 content
UPDATE curriculum_content_descriptions 
SET year_level = 'Year 1'
WHERE description ILIKE '%By the end of Year 1%'
   OR description ILIKE '%Year 1 students%';

-- Update Year 2 content
UPDATE curriculum_content_descriptions 
SET year_level = 'Year 2'
WHERE description ILIKE '%By the end of Year 2%'
   OR description ILIKE '%Year 2 students%';

-- Update Year 3 content
UPDATE curriculum_content_descriptions 
SET year_level = 'Year 3'
WHERE description ILIKE '%By the end of Year 3%'
   OR description ILIKE '%Year 3 students%';

-- Update Year 4 content
UPDATE curriculum_content_descriptions 
SET year_level = 'Year 4'
WHERE description ILIKE '%By the end of Year 4%'
   OR description ILIKE '%Year 4 students%';

-- Update Year 5 content
UPDATE curriculum_content_descriptions 
SET year_level = 'Year 5'
WHERE description ILIKE '%By the end of Year 5%'
   OR description ILIKE '%Year 5 students%';

-- Update Year 6 content
UPDATE curriculum_content_descriptions 
SET year_level = 'Year 6'
WHERE description ILIKE '%By the end of Year 6%'
   OR description ILIKE '%Year 6 students%';

-- Update Year 7 content
UPDATE curriculum_content_descriptions 
SET year_level = 'Year 7'
WHERE description ILIKE '%By the end of Year 7%'
   OR description ILIKE '%Year 7 students%';

-- Update Year 8 content
UPDATE curriculum_content_descriptions 
SET year_level = 'Year 8'
WHERE description ILIKE '%By the end of Year 8%'
   OR description ILIKE '%Year 8 students%';

-- Update Year 9 content
UPDATE curriculum_content_descriptions 
SET year_level = 'Year 9'
WHERE description ILIKE '%By the end of Year 9%'
   OR description ILIKE '%Year 9 students%';

-- Update Year 10 content
UPDATE curriculum_content_descriptions 
SET year_level = 'Year 10'
WHERE description ILIKE '%By the end of Year 10%'
   OR description ILIKE '%Year 10 students%';

-- Check the results
SELECT 
    'Updated year_level values' as info,
    year_level,
    COUNT(*) as count
FROM curriculum_content_descriptions 
GROUP BY year_level
ORDER BY year_level;

-- Show some sample records to verify the updates
SELECT 
    year_level,
    subject_code,
    strand_id,
    LEFT(description, 100) as sample_description
FROM curriculum_content_descriptions 
ORDER BY year_level, subject_code
LIMIT 20; 