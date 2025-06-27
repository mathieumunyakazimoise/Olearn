#!/bin/bash

# OLearn E-Learning App Setup Script
# This script helps set up the development environment for the OLearn app

echo "Welcome to OLearn E-Learning App Setup!"
echo "=========================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Flutter is not installed. Please install Flutter first:"
    echo "https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "Flutter is installed"
flutter --version

# Check Flutter doctor
echo ""
echo "Running Flutter doctor..."
flutter doctor

# Get dependencies
echo ""
echo "Installing dependencies..."
flutter pub get

# Generate model files
echo ""
echo "Generating model files..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo ""
    echo "Firebase CLI is not installed. Installing..."
    npm install -g firebase-tools
fi

echo ""
echo "Setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Follow the Firebase setup guide in FIREBASE_SETUP_GUIDE.md"
echo "2. Update Firebase configuration in lib/config/firebase_config.dart"
echo "3. Run 'flutter run' to start the app"
echo ""
echo "Useful commands:"
echo "   flutter run                    - Run the app"
echo "   flutter test                   - Run tests"
echo "   flutter build apk --release    - Build Android APK"
echo "   flutter build ios --release    - Build iOS app"
echo "   flutter packages pub run build_runner build --delete-conflicting-outputs - Regenerate models"
echo ""
echo "Happy coding!" 