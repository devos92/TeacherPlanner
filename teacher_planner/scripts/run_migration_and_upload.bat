@echo off
echo ========================================
echo Teacher Planner - Database Migration
echo ========================================
echo.

echo Step 1: Running database migration...
echo This will update the database schema to handle longer field lengths.
echo.

REM You'll need to run this migration in your Supabase dashboard
REM or use the Supabase CLI if you have it installed
echo Please run the migration script 'migrate_schema.sql' in your Supabase dashboard
echo or use the Supabase CLI to apply the schema changes.
echo.
echo The migration script is located at: scripts/migrate_schema.sql
echo.

pause

echo.
echo Step 2: Running MRAC data upload...
echo.

cd /d "%~dp0"
dart download_and_upload_mrac.dart

echo.
echo ========================================
echo Process completed!
echo ========================================
pause 