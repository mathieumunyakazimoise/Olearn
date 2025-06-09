class AppConstants {
  // Routes
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String onboardingRoute = '/onboarding';
  static const String homeRoute = '/home';
  static const String coursesRoute = '/courses';
  static const String lessonRoute = '/lesson';
  static const String quizRoute = '/quiz';
  static const String downloadsRoute = '/downloads';
  static const String sharingRoute = '/sharing';
  static const String progressRoute = '/progress';
  static const String settingsRoute = '/settings';
  static const String profileRoute = '/profile';

  // Placeholder Data
  static const List<Map<String, dynamic>> sampleCourses = [
    {
      'id': '1',
      'title': 'Mathematics Basics',
      'description': 'Learn fundamental mathematical concepts',
      'category': 'Text',
      'duration': '2 hours',
      'progress': 0.0,
    },
    {
      'id': '2',
      'title': 'Science Experiments',
      'description': 'Interactive science experiments and demonstrations',
      'category': 'Video',
      'duration': '1.5 hours',
      'progress': 0.0,
    },
    {
      'id': '3',
      'title': 'Language Learning',
      'description': 'Basic language skills and vocabulary',
      'category': 'Audio',
      'duration': '3 hours',
      'progress': 0.0,
    },
    {
      'id': '4',
      'title': 'Digital Literacy',
      'description': 'Essential computer and internet skills',
      'category': 'Text',
      'duration': '2.5 hours',
      'progress': 0.0,
    },
    {
      'id': '5',
      'title': 'Agricultural Practices',
      'description': 'Modern and traditional farming techniques',
      'category': 'Video',
      'duration': '2 hours',
      'progress': 0.0,
    },
    {
      'id': '6',
      'title': 'Health & Hygiene',
      'description': 'Personal and community health tips',
      'category': 'Audio',
      'duration': '1 hour',
      'progress': 0.0,
    },
    {
      'id': '7',
      'title': 'Financial Literacy',
      'description': 'Managing money and basic finance',
      'category': 'Interactive',
      'duration': '1.5 hours',
      'progress': 0.0,
    },
    {
      'id': '8',
      'title': 'Environmental Awareness',
      'description': 'Protecting our environment',
      'category': 'Text',
      'duration': '1 hour',
      'progress': 0.0,
    },
    {
      'id': '9',
      'title': 'Civic Education',
      'description': 'Understanding rights and responsibilities',
      'category': 'Text',
      'duration': '1.5 hours',
      'progress': 0.0,
    },
    {
      'id': '10',
      'title': 'Entrepreneurship',
      'description': 'Starting and running a small business',
      'category': 'Video',
      'duration': '2 hours',
      'progress': 0.0,
    },
  ];

  static const List<Map<String, dynamic>> onboardingScreens = [
    {
      'title': 'Welcome to OLearn',
      'description': 'Your offline learning companion for rural education',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Learn Offline',
      'description': 'Access educational content without internet connection',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Share with Peers',
      'description': 'Share content with nearby learners using Bluetooth',
      'image': 'assets/images/onboarding3.png',
    },
    {
      'title': 'Track Progress',
      'description': 'Monitor your learning journey and achievements',
      'image': 'assets/images/onboarding4.png',
    },
  ];

  // App Info
  static const String appName = 'OLearn';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Offline Learning Platform for Rural Education';
} 