-- Debug: Check what subjects are available for different year levels
SELECT 
  'Level 1 (Foundation)' as level_info,
  c.level_id,
  c.subject_id,
  s.name as subject_name,
  COUNT(*) as curriculum_count
FROM curriculum c
JOIN subject s ON c.subject_id = s.id
WHERE c.level_id = 1 
  AND c.subject_id IS NOT NULL
GROUP BY c.level_id, c.subject_id, s.name
ORDER BY s.name;

-- Check Level 2 (Year 1)
SELECT 
  'Level 2 (Year 1)' as level_info,
  c.level_id,
  c.subject_id,
  s.name as subject_name,
  COUNT(*) as curriculum_count
FROM curriculum c
JOIN subject s ON c.subject_id = s.id
WHERE c.level_id = 2 
  AND c.subject_id IS NOT NULL
GROUP BY c.level_id, c.subject_id, s.name
ORDER BY s.name; 