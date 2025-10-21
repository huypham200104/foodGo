@echo off
echo ========================================
echo    FoodGo Menu Import Script
echo ========================================
echo.

echo Installing dependencies...
flutter pub get

echo.
echo Running menu import script...
flutter run lib/scripts/import_menu_to_firebase.dart

echo.
echo Import process completed!
pause
