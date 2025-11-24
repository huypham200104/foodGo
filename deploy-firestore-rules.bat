@echo off
echo Deploying Firestore Security Rules...
echo.

REM Check if Firebase CLI is installed
firebase --version > nul 2>&1
if errorlevel 1 (
    echo Firebase CLI is not installed. Please install it first:
    echo npm install -g firebase-tools
    echo.
    pause
    exit /b 1
)

REM Login to Firebase if not already logged in
echo Checking Firebase authentication...
firebase projects:list > nul 2>&1
if errorlevel 1 (
    echo Please login to Firebase first:
    firebase login
    if errorlevel 1 (
        echo Failed to login to Firebase
        pause
        exit /b 1
    )
)

REM Deploy Firestore rules
echo Deploying Firestore Security Rules...
firebase deploy --only firestore:rules

if errorlevel 1 (
    echo Failed to deploy Firestore rules
    echo Please check your Firebase project configuration
    pause
    exit /b 1
) else (
    echo.
    echo Firestore Security Rules deployed successfully!
    echo.
)

pause