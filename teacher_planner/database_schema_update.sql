-- Database Schema Update for Teacher Planner
-- Add missing columns to weekly_plans table

-- Add missing columns to weekly_plans table
ALTER TABLE weekly_plans 
ADD COLUMN IF NOT EXISTS week_start_date DATE,
ADD COLUMN IF NOT EXISTS periods INTEGER DEFAULT 5,
ADD COLUMN IF NOT EXISTS is_vertical_layout BOOLEAN DEFAULT TRUE;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_weekly_plans_user_id ON weekly_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_weekly_plans_week_start_date ON weekly_plans(week_start_date);

-- Enable RLS (Row Level Security)
ALTER TABLE weekly_plans ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own weekly plans" ON weekly_plans;
DROP POLICY IF EXISTS "Users can update own weekly plans" ON weekly_plans;
DROP POLICY IF EXISTS "Users can insert own weekly plans" ON weekly_plans;

-- Policy: Allow insert during development (no auth required for now)
CREATE POLICY "Allow weekly plan insert" ON weekly_plans
    FOR INSERT WITH CHECK (true);

-- Policy: Users can view their own weekly plans (requires auth)
CREATE POLICY "Users can view own weekly plans" ON weekly_plans
    FOR SELECT USING (auth.uid()::uuid = user_id);

-- Policy: Users can update their own weekly plans (requires auth)
CREATE POLICY "Users can update own weekly plans" ON weekly_plans
    FOR UPDATE USING (auth.uid()::uuid = user_id);

-- Verify the table structure
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'weekly_plans'
ORDER BY ordinal_position; 