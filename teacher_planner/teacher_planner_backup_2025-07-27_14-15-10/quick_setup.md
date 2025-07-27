# Quick Setup - MRAC Data Upload

## 🚨 Current Issue: Database Tables Missing

The 404 error means your Supabase database tables don't exist yet.

## 🔧 Quick Fix (2 minutes):

### Step 1: Go to Supabase Dashboard

- Open: https://mwfsytnixlcpterxqqnf.supabase.co
- Sign in to your account

### Step 2: Run the SQL Schema

1. Click **"SQL Editor"** in the left sidebar
2. Click **"New Query"**
3. Copy this entire SQL and paste it:

```sql
-- Create curriculum_years table
CREATE TABLE IF NOT EXISTS curriculum_years (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create curriculum_subjects table
CREATE TABLE IF NOT EXISTS curriculum_subjects (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create curriculum_strands table
CREATE TABLE IF NOT EXISTS curriculum_strands (
    id VARCHAR(50) PRIMARY KEY,
    subject_id VARCHAR(50) REFERENCES curriculum_subjects(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create curriculum_outcomes table
CREATE TABLE IF NOT EXISTS curriculum_outcomes (
    id VARCHAR(20) PRIMARY KEY,
    strand_id VARCHAR(50) REFERENCES curriculum_strands(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    description TEXT NOT NULL,
    elaboration TEXT,
    year_level VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE curriculum_years ENABLE ROW LEVEL SECURITY;
ALTER TABLE curriculum_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE curriculum_strands ENABLE ROW LEVEL SECURITY;
ALTER TABLE curriculum_outcomes ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access
CREATE POLICY "Allow public read access to curriculum_years" ON curriculum_years FOR SELECT USING (true);
CREATE POLICY "Allow public read access to curriculum_subjects" ON curriculum_subjects FOR SELECT USING (true);
CREATE POLICY "Allow public read access to curriculum_strands" ON curriculum_strands FOR SELECT USING (true);
CREATE POLICY "Allow public read access to curriculum_outcomes" ON curriculum_outcomes FOR SELECT USING (true);
```

4. Click **"Run"**

### Step 3: Test the Upload

1. Go back to your Flutter app
2. Click the cloud upload button
3. Click "Upload MRAC Data to Supabase"
4. Should work now! ✅

## 🎯 What This Creates:

- **Years**: Foundation to Year 10
- **Subjects**: English, Math, Science, HASS, Arts, Technologies, Health, Languages
- **Strands**: Subject-specific strands
- **Outcomes**: Individual curriculum outcomes with codes
- **Relationships**: Proper foreign key relationships
- **Security**: Public read access enabled

## 📊 Expected Results:

After upload, you'll have:

- 11 year levels
- 8 subjects
- 20+ strands
- 100+ curriculum outcomes
- Full search capabilities
