# TEACHER PLANNER - BACKUP BEFORE CLEANUP (PowerShell Version)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEACHER PLANNER - BACKUP BEFORE CLEANUP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get current date and time for backup folder
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupDir = "teacher_planner_backup_$timestamp"

Write-Host "Creating backup in: $backupDir" -ForegroundColor Yellow
Write-Host ""

try {
    # Copy entire project to backup (exclude the backup folder itself)
    Copy-Item -Path "." -Destination $backupDir -Recurse -Force -Exclude "teacher_planner_backup_*"
    
    Write-Host "✅ BACKUP SUCCESSFUL!" -ForegroundColor Green
    Write-Host "Backup location: $PWD\$backupDir" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your project has been safely backed up." -ForegroundColor Green
    Write-Host "You can now run the cleanup script: .\cleanup_project.ps1" -ForegroundColor Green
    Write-Host ""
    Write-Host "If anything breaks, run: .\restore_from_backup.ps1 $backupDir" -ForegroundColor Yellow
}
catch {
    Write-Host "❌ BACKUP FAILED!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check permissions and try again." -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to continue" 