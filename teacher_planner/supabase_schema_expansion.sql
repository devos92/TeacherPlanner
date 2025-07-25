-- Supabase Schema Expansion for Teacher Planner
-- This file extends the existing curriculum schema with teacher planning features

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS teacher_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    school_name TEXT,
    year_level TEXT,
    subject_specialization TEXT[],
    avatar_url TEXT,
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enhanced Events Table
CREATE TABLE IF NOT EXISTS enhanced_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID REFERENCES teacher_profiles(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    subject TEXT NOT NULL,
    subtitle TEXT DEFAULT '',
    body TEXT DEFAULT '',
    status TEXT DEFAULT 'planned' CHECK (status IN ('planned', 'completed', 'cancelled')),
    priority INTEGER DEFAULT 1 CHECK (priority BETWEEN 1 AND 5),
    location TEXT,
    notes TEXT,
    tags TEXT[],
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Daily Reflections Table
CREATE TABLE IF NOT EXISTS daily_reflections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID REFERENCES teacher_profiles(id) ON DELETE CASCADE,
    date DATE NOT NULL UNIQUE,
    overall_rating INTEGER CHECK (overall_rating BETWEEN 1 AND 5),
    what_went_well TEXT,
    challenges_faced TEXT,
    lessons_learned TEXT,
    tomorrow_focus TEXT,
    mood TEXT,
    energy_level INTEGER CHECK (energy_level BETWEEN 1 AND 5),
    tags TEXT[],
    private_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Attachments Table (for images, documents, links)
CREATE TABLE IF NOT EXISTS attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID REFERENCES teacher_profiles(id) ON DELETE CASCADE,
    parent_id UUID NOT NULL, -- References enhanced_events.id or daily_reflections.id
    parent_type TEXT NOT NULL CHECK (parent_type IN ('event', 'reflection')),
    name TEXT NOT NULL,
    file_path TEXT, -- Supabase storage path
    file_url TEXT, -- Public URL from Supabase storage
    file_type TEXT NOT NULL CHECK (file_type IN ('image', 'document', 'video', 'audio', 'link', 'other')),
    file_size BIGINT,
    mime_type TEXT,
    description TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Hyperlinks Table (separate from attachments for better organization)
CREATE TABLE IF NOT EXISTS hyperlinks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID REFERENCES teacher_profiles(id) ON DELETE CASCADE,
    parent_id UUID NOT NULL,
    parent_type TEXT NOT NULL CHECK (parent_type IN ('event', 'reflection')),
    title TEXT NOT NULL,
    url TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Event-Curriculum Outcomes Junction Table
CREATE TABLE IF NOT EXISTS event_outcomes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES enhanced_events(id) ON DELETE CASCADE,
    outcome_id VARCHAR(255) REFERENCES curriculum_outcomes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(event_id, outcome_id)
);

-- Templates Table (for reusable lesson plans)
CREATE TABLE IF NOT EXISTS lesson_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID REFERENCES teacher_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    subject TEXT NOT NULL,
    duration_minutes INTEGER,
    template_data JSONB NOT NULL, -- Stores the lesson structure
    tags TEXT[],
    is_public BOOLEAN DEFAULT false,
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Shared Resources Table (for teacher collaboration)
CREATE TABLE IF NOT EXISTS shared_resources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shared_by UUID REFERENCES teacher_profiles(id) ON DELETE CASCADE,
    resource_type TEXT NOT NULL CHECK (resource_type IN ('event', 'template', 'attachment')),
    resource_id UUID NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    subject TEXT,
    year_level TEXT,
    tags TEXT[],
    downloads_count INTEGER DEFAULT 0,
    rating_average DECIMAL(3,2) DEFAULT 0.0,
    rating_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_enhanced_events_teacher_date ON enhanced_events(teacher_id, date);
