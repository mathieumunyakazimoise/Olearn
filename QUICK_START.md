# Quick Start Guide - OLearn E-Learning App

This guide will help you get the OLearn app running quickly for testing purposes.

## Prerequisites

- Flutter SDK (3.0.0+)
- Android Studio / VS Code
- Android emulator or physical device
- Google account

## Step 1: Clone and Setup

```bash
# Clone the repository (if not already done)
git clone <repository-url>
cd olearn

# Run the setup script
./setup.sh
```

## Step 2: Firebase Setup (Quick Version)

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Create a project"
   - Name it "olearn-app" (or your preferred name)
   - Enable Google Analytics (optional)

2. **Add Android App**
   - Click the Android icon (</>) in Firebase Console
   - Package name: `com.example.olearn`
   - App nickname: `OLearn`
   - Download `google-services.json`
   - Place it in `android/app/` directory

3. **Enable Authentication**
   - Go to Authentication → Sign-in method
   - Enable Email/Password
   - Enable Google Sign-in

4. **Create Firestore Database**
   - Go to Firestore Database
   - Click "Create database"
   - Choose "Start in test mode"
   - Select a location close to you

5. **Set up Storage**
   - Go to Storage
   - Click "Get started"
   - Choose "Start in test mode"
   - Select a location close to you

## Step 3: Update Configuration

1. **Get Firebase Config**
   - In Firebase Console, go to Project Settings (gear icon)
   - Scroll to "Your apps" section
   - Copy the configuration values

2. **Update Firebase Config**
   - Open `lib/config/firebase_config.dart`
   - Replace placeholder values with your actual Firebase config:

```dart
static Future<void> initialize() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'YOUR_ACTUAL_API_KEY',
      appId: 'YOUR_ACTUAL_APP_ID',
      messagingSenderId: 'YOUR_ACTUAL_MESSAGING_SENDER_ID',
      projectId: 'YOUR_ACTUAL_PROJECT_ID',
      storageBucket: 'YOUR_ACTUAL_STORAGE_BUCKET',
    ),
  );
}
```

## Step 4: Run the App

```bash
# Check available devices
flutter devices

# Run on Android emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# Run on iOS (if on Mac)
flutter run -d ios
```

## Step 5: Test the App

### First Time Setup
1. The app will start with the login screen
2. Create a new account or sign in with Google
3. You'll be redirected to the home screen

### Create Admin User (Optional)
To access admin features, you need to manually set a user as admin in Firebase:

1. Go to Firebase Console → Firestore Database
2. Find the `users` collection
3. Find your user document
4. Add a field: `role: "admin"`
5. Save the document

### Test Features
- **Authentication**: Try signing up, signing in, and signing out
- **Course Browsing**: View available courses (if any)
- **Profile**: Update your profile information
- **Admin Dashboard**: Access admin features (if you're an admin)

## Troubleshooting

### Common Issues

1. **"Firebase not initialized" error**
   - Check that `google-services.json` is in `android/app/`
   - Verify Firebase config values are correct
   - Run `flutter clean` and `flutter pub get`

2. **"Permission denied" errors**
   - Firebase is in test mode, so permissions should work
   - Check that Authentication is enabled in Firebase Console

3. **App crashes on startup**
   - Check Flutter doctor: `flutter doctor`
   - Ensure all dependencies are installed: `flutter pub get`
   - Check device compatibility

4. **Google Sign-in not working**
   - Add SHA-1 fingerprint to Firebase Console
   - For debug: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`

### Debug Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check for issues
flutter doctor -v
flutter analyze

# Regenerate models
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Next Steps

Once the basic app is running:

1. **Add Sample Data**: Create some test courses and lessons
2. **Test Admin Features**: Create admin users and test course management
3. **Test Student Features**: Enroll in courses and track progress
4. **Customize**: Modify the UI, add new features, or integrate additional services

## Support

If you encounter issues:

1. Check the main README.md for detailed setup instructions
2. Review the FIREBASE_SETUP_GUIDE.md for comprehensive Firebase setup
3. Check Flutter and Firebase documentation
4. Create an issue in the repository

## Production Considerations

For production deployment:

1. **Security Rules**: Update Firestore and Storage security rules
2. **Authentication**: Configure proper authentication providers
3. **Monitoring**: Enable Firebase Analytics and Crashlytics
4. **Backup**: Set up automated backups
5. **Testing**: Run comprehensive tests before deployment

---

🎉 **Congratulations!** Your OLearn e-learning app is now running locally. You can start developing and testing features immediately. 