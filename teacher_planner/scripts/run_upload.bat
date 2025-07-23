@echo off
echo 🚀 Running Australian Curriculum Data Upload...
echo.

cd /d "%~dp0"

echo 📦 Installing dependencies...
dart pub get

echo.
echo 📚 Uploading curriculum data to Supabase...
dart upload_curriculum_data.dart

echo.
echo ✅ Upload complete! Press any key to exit...
pause >nul 