-- Debug: Check what content is available in curriculum table
SELECT 
  'Sample Curriculum Content' as info,
  code,
  content_description,
  elaboration,
  level_id,
  subject_id,
  strand_id,
  sub_strand_id,
  CASE 
    WHEN content_description IS NOT NULL AND content_description != '' THEN 'Has description'
    WHEN elaboration IS NOT NULL AND elaboration != '' THEN 'Has elaboration'
    ELSE 'No content'
  END as content_status
FROM curriculum 
WHERE level_id = 1 
  AND subject_id = 8  -- English
LIMIT 20;

-- Check if there are any records with actual content
SELECT 
  'Content Analysis' as info,
  COUNT(*) as total_records,
  COUNT(CASE WHEN content_description IS NOT NULL AND content_description != '' THEN 1 END) as has_description,
  COUNT(CASE WHEN elaboration IS NOT NULL AND elaboration != '' THEN 1 END) as has_elaboration,
  COUNT(CASE WHEN content_description IS NULL OR content_description = '' THEN 1 END) as no_description
FROM curriculum; 