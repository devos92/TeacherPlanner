-- Re-import curriculum data properly
-- First, let's clear the existing data to start fresh
DELETE FROM curriculum;

-- Create a new temporary table with the correct structure
DROP TABLE IF EXISTS temp_curriculum_import_v2;
CREATE TABLE temp_curriculum_import_v2 (
    "Learning Area" TEXT,
    "Subject" TEXT,
    "Level" TEXT,
    "Code" TEXT,
    "Strand" TEXT,
    "Sub-Strand" TEXT,
    "Content Description" TEXT,
    "Elaboration" TEXT
);

-- Now you need to:
-- 1. Export your Excel data to CSV with these exact column headers
-- 2. Import the CSV into this temp_curriculum_import_v2 table
-- 3. Run the processing script below

-- Processing script to map the data correctly
INSERT INTO curriculum (
    code,
    content_description,
    elaboration,
    level_id,
    subject_id,
    strand_id,
    sub_strand_id
)
SELECT 
    t."Code",
    t."Content Description",
    t."Elaboration",
    l.id as level_id,
    s.id as subject_id,
    st.id as strand_id,
    ss.id as sub_strand_id
FROM temp_curriculum_import_v2 t
JOIN level l ON l.name = t."Level"
JOIN subject s ON s.name = t."Subject"
LEFT JOIN strand st ON st.name = t."Strand"
LEFT JOIN sub_strand ss ON ss.name = t."Sub-Strand"
WHERE t."Code" IS NOT NULL;

-- Verify the import
SELECT 
    'Import Verification' as info,
    COUNT(*) as total_imported,
    COUNT(CASE WHEN content_description IS NOT NULL AND content_description != '' THEN 1 END) as has_descriptions,
    COUNT(CASE WHEN elaboration IS NOT NULL AND elaboration != '' THEN 1 END) as has_elaborations
FROM curriculum; 