# Supabase Database Setup Guide

## Step 1: Access Your Supabase Dashboard

1. Go to: https://mwfsytnixlcpterxqqnf.supabase.co
2. Sign in to your Supabase account
3. Navigate to your project

## Step 2: Create the Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Click **"New Query"**
3. Copy and paste the entire contents of `supabase_schema.sql`
4. Click **"Run"** to execute the SQL

## Step 3: Verify Tables Created

1. Go to **Table Editor** in your Supabase dashboard
2. You should see these tables:
   - `curriculum_years`
   - `curriculum_subjects`
   - `curriculum_strands`
   - `curriculum_outcomes`
   - `curriculum_full_view` (view)

## Step 4: Test the MRAC Upload

1. Run the Flutter app: `flutter run`
2. Navigate to the MRAC upload page
3. Click "Upload MRAC Data to Supabase"
4. Check the console for success messages

## Troubleshooting

If you get a 404 error:

- Make sure you've run the SQL schema
- Check that your Supabase URL and key are correct in `lib/config/supabase_config.dart`
- Verify the tables exist in the Table Editor

## Database Structure

The schema creates:

- **Years**: Foundation to Year 10
- **Subjects**: English, Math, Science, HASS, Arts, Technologies, Health, Languages
- **Strands**: Subject-specific strands (e.g., Language, Literature, Literacy for English)
- **Outcomes**: Individual curriculum outcomes with codes and descriptions
- **Relationships**: Proper foreign key relationships between all tables
- **Search**: Full-text search capabilities on outcomes
- **Security**: Row Level Security with public read access
