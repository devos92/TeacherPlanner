@echo off
echo ========================================
echo TEACHER PLANNER - BACKUP BEFORE CLEANUP
echo ========================================
echo.

:: Get current date and time for backup folder
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "MIN=%dt:~10,2%" & set "SS=%dt:~12,2%"
set "BACKUP_TIMESTAMP=%YYYY%-%MM%-%DD%_%HH%-%MIN%-%SS%"

:: Create backup directory
set "BACKUP_DIR=teacher_planner_backup_%BACKUP_TIMESTAMP%"
echo Creating backup in: %BACKUP_DIR%
echo.

:: Copy entire project to backup
xcopy /E /I /H /Y "." "%BACKUP_DIR%" > nul 2>&1

if %ERRORLEVEL% EQU 0 (
    echo ✅ BACKUP SUCCESSFUL!
    echo Backup location: %CD%\%BACKUP_DIR%
    echo.
    echo Your project has been safely backed up.
    echo You can now run the cleanup script: cleanup_project.bat
    echo.
    echo If anything breaks, run: restore_from_backup.bat %BACKUP_DIR%
) else (
    echo ❌ BACKUP FAILED!
    echo Please check permissions and try again.
)

echo.
pause 