@echo off
echo ========================================
echo TEACHER PLANNER - RESTORE FROM BACKUP
echo ========================================
echo.

:: Check if backup folder is provided
if "%1"=="" (
    echo Usage: restore_from_backup.bat [backup_folder_name]
    echo.
    echo Available backups:
    dir /B teacher_planner_backup_* 2>nul
    echo.
    pause
    exit /b 1
)

set "BACKUP_DIR=%1"

:: Check if backup exists
if not exist "%BACKUP_DIR%" (
    echo ❌ ERROR: Backup folder '%BACKUP_DIR%' not found!
    echo.
    echo Available backups:
    dir /B teacher_planner_backup_* 2>nul
    echo.
    pause
    exit /b 1
)

echo This will restore your project from backup: %BACKUP_DIR%
echo ⚠️  WARNING: This will OVERWRITE your current project!
echo.
set /p confirm="Are you sure you want to restore? (y/N): "
if /i not "%confirm%"=="y" (
    echo Restore cancelled.
    pause
    exit /b 0
)

echo.
echo Starting restore...
echo.

:: Exclude the backup folders themselves when copying back
echo 📁 Restoring files from backup...
xcopy /E /I /H /Y "%BACKUP_DIR%\*" "." /EXCLUDE:backup_exclude.txt > nul 2>&1

:: Create exclusion file temporarily
echo teacher_planner_backup_* > backup_exclude.txt

:: Copy everything except other backup folders
for /f %%i in ('dir /B "%BACKUP_DIR%"') do (
    if not "%%i"=="teacher_planner_backup_*" (
        xcopy /E /I /H /Y "%BACKUP_DIR%\%%i" "%%i" > nul 2>&1
    )
)

:: Clean up temp file
del backup_exclude.txt 2>nul

if %ERRORLEVEL% EQU 0 (
    echo ✅ RESTORE SUCCESSFUL!
    echo.
    echo Your project has been restored from backup.
    echo You can now test the app to make sure everything works.
    echo.
    echo To test the restore:
    echo   1. Run: flutter clean
    echo   2. Run: flutter pub get
    echo   3. Run: flutter run --debug
) else (
    echo ❌ RESTORE FAILED!
    echo Please check permissions and try again.
)

echo.
pause 