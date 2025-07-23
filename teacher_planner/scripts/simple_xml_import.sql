-- Simple XML Import from Supabase Storage
-- This is a simplified version that should work without syntax errors

-- First, let's check the structure of the storage.objects table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'objects' 
AND table_schema = 'storage'
ORDER BY ordinal_position;

-- Let's also see what's actually in the storage.objects table
SELECT * FROM storage.objects LIMIT 1;

-- Now let's check if we can find our XML file
SELECT 
    name,
    bucket_id,
    created_at,
    updated_at
FROM storage.objects 
WHERE bucket_id = 'curriculum-data' 
AND name = 'art-curriculum.xml';

-- Let's manually insert the basic subjects we know exist
INSERT INTO curriculum_subjects (id, name, code, description)
VALUES 
    ('learning_areas', 'Learning Areas', 'LA', 'Australian Curriculum Learning Areas'),
    ('the_arts', 'The Arts', 'ART', 'Australian Curriculum - The Arts')
ON CONFLICT (id) DO NOTHING;

-- Let's see what we have
SELECT 'Subjects in database:' as info, COUNT(*)::text as count FROM curriculum_subjects;

-- Show the subjects
SELECT id, name, code FROM curriculum_subjects; 