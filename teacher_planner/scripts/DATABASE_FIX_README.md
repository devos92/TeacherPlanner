# Database Field Length Fix for MRAC Data

## Problem

The MRAC (Australian Curriculum) data upload was failing with errors like:

```
HTTP POST failed: 400 - {"code":"22001","details":null,"hint":null,"message":"value too long for type character varying(100)"}
HTTP POST failed: 400 - {"code":"22001","details":null,"hint":null,"message":"value too long for type character varying(20)"}
```

This happened because the database schema had field length limitations that were too small for the MRAC data:

- `id VARCHAR(20)` - but MRAC IDs are long URLs
- `name VARCHAR(100)` - but some names are longer
- `code VARCHAR(20)` - but some codes are longer

## Solution

### Step 1: Update Database Schema

The database schema has been updated to accommodate longer field lengths:

**Updated field lengths:**

- `id`: VARCHAR(20) → VARCHAR(255)
- `name`: VARCHAR(100) → VARCHAR(255)
- `code`: VARCHAR(20) → VARCHAR(100)
- `year_level`: VARCHAR(20) → VARCHAR(50)

### Step 2: Run Migration

You need to apply the schema changes to your Supabase database:

#### Option A: Using Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy and paste the contents of `migrate_schema.sql`
4. Run the migration script

#### Option B: Using Supabase CLI

```bash
supabase db reset
# Then apply the new schema
```

### Step 3: Run the Upload Script

After the migration is complete, run the upload script:

```bash
cd scripts
dart download_and_upload_mrac.dart
```

## Files Modified

1. **`supabase_schema.sql`** - Updated with longer field lengths
2. **`scripts/migrate_schema.sql`** - Migration script to update existing database
3. **`scripts/download_and_upload_mrac.dart`** - Improved error handling and data extraction
4. **`scripts/run_migration_and_upload.bat`** - Batch script to run both steps

## Improvements Made

### Better Data Extraction

- Added fallback field extraction for JSON-LD format
- Added length validation and truncation
- Improved year level detection
- Better error handling with detailed logging

### Enhanced Error Handling

- Progress indicators during upload
- Limited error message spam
- Better error categorization
- Detailed logging for debugging

### Data Validation

- Truncates long fields to fit database constraints
- Validates data before upload
- Handles missing or malformed data gracefully

## Testing the Fix

After running the migration and upload:

1. Check your Supabase dashboard to verify data was uploaded
2. Query the `curriculum_full_view` to see the imported data
3. Test the Flutter app to ensure curriculum data is accessible

## Troubleshooting

If you still encounter issues:

1. **Check field lengths**: Ensure no data exceeds the new field limits
2. **Verify migration**: Confirm the schema was updated correctly
3. **Check permissions**: Ensure RLS policies allow data insertion
4. **Review logs**: Check the detailed error messages for specific issues

## Notes

- The migration will delete existing curriculum data
- Make sure to backup any important data before running the migration
- The new schema can handle much longer URLs and text content
- Error handling has been improved to provide better debugging information