CREATE INDEX IF NOT EXISTS idx_enhanced_events_date ON enhanced_events(date);
CREATE INDEX IF NOT EXISTS idx_enhanced_events_subject ON enhanced_events(subject);
CREATE INDEX IF NOT EXISTS idx_daily_reflections_teacher_date ON daily_reflections(teacher_id, date);
CREATE INDEX IF NOT EXISTS idx_attachments_parent ON attachments(parent_id, parent_type);
CREATE INDEX IF NOT EXISTS idx_attachments_teacher ON attachments(teacher_id);
CREATE INDEX IF NOT EXISTS idx_hyperlinks_parent ON hyperlinks(parent_id, parent_type);
CREATE INDEX IF NOT EXISTS idx_event_outcomes_event ON event_outcomes(event_id);
CREATE INDEX IF NOT EXISTS idx_event_outcomes_outcome ON event_outcomes(outcome_id);
CREATE INDEX IF NOT EXISTS idx_lesson_templates_teacher ON lesson_templates(teacher_id);
CREATE INDEX IF NOT EXISTS idx_shared_resources_subject ON shared_resources(subject);

-- Full-text search indexes
CREATE INDEX IF NOT EXISTS idx_enhanced_events_search ON enhanced_events 
USING gin(to_tsvector('english', subject || ' ' || COALESCE(body, '') || ' ' || COALESCE(notes, '')));

CREATE INDEX IF NOT EXISTS idx_reflections_search ON daily_reflections 
USING gin(to_tsvector('english', COALESCE(what_went_well, '') || ' ' || COALESCE(challenges_faced, '') || ' ' || COALESCE(lessons_learned, '')));

-- Enable Row Level Security
ALTER TABLE teacher_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE enhanced_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_reflections ENABLE ROW LEVEL SECURITY;
ALTER TABLE attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE hyperlinks ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_outcomes ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE shared_resources ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Teacher profiles: users can only access their own profile
CREATE POLICY "Users can view own profile" ON teacher_profiles
    FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON teacher_profiles
    FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON teacher_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Enhanced events: teachers can only access their own events
CREATE POLICY "Teachers can view own events" ON enhanced_events
    FOR SELECT USING (auth.uid() = teacher_id);
CREATE POLICY "Teachers can create own events" ON enhanced_events
    FOR INSERT WITH CHECK (auth.uid() = teacher_id);
CREATE POLICY "Teachers can update own events" ON enhanced_events
    FOR UPDATE USING (auth.uid() = teacher_id);
CREATE POLICY "Teachers can delete own events" ON enhanced_events
    FOR DELETE USING (auth.uid() = teacher_id);

-- Daily reflections: teachers can only access their own reflections
CREATE POLICY "Teachers can view own reflections" ON daily_reflections
    FOR SELECT USING (auth.uid() = teacher_id);
CREATE POLICY "Teachers can create own reflections" ON daily_reflections
    FOR INSERT WITH CHECK (auth.uid() = teacher_id);
CREATE POLICY "Teachers can update own reflections" ON daily_reflections
    FOR UPDATE USING (auth.uid() = teacher_id);
CREATE POLICY "Teachers can delete own reflections" ON daily_reflections
    FOR DELETE USING (auth.uid() = teacher_id);

-- Attachments: teachers can only access their own attachments
CREATE POLICY "Teachers can view own attachments" ON attachments
    FOR SELECT USING (auth.uid() = teacher_id);
CREATE POLICY "Teachers can create own attachments" ON attachments
    FOR INSERT WITH CHECK (auth.uid() = teacher_id);
CREATE POLICY "Teachers can update own attachments" ON attachments
    FOR UPDATE USING (auth.uid() = teacher_id);
CREATE POLICY "Teachers can delete own attachments" ON attachments
    FOR DELETE USING (auth.uid() = teacher_id);

-- Hyperlinks: teachers can only access their own hyperlinks
CREATE POLICY "Teachers can view own hyperlinks" ON hyperlinks
    FOR SELECT USING (auth.uid() = teacher_id);
CREATE POLICY "Teachers can create own hyperlinks" ON hyperlinks
    FOR INSERT WITH CHECK (auth.uid() = teacher_id);
CREATE POLICY "Teachers can update own hyperlinks" ON hyperlinks
    FOR UPDATE USING (auth.uid() = teacher_id);
CREATE POLICY "Teachers can delete own hyperlinks" ON hyperlinks
    FOR DELETE USING (auth.uid() = teacher_id);

