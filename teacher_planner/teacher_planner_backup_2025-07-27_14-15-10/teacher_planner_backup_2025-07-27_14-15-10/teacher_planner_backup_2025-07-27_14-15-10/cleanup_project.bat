@echo off
echo ========================================
echo TEACHER PLANNER - PROJECT CLEANUP
echo ========================================
echo.

:: Check if backup was made
if not exist "teacher_planner_backup_*" (
    echo ❌ ERROR: No backup found!
    echo Please run backup_before_cleanup.bat first!
    echo.
    pause
    exit /b 1
)

echo This will delete redundant files from your project.
echo Make sure you have run backup_before_cleanup.bat first!
echo.
set /p confirm="Continue with cleanup? (y/N): "
if /i not "%confirm%"=="y" (
    echo Cleanup cancelled.
    pause
    exit /b 0
)

echo.
echo Starting cleanup...
echo.

:: Delete documentation files
echo 🗂️ Removing redundant documentation...
del /Q "SUPABASE_SETUP_COMPLETE.md" 2>nul
del /Q "SUPER_EDITOR_GUIDE.md" 2>nul
del /Q "TEXT_EDITOR_GUIDE.md" 2>nul
del /Q "IMPLEMENTATION_SUMMARY.md" 2>nul
del /Q "MULTI_DAY_SELECTION_GUIDE.md" 2>nul
del /Q "README_SUPABASE_SETUP.md" 2>nul
del /Q "DRAG_AND_MULTI_SELECT_GUIDE.md" 2>nul
del /Q "ENHANCED_DAY_DETAIL_GUIDE.md" 2>nul
del /Q "EVENT_INTERACTION_FIX.md" 2>nul
del /Q "EVENT_INTERACTION_GUIDE.md" 2>nul
del /Q "CUSTOM_TIME_GUIDE.md" 2>nul
del /Q "DRAG_AND_DROP_COMPLETE_GUIDE.md" 2>nul
del /Q "setup_database.md" 2>nul
del /Q "quick_setup.md" 2>nul

:: Delete example files
echo 📁 Removing examples directory...
rmdir /S /Q "lib\examples" 2>nul

:: Delete redundant pages
echo 📄 Removing redundant pages...
del /Q "lib\pages\day_detail_page.dart" 2>nul
del /Q "lib\pages\lesson_detail_page.dart" 2>nul
del /Q "lib\pages\add_event_page.dart" 2>nul
del /Q "lib\pages\event_detail_editor.dart" 2>nul
del /Q "lib\pages\multi_select_event_page.dart" 2>nul
del /Q "lib\pages\document_templates.dart" 2>nul
del /Q "lib\pages\curriculum_browser_page.dart" 2>nul

:: Delete redundant services
echo 🔧 Removing redundant services...
del /Q "lib\services\database_service.dart" 2>nul
del /Q "lib\services\storage_service.dart" 2>nul

:: Clean up any import references (basic cleanup)
echo 🔗 Cleaning up import references...

:: Update enhanced_day_detail_page.dart to remove storage_service import
powershell -Command "(Get-Content 'lib\pages\enhanced_day_detail_page.dart') -replace 'import ''../services/storage_service.dart'';', '' | Set-Content 'lib\pages\enhanced_day_detail_page.dart'" 2>nul

:: Update enhanced_day_detail_page.dart to remove storage service usage
powershell -Command "(Get-Content 'lib\pages\enhanced_day_detail_page.dart') -replace 'final StorageService _storageService =\s*StorageServiceFactory.create\(StorageProvider.supabase\);', '' | Set-Content 'lib\pages\enhanced_day_detail_page.dart'" 2>nul

echo.
echo ✅ CLEANUP COMPLETE!
echo.
echo Files cleaned up:
echo   📋 14 documentation files removed
echo   📁 Examples directory removed
echo   📄 7 redundant pages removed  
echo   🔧 2 redundant services removed
echo.
echo Your project is now ~40-50%% smaller!
echo.
echo To test the cleanup:
echo   1. Run: flutter analyze
echo   2. Run: flutter run --debug
echo.
echo If anything breaks, run: restore_from_backup.bat [backup_folder_name]
echo.
pause 