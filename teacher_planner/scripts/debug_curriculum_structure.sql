-- First, check the actual structure of the curriculum table
SELECT 
  'Curriculum Table Structure' as info,
  column_name, 
  data_type, 
  is_nullable 
FROM information_schema.columns 
WHERE table_name = 'curriculum' 
ORDER BY ordinal_position;

-- Get all Year 1 Maths Number strand data
SELECT 
  'Year 1 Maths Number Strand - All Data' as info,
  c.code,
  c.content_description,
  c.elaboration,
  l.name as level_name,
  s.name as subject_name,
  st.name as strand_name,
  ss.name as sub_strand_name
FROM curriculum c
JOIN level l ON c.level_id = l.id
JOIN subject s ON c.subject_id = s.id
LEFT JOIN strand st ON c.strand_id = st.id
LEFT JOIN sub_strand ss ON c.sub_strand_id = ss.id
WHERE c.level_id = 2  -- Year 1
  AND c.subject_id = 19  -- Mathematics
  AND c.strand_id = 41  -- Number
ORDER BY c.code;

-- Check total count for Year 1 Maths Number
SELECT 
  'Year 1 Maths Number Count' as info,
  COUNT(*) as total_outcomes
FROM curriculum c
WHERE c.level_id = 2  -- Year 1
  AND c.subject_id = 19  -- Mathematics
  AND c.strand_id = 41  -- Number; 