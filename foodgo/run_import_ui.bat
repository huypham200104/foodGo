@echo off
echo ========================================
echo    FoodGo Menu Import UI
echo ========================================
echo.

echo Installing dependencies...
flutter pub get

echo.
echo Starting import UI...
flutter run lib/main_import.dart -d windows

echo.
echo Import UI completed!
pause
