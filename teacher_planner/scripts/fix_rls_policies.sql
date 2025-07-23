-- Fix RLS Policies for Curriculum Tables
-- Run this in your Supabase SQL Editor

-- Add INSERT policies for all curriculum tables
CREATE POLICY "Allow public insert access to curriculum_years" ON curriculum_years
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public insert access to curriculum_subjects" ON curriculum_subjects
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public insert access to curriculum_strands" ON curriculum_strands
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public insert access to curriculum_outcomes" ON curriculum_outcomes
    FOR INSERT WITH CHECK (true);

-- Add UPDATE policies for all curriculum tables
CREATE POLICY "Allow public update access to curriculum_years" ON curriculum_years
    FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow public update access to curriculum_subjects" ON curriculum_subjects
    FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow public update access to curriculum_strands" ON curriculum_strands
    FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow public update access to curriculum_outcomes" ON curriculum_outcomes
    FOR UPDATE USING (true) WITH CHECK (true);

-- Add DELETE policies for all curriculum tables
CREATE POLICY "Allow public delete access to curriculum_years" ON curriculum_years
    FOR DELETE USING (true);

CREATE POLICY "Allow public delete access to curriculum_subjects" ON curriculum_subjects
    FOR DELETE USING (true);

CREATE POLICY "Allow public delete access to curriculum_strands" ON curriculum_strands
    FOR DELETE USING (true);

CREATE POLICY "Allow public delete access to curriculum_outcomes" ON curriculum_outcomes
    FOR DELETE USING (true); 