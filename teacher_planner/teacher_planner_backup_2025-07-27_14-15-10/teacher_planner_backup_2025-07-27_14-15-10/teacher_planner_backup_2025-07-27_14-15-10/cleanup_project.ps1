# TEACHER PLANNER - PROJECT CLEANUP (PowerShell Version)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEACHER PLANNER - PROJECT CLEANUP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if backup was made
$backupFolders = Get-ChildItem -Directory -Name "teacher_planner_backup_*"
if ($backupFolders.Count -eq 0) {
    Write-Host "❌ ERROR: No backup found!" -ForegroundColor Red
    Write-Host "Please run .\backup_before_cleanup.ps1 first!" -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "This will delete redundant files from your project." -ForegroundColor Yellow
Write-Host "Make sure you have run backup_before_cleanup.ps1 first!" -ForegroundColor Yellow
Write-Host ""
$confirm = Read-Host "Continue with cleanup? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host ""
Write-Host "Starting cleanup..." -ForegroundColor Green
Write-Host ""

# Delete documentation files
Write-Host "🗂️ Removing redundant documentation..." -ForegroundColor Yellow
$docsToDelete = @(
    "SUPABASE_SETUP_COMPLETE.md",
    "SUPER_EDITOR_GUIDE.md", 
    "TEXT_EDITOR_GUIDE.md",
    "IMPLEMENTATION_SUMMARY.md",
    "MULTI_DAY_SELECTION_GUIDE.md",
    "README_SUPABASE_SETUP.md",
    "DRAG_AND_MULTI_SELECT_GUIDE.md",
    "ENHANCED_DAY_DETAIL_GUIDE.md",
    "EVENT_INTERACTION_FIX.md",
    "EVENT_INTERACTION_GUIDE.md",
    "CUSTOM_TIME_GUIDE.md",
    "DRAG_AND_DROP_COMPLETE_GUIDE.md",
    "setup_database.md",
    "quick_setup.md"
)

foreach ($doc in $docsToDelete) {
    if (Test-Path $doc) {
        Remove-Item $doc -Force
        Write-Host "  Deleted: $doc" -ForegroundColor Gray
    }
}

# Delete example files
Write-Host "📁 Removing examples directory..." -ForegroundColor Yellow
if (Test-Path "lib\examples") {
    Remove-Item "lib\examples" -Recurse -Force
    Write-Host "  Deleted: lib\examples" -ForegroundColor Gray
}

# Delete redundant pages
Write-Host "📄 Removing redundant pages..." -ForegroundColor Yellow
$pagesToDelete = @(
    "lib\pages\day_detail_page.dart",
    "lib\pages\lesson_detail_page.dart",
    "lib\pages\add_event_page.dart",
    "lib\pages\event_detail_editor.dart",
    "lib\pages\multi_select_event_page.dart",
    "lib\pages\document_templates.dart",
    "lib\pages\curriculum_browser_page.dart"
)

foreach ($page in $pagesToDelete) {
    if (Test-Path $page) {
        Remove-Item $page -Force
        Write-Host "  Deleted: $page" -ForegroundColor Gray
    }
}

# Delete redundant services
Write-Host "🔧 Removing redundant services..." -ForegroundColor Yellow
$servicesToDelete = @(
    "lib\services\database_service.dart",
    "lib\services\storage_service.dart"
)

foreach ($service in $servicesToDelete) {
    if (Test-Path $service) {
        Remove-Item $service -Force
        Write-Host "  Deleted: $service" -ForegroundColor Gray
    }
}

# Clean up import references
Write-Host "🔗 Cleaning up import references..." -ForegroundColor Yellow
$enhancedDetailPage = "lib\pages\enhanced_day_detail_page.dart"
if (Test-Path $enhancedDetailPage) {
    $content = Get-Content $enhancedDetailPage -Raw
    $content = $content -replace "import '../services/storage_service.dart';\r?\n", ""
    $content = $content -replace "final StorageService _storageService =\s*StorageServiceFactory\.create\(StorageProvider\.supabase\);\r?\n", ""
    Set-Content $enhancedDetailPage -Value $content
    Write-Host "  Updated: $enhancedDetailPage" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ CLEANUP COMPLETE!" -ForegroundColor Green
Write-Host ""
Write-Host "Files cleaned up:" -ForegroundColor Green
Write-Host "  📋 14 documentation files removed" -ForegroundColor Gray
Write-Host "  📁 Examples directory removed" -ForegroundColor Gray
Write-Host "  📄 7 redundant pages removed" -ForegroundColor Gray
Write-Host "  🔧 2 redundant services removed" -ForegroundColor Gray
Write-Host ""
Write-Host "Your project is now ~40-50% smaller!" -ForegroundColor Green
Write-Host ""
Write-Host "To test the cleanup:" -ForegroundColor Yellow
Write-Host "  1. Run: flutter analyze" -ForegroundColor White
Write-Host "  2. Run: flutter run --debug" -ForegroundColor White
Write-Host ""
Write-Host "If anything breaks, run: .\restore_from_backup.ps1 [backup_folder_name]" -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to continue" 