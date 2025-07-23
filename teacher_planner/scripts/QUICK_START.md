# 🚀 Quick Start - Upload Curriculum Data

## The Issue

The script detected that your Supabase database tables don't exist yet. This is normal for a new setup.

## ✅ Solution (2 minutes)

### Step 1: Create Database Tables

1. **Go to your Supabase dashboard:**

   - Open: https://mwfsytnixlcpterxqqnf.supabase.co
   - Sign in to your account

2. **Run the SQL schema:**
   - Click **"SQL Editor"** in the left sidebar
   - Click **"New Query"**
   - Copy and paste this SQL:

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

3. **Click "Run"** to execute the SQL

### Step 2: Run the Upload Script

1. **In this terminal, run:**

   ```bash
   dart simple_upload.dart
   ```

2. **Expected output:**
   ```
   🚀 Starting Australian Curriculum data upload...
   🔍 Testing table existence...
   ✅ All required tables exist
   🧹 Clearing existing curriculum data...
   ✅ Existing data cleared
   📚 Uploading structured curriculum data...
   📅 Uploading years...
   ✅ Years uploaded: 11
   📖 Uploading subjects...
   ✅ Subjects uploaded: 8
   🔗 Uploading strands...
   ✅ Strands uploaded: 24
   🎯 Uploading outcomes...
   ✅ Outcomes uploaded: 10
   ✅ Curriculum data upload completed successfully!
   ```

## 🎯 What This Creates

- **11 Year levels** (Foundation to Year 10)
- **8 Subjects** (English, Math, Science, HASS, Arts, Technologies, Health, Languages)
- **24 Strands** across all subjects
- **10+ Curriculum outcomes** with codes and descriptions
- **Full database relationships** and search capabilities

## 🔄 Alternative: Use the App

Once the data is uploaded, you can also use the Flutter app:

1. Run `flutter run` in the main project directory
2. Use the curriculum sidebar to browse the uploaded data
3. No need to manually upload from the app anymore!

## 🆘 Troubleshooting

- **404 Error**: Tables don't exist - run the SQL schema first
- **Permission Error**: Check your Supabase API key
- **Connection Error**: Check your internet connection