-- Event outcomes: teachers can only access outcomes for their events
CREATE POLICY "Teachers can view own event outcomes" ON event_outcomes
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM enhanced_events 
            WHERE enhanced_events.id = event_outcomes.event_id 
            AND enhanced_events.teacher_id = auth.uid()
        )
    );
CREATE POLICY "Teachers can create own event outcomes" ON event_outcomes
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM enhanced_events 
            WHERE enhanced_events.id = event_outcomes.event_id 
            AND enhanced_events.teacher_id = auth.uid()
        )
    );
CREATE POLICY "Teachers can delete own event outcomes" ON event_outcomes
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM enhanced_events 
            WHERE enhanced_events.id = event_outcomes.event_id 
            AND enhanced_events.teacher_id = auth.uid()
        )
    );

-- Lesson templates: teachers can view their own and public templates
CREATE POLICY "Teachers can view accessible templates" ON lesson_templates
    FOR SELECT USING (auth.uid() = teacher_id OR is_public = true);
CREATE POLICY "Teachers can create own templates" ON lesson_templates
    FOR INSERT WITH CHECK (auth.uid() = teacher_id);
CREATE POLICY "Teachers can update own templates" ON lesson_templates
    FOR UPDATE USING (auth.uid() = teacher_id);
CREATE POLICY "Teachers can delete own templates" ON lesson_templates
    FOR DELETE USING (auth.uid() = teacher_id);

-- Shared resources: public read access, creators can manage
CREATE POLICY "Public can view active shared resources" ON shared_resources
    FOR SELECT USING (is_active = true);
CREATE POLICY "Creators can manage shared resources" ON shared_resources
    FOR ALL USING (auth.uid() = shared_by);

-- Create triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_teacher_profiles_updated_at BEFORE UPDATE ON teacher_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_enhanced_events_updated_at BEFORE UPDATE ON enhanced_events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_daily_reflections_updated_at BEFORE UPDATE ON daily_reflections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_attachments_updated_at BEFORE UPDATE ON attachments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_hyperlinks_updated_at BEFORE UPDATE ON hyperlinks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_lesson_templates_updated_at BEFORE UPDATE ON lesson_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_shared_resources_updated_at BEFORE UPDATE ON shared_resources
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create useful views
CREATE OR REPLACE VIEW events_with_attachments AS
SELECT 
    e.*,
    COALESCE(
        JSON_AGG(
            JSON_BUILD_OBJECT(
                'id', a.id,
                'name', a.name,
                'file_url', a.file_url,
                'file_type', a.file_type,
                'file_size', a.file_size
            )
        ) FILTER (WHERE a.id IS NOT NULL), 
        '[]'::json
    ) as attachments,
    COALESCE(
        JSON_AGG(
            JSON_BUILD_OBJECT(
                'id', h.id,
                'title', h.title,
                'url', h.url,
                'description', h.description
            )
        ) FILTER (WHERE h.id IS NOT NULL), 
        '[]'::json
    ) as hyperlinks
FROM enhanced_events e
LEFT JOIN attachments a ON e.id = a.parent_id AND a.parent_type = 'event'
LEFT JOIN hyperlinks h ON e.id = h.parent_id AND h.parent_type = 'event'
GROUP BY e.id;

CREATE OR REPLACE VIEW events_with_outcomes AS
SELECT 
    e.*,
    COALESCE(
        JSON_AGG(
            JSON_BUILD_OBJECT(
                'outcome_id', co.id,
                'outcome_code', co.code,
                'outcome_description', co.description,
                'subject_name', cs.name,
                'strand_name', cst.name
            )
        ) FILTER (WHERE co.id IS NOT NULL), 
        '[]'::json
    ) as curriculum_outcomes
FROM enhanced_events e
LEFT JOIN event_outcomes eo ON e.id = eo.event_id
LEFT JOIN curriculum_outcomes co ON eo.outcome_id = co.id
LEFT JOIN curriculum_strands cst ON co.strand_id = cst.id
LEFT JOIN curriculum_subjects cs ON cst.subject_id = cs.id
GROUP BY e.id;

-- Grant permissions
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated; 