# Firebase Setup Guide for OLearn E-Learning App

## Prerequisites
- Google account
- Flutter SDK installed
- Android Studio / VS Code
- Android emulator or physical device

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `olearn-app` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Choose Analytics account or create new one
6. Click "Create project"

## Step 2: Add Android App to Firebase

1. In Firebase Console, click the Android icon (</>) to add Android app
2. Enter Android package name: `com.example.olearn`
3. Enter app nickname: `OLearn`
4. Enter SHA-1 certificate fingerprint (optional for now)
5. Click "Register app"
6. Download `google-services.json` file
7. Place `google-services.json` in `android/app/` directory

## Step 3: Add iOS App to Firebase (Optional)

1. In Firebase Console, click the iOS icon to add iOS app
2. Enter iOS bundle ID: `com.example.olearn`
3. Enter app nickname: `OLearn`
4. Click "Register app"
5. Download `GoogleService-Info.plist` file
6. Place `GoogleService-Info.plist` in `ios/Runner/` directory

## Step 4: Enable Authentication

1. In Firebase Console, go to "Authentication" → "Sign-in method"
2. Enable the following providers:
   - Email/Password
   - Google Sign-in
3. For Google Sign-in, add your support email

## Step 5: Set up Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Click "Done"

## Step 6: Set up Storage

1. In Firebase Console, go to "Storage"
2. Click "Get started"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Click "Done"

## Step 7: Configure Security Rules

### Firestore Security Rules
Go to Firestore Database → Rules and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read published courses
    match /courses/{courseId} {
      allow read: if resource.data.isPublished == true;
      allow write: if request.auth != null && 
        (request.auth.uid == resource.data.instructorId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Anyone can read published lessons
    match /courses/{courseId}/lessons/{lessonId} {
      allow read: if get(/databases/$(database)/documents/courses/$(courseId)).data.isPublished == true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/courses/$(courseId)).data.instructorId == request.auth.uid;
    }
    
    // Users can read/write their own enrollments
    match /enrollments/{enrollmentId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Users can read/write their own progress
    match /progress/{progressId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### Storage Security Rules
Go to Storage → Rules and replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Course thumbnails - anyone can read, instructors can upload
    match /courses/{courseId}/thumbnail/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && 
        firestore.get(/databases/(default)/documents/courses/$(courseId)).data.instructorId == request.auth.uid;
    }
    
    // Course content - enrolled students and instructors can access
    match /courses/{courseId}/content/{fileName} {
      allow read: if request.auth != null && 
        (firestore.get(/databases/(default)/documents/courses/$(courseId)).data.instructorId == request.auth.uid ||
         firestore.get(/databases/(default)/documents/enrollments/$(request.auth.uid + '_' + courseId)).data != null);
      allow write: if request.auth != null && 
        firestore.get(/databases/(default)/documents/courses/$(courseId)).data.instructorId == request.auth.uid;
    }
    
    // User profile pictures - users can manage their own
    match /users/{userId}/profile/{fileName} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 8: Update Firebase Configuration

1. In Firebase Console, go to Project Settings (gear icon)
2. Scroll down to "Your apps" section
3. Copy the configuration values
4. Update `lib/config/firebase_config.dart` with your actual values

## Step 9: Install Firebase CLI (Optional but Recommended)

```bash
npm install -g firebase-tools
firebase login
firebase init
```

## Step 10: Test Setup

1. Run the app: `flutter run`
2. Test authentication flow
3. Test course creation (if admin)
4. Test course enrollment (if student)

## Troubleshooting

### Common Issues:

1. **SHA-1 Certificate Fingerprint Error**
   - For debug: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
   - Add the SHA-1 to Firebase Console

2. **Google Sign-in Not Working**
   - Ensure Google Sign-in is enabled in Firebase Console
   - Check that `google-services.json` is in the correct location
   - Verify SHA-1 fingerprint is added to Firebase Console

3. **Firestore Permission Denied**
   - Check security rules
   - Ensure user is authenticated
   - Verify document structure matches rules

4. **Storage Upload Fails**
   - Check storage security rules
   - Ensure file size is within limits
   - Verify user has proper permissions

## Production Considerations

1. **Security Rules**: Update rules for production
2. **Authentication**: Add additional providers as needed
3. **Backup**: Set up automated backups
4. **Monitoring**: Enable Firebase Analytics and Crashlytics
5. **Performance**: Use Firebase Performance Monitoring

## Next Steps

After setup, you can:
1. Create admin users
2. Upload course content
3. Test student enrollment
4. Monitor usage in Firebase Console 