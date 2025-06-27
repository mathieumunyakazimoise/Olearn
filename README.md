# OLearn - E-Learning Mobile App

A comprehensive e-learning mobile application built with Flutter and Firebase, designed for marginalized youth to access quality education.

## Features

### For Students
- Browse and enroll in courses
- Watch video lessons
- Take quizzes and assessments
- Track learning progress
- Interactive discussions
- Offline content access

### For Instructors/Admins
- Create and manage courses
- Upload video content
- View analytics and student progress
- Manage student enrollments
- Course publishing controls

### Technical Features
- Firebase Authentication (Email/Password, Google Sign-in)
- Firestore Database for real-time data
- Firebase Storage for media files
- Multi-language support
- Cross-platform (iOS & Android)
- Modern, accessible UI

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android emulator or physical device
- Google account for Firebase setup

## Installation & Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd olearn
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

Follow the detailed Firebase setup guide in `FIREBASE_SETUP_GUIDE.md`:

1. Create a Firebase project
2. Add Android and iOS apps
3. Download configuration files
4. Enable Authentication and Firestore
5. Set up Storage
6. Configure security rules

### 4. Update Firebase Configuration

Replace the placeholder values in `lib/config/firebase_config.dart` with your actual Firebase configuration:

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

### 5. Generate Model Files

```bash
flutter packages pub run build_runner build
```

### 6. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices
flutter run -d <device-id>
```

## Project Structure

```
lib/
├── config/                 # Configuration files
│   ├── firebase_config.dart
│   └── supabase_config.dart
├── constants/              # App constants
│   └── app_constants.dart
├── l10n/                   # Localization files
│   ├── app_en.arb
│   ├── app_es.arb
│   └── ...
├── main.dart              # App entry point
├── models/                # Data models
│   ├── course_model.dart
│   ├── lesson_model.dart
│   └── user_model.dart
├── providers/             # State management
│   ├── locale_provider.dart
│   └── theme_provider.dart
├── screens/               # UI screens
│   ├── admin_dashboard_screen.dart
│   ├── course_creation_screen.dart
│   ├── courses_screen.dart
│   ├── home_screen.dart
│   ├── lesson_screen.dart
│   ├── login_screen.dart
│   └── ...
├── services/              # Business logic
│   ├── admin_service.dart
│   ├── auth_service.dart
│   ├── course_service.dart
│   ├── enrollment_service.dart
│   └── lesson_service.dart
├── theme/                 # App theming
│   └── app_theme.dart
├── utils/                 # Utility functions
└── widgets/               # Reusable widgets
    ├── custom_button.dart
    └── custom_text_field.dart
```

## Firebase Collections Structure

### Users Collection
```json
{
  "id": "user_id",
  "email": "user@example.com",
  "name": "User Name",
  "role": "student|instructor|admin",
  "photoUrl": "https://...",
  "bio": "User bio",
  "enrolledCourses": ["course_id1", "course_id2"],
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### Courses Collection
```json
{
  "id": "course_id",
  "title": "Course Title",
  "description": "Course description",
  "instructorId": "user_id",
  "instructorName": "Instructor Name",
  "thumbnailUrl": "https://...",
  "categories": ["Technology", "Programming"],
  "rating": 4.5,
  "totalStudents": 100,
  "totalLessons": 10,
  "totalDuration": 120,
  "prerequisites": ["Basic knowledge"],
  "learningObjectives": ["Learn Flutter"],
  "isPublished": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### Lessons Subcollection (under Courses)
```json
{
  "id": "lesson_id",
  "title": "Lesson Title",
  "description": "Lesson description",
  "content": "Lesson content",
  "videoUrl": "https://...",
  "duration": 15,
  "order": 1,
  "isPublished": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### Enrollments Collection
```json
{
  "id": "user_id_course_id",
  "userId": "user_id",
  "courseId": "course_id",
  "enrolledAt": "2024-01-01T00:00:00Z",
  "status": "active",
  "progress": 75.5,
  "lastAccessed": "2024-01-01T00:00:00Z"
}
```

### Progress Collection
```json
{
  "id": "user_id_course_id",
  "userId": "user_id",
  "courseId": "course_id",
  "completedLessons": ["lesson_id1", "lesson_id2"],
  "lastAccessed": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

## Key Features Implementation

### Authentication
- Email/password registration and login
- Google Sign-in integration
- Password reset functionality
- User profile management

### Course Management
- Create, edit, and delete courses
- Upload course thumbnails
- Manage course content and lessons
- Publish/unpublish courses
- Course analytics and insights

### Student Experience
- Browse available courses
- Enroll in courses
- Watch video lessons
- Track learning progress
- Complete assessments

### Admin Features
- User management (promote/demote roles)
- Course approval and moderation
- Platform analytics
- System settings

## Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## Building for Production

### Android
```bash
# Generate signed APK
flutter build apk --release

# Generate App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS
flutter build ios --release
```

## Deployment

### Android
1. Generate signed APK/App Bundle
2. Upload to Google Play Console
3. Configure app signing
4. Submit for review

### iOS
1. Build iOS app
2. Archive in Xcode
3. Upload to App Store Connect
4. Submit for review

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Troubleshooting

### Common Issues

1. **Firebase Configuration Error**
   - Ensure `google-services.json` is in `android/app/`
   - Verify Firebase configuration values
   - Check SHA-1 fingerprint

2. **Build Errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check Flutter and Dart versions

3. **Authentication Issues**
   - Verify Firebase Authentication is enabled
   - Check Google Sign-in configuration
   - Ensure proper SHA-1 fingerprint

4. **Storage Upload Failures**
   - Check Firebase Storage rules
   - Verify file size limits
   - Ensure proper permissions

## Support

For support and questions:
- Create an issue in the repository
- Check the Firebase documentation
- Review Flutter documentation

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- The open-source community for various packages
