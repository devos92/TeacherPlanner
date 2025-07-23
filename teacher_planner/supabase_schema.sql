-- Supabase Database Schema for Australian Curriculum
-- This file contains the SQL to create the curriculum tables

-- Create curriculum_years table
CREATE TABLE IF NOT EXISTS curriculum_years (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create curriculum_subjects table
CREATE TABLE IF NOT EXISTS curriculum_subjects (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create curriculum_strands table
CREATE TABLE IF NOT EXISTS curriculum_strands (
    id VARCHAR(255) PRIMARY KEY,
    subject_id VARCHAR(255) REFERENCES curriculum_subjects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create curriculum_outcomes table
CREATE TABLE IF NOT EXISTS curriculum_outcomes (
    id VARCHAR(255) PRIMARY KEY,
    strand_id VARCHAR(255) REFERENCES curriculum_strands(id) ON DELETE CASCADE,
    code VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    elaboration TEXT,
    year_level VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_curriculum_strands_subject_id ON curriculum_strands(subject_id);
CREATE INDEX IF NOT EXISTS idx_curriculum_outcomes_strand_id ON curriculum_outcomes(strand_id);
CREATE INDEX IF NOT EXISTS idx_curriculum_outcomes_year_level ON curriculum_outcomes(year_level);
CREATE INDEX IF NOT EXISTS idx_curriculum_outcomes_code ON curriculum_outcomes(code);

-- Create full-text search index for outcomes
CREATE INDEX IF NOT EXISTS idx_curriculum_outcomes_search ON curriculum_outcomes USING gin(to_tsvector('english', description || ' ' || elaboration));

-- Enable Row Level Security
ALTER TABLE curriculum_years ENABLE ROW LEVEL SECURITY;
ALTER TABLE curriculum_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE curriculum_strands ENABLE ROW LEVEL SECURITY;
ALTER TABLE curriculum_outcomes ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access
CREATE POLICY "Allow public read access to curriculum_years" ON curriculum_years
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access to curriculum_subjects" ON curriculum_subjects
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access to curriculum_strands" ON curriculum_strands
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access to curriculum_outcomes" ON curriculum_outcomes
    FOR SELECT USING (true);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update updated_at
CREATE TRIGGER update_curriculum_years_updated_at BEFORE UPDATE ON curriculum_years
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_curriculum_subjects_updated_at BEFORE UPDATE ON curriculum_subjects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_curriculum_strands_updated_at BEFORE UPDATE ON curriculum_strands
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_curriculum_outcomes_updated_at BEFORE UPDATE ON curriculum_outcomes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create view for easy curriculum queries
CREATE OR REPLACE VIEW curriculum_full_view AS
SELECT 
    co.id as outcome_id,
    co.code as outcome_code,
    co.description as outcome_description,
    co.elaboration as outcome_elaboration,
    co.year_level,
    cs.id as strand_id,
    cs.name as strand_name,
    cs.description as strand_description,
    csub.id as subject_id,
    csub.name as subject_name,
    csub.code as subject_code,
    csub.description as subject_description
FROM curriculum_outcomes co
JOIN curriculum_strands cs ON co.strand_id = cs.id
JOIN curriculum_subjects csub ON cs.subject_id = csub.id
ORDER BY csub.name, cs.name, co.code;

-- Grant permissions
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT SELECT ON curriculum_full_view TO anon;
GRANT SELECT ON curriculum_full_view TO authenticated; 