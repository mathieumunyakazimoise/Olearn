import 'package:flutter/material.dart';
import 'package:olearn/config/firebase_config.dart';
import 'package:olearn/l10n/app_localizations.dart';
import 'package:olearn/screens/splash_screen.dart';
import 'package:olearn/screens/login_screen.dart';
import 'package:olearn/screens/home_screen.dart';
import 'package:olearn/screens/onboarding_screen.dart';
import 'package:olearn/screens/lesson_screen.dart';
import 'package:olearn/screens/signup_screen.dart';
import 'package:olearn/screens/courses_screen.dart';
import 'package:olearn/screens/downloads_screen.dart';
import 'package:olearn/screens/sharing_screen.dart';
import 'package:olearn/screens/progress_screen.dart';
import 'package:olearn/screens/profile_screen.dart';
import 'package:olearn/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstLaunch') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OLearn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CoverScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/lesson') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && args['course'] != null) {
            return MaterialPageRoute(
              builder: (context) => LessonScreen(course: args['course']),
            );
          }
        }
        if (settings.name == '/progress') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && args['userId'] != null) {
            return MaterialPageRoute(
              builder: (context) => ProgressScreen(userId: args['userId']),
            );
          }
        }
        // Add more dynamic routes if needed
        return null;
      },
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/onboarding': (context) => const Onboarding(),
        '/home': (context) => const HomeScreen(),
        '/courses': (context) => const CoursesScreen(),
        '/downloads': (context) => const DownloadsScreen(),
        '/sharing': (context) => const SharingScreen(),
        '/profile': (context) => const ProfileScreen(),
        // '/lesson' handled by onGenerateRoute
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // For now, show login screen directly
        // You can add logic here to show CoverScreen for first-time users
        return const LoginScreen();
      },
    );
  }
}

class CoverScreen extends StatelessWidget {
  const CoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2196F3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: Image.asset(
                'assets/images/learn.png',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Welcome to OLearn',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isFirstLaunch', false);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
