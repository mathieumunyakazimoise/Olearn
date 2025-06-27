import 'package:flutter/material.dart';
import 'package:olearn/constants/app_constants.dart';
import 'package:olearn/theme/app_theme.dart';
import 'package:olearn/screens/courses_screen.dart';
import 'package:olearn/screens/profile_screen.dart';
import 'package:olearn/screens/admin_dashboard_screen.dart';
import 'package:olearn/screens/progress_screen.dart';
import 'package:olearn/l10n/app_localizations.dart';
import 'package:olearn/services/auth_service.dart';
import 'package:olearn/services/course_service.dart';
import 'package:olearn/models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final CourseService _courseService = CourseService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      setState(() {
        _currentUser = userData;
      });
    }
  }

  List<Widget> get _screens {
    final screens = <Widget>[
      _HomeDashboard(),
      CoursesScreen(),
    ];
    if (!(_currentUser?.isAdmin ?? false)) {
      screens.add(ProgressScreen(userId: _currentUser?.id));
    }
    screens.add(ProfileScreen());
    if (_currentUser?.isAdmin == true) {
      screens.add(const AdminDashboardScreen());
    }
    return screens;
  }

  List<BottomNavigationBarItem> get _navItems {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
    ];
    if (!(_currentUser?.isAdmin ?? false)) {
      items.add(const BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Progress'));
    }
    items.add(const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'));
    if (_currentUser?.isAdmin == true) {
      items.add(const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'));
    }
    return items;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  final AuthService _authService = AuthService();
  final CourseService _courseService = CourseService();

  Future<String> _getUserName() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      return userData?.name ?? '';
    }
    return '';
  }

  Future<void> _populateSampleCourses() async {
    try {
      await _courseService.createSampleCourses();
    } catch (e) {
      print('Error creating sample courses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserName(),
      builder: (context, snapshot) {
        final userName = snapshot.data ?? '';
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                    child: const Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $userName',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.welcomeBackToOLearn,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Welcome Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.welcomeBack,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.continueLearning,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Progress Overview
              Text(
                AppLocalizations.of(context)!.yourProgress,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildProgressItem(
                            context,
                            AppLocalizations.of(context)!.courses,
                            '3/10',
                            Icons.book_outlined,
                          ),
                          _buildProgressItem(
                            context,
                            AppLocalizations.of(context)!.quizzes,
                            '2/5',
                            Icons.quiz_outlined,
                          ),
                          _buildProgressItem(
                            context,
                            'Hours',
                            '4.5',
                            Icons.timer_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Quick Access
              Text(
                AppLocalizations.of(context)!.quickAccess,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildNavigationCard(
                    context,
                    AppLocalizations.of(context)!.courses,
                    Icons.book_outlined,
                    AppConstants.coursesRoute,
                  ),
                  _buildNavigationCard(
                    context,
                    'Downloads',
                    Icons.download_outlined,
                    AppConstants.downloadsRoute,
                  ),
                  _buildNavigationCard(
                    context,
                    'Share',
                    Icons.share_outlined,
                    AppConstants.sharingRoute,
                  ),
                  _buildNavigationCard(
                    context,
                    'Progress',
                    Icons.bar_chart_outlined,
                    AppConstants.progressRoute,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Recent Activity
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.book_outlined,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      title: Text('Mathematics Basics'),
                      subtitle: Text('Completed Lesson ${index + 1}'),
                      trailing: Text(
                        '2h ago',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 