# Teacher Planner Setup Script
# This script helps you set up the environment for the Teacher Planner app

Write-Host "🎓 Teacher Planner Setup" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

# Check if .env file exists
if (Test-Path ".env") {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
} else {
    Write-Host "📝 Creating .env file from template..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✅ .env file created" -ForegroundColor Green
    Write-Host "⚠️  Please edit .env file with your Supabase credentials" -ForegroundColor Yellow
}

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version
    Write-Host "✅ Flutter is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter from https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

# Get dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
flutter pub get

# Check if .env has been configured
$envContent = Get-Content ".env" -ErrorAction SilentlyContinue
if ($envContent -and ($envContent -match "your_supabase_project_url_here" -or $envContent -match "your_supabase_anon_key_here")) {
    Write-Host "⚠️  WARNING: .env file still contains placeholder values!" -ForegroundColor Red
    Write-Host "Please update your .env file with actual Supabase credentials:" -ForegroundColor Yellow
    Write-Host "1. Go to your Supabase Dashboard" -ForegroundColor Cyan
    Write-Host "2. Navigate to Settings → API" -ForegroundColor Cyan
    Write-Host "3. Copy the Project URL and anon public key" -ForegroundColor Cyan
    Write-Host "4. Update the .env file with these values" -ForegroundColor Cyan
} else {
    Write-Host "✅ .env file appears to be configured" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Configure your .env file with Supabase credentials" -ForegroundColor White
Write-Host "2. Run the database schema scripts in your Supabase SQL editor" -ForegroundColor White
Write-Host "3. Run 'flutter run' to start the application" -ForegroundColor White
Write-Host ""
Write-Host "For more information, see README.md" -ForegroundColor Cyan 