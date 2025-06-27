import 'package:flutter/material.dart';
import 'package:olearn/services/admin_service.dart';
import 'package:olearn/models/user_model.dart';
import 'package:olearn/models/course_model.dart';
import 'package:olearn/widgets/custom_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:olearn/screens/user_management_screen.dart';
import 'package:olearn/screens/course_management_screen.dart';
import 'package:olearn/services/course_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _adminService.getAppStatistics();
      if (mounted) {
        setState(() {
          _statistics = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading statistics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatisticsCards(),
                      const SizedBox(height: 24),
                      _buildCharts(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildRecentUsers(),
                      const SizedBox(height: 24),
                      _buildRecentCourses(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatisticsCards() {
    if (_statistics == null) return const SizedBox.shrink();
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          'Total Users',
          _statistics!['totalUsers'].toString(),
          Icons.people,
          Colors.blue,
          onTap: _navigateToUserManagement,
        ),
        _buildStatCard(
          'Total Courses',
          _statistics!['totalCourses'].toString(),
          Icons.book,
          Colors.green,
          onTap: _navigateToCourseManagement,
        ),
        _buildStatCard(
          'Total Enrollments',
          _statistics!['totalEnrollments'].toString(),
          Icons.school,
          Colors.orange,
          onTap: _navigateToCourseManagement,
        ),
        _buildStatCard(
          'Published Courses',
          _statistics!['publishedCourses'].toString(),
          Icons.published_with_changes,
          Colors.purple,
          onTap: _navigateToCourseManagement,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharts() {
    if (_statistics == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: _statistics!['adminCount'].toDouble(),
                      title: 'Admins\n${_statistics!['adminCount']}',
                      color: Colors.red,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: _statistics!['instructorCount'].toDouble(),
                      title: 'Instructors\n${_statistics!['instructorCount']}',
                      color: Colors.blue,
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: _statistics!['studentCount'].toDouble(),
                      title: 'Students\n${_statistics!['studentCount']}',
                      color: Colors.green,
                      radius: 60,
                    ),
                  ],
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Manage Users',
                    onPressed: () => _navigateToUserManagement(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Manage Courses',
                    onPressed: () => _navigateToCourseManagement(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Add Instructor',
                    onPressed: () => _showAddInstructorDialog(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'System Settings',
                    onPressed: () => _showSystemSettings(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUsers() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Users',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => _navigateToUserManagement(),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<UserModel>>(
              stream: _adminService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final users = snapshot.data!.take(5).toList();
                
                return Column(
                  children: users.map((user) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(user.name[0].toUpperCase())
                          : null,
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Chip(
                      label: Text(user.role ?? 'student'),
                      backgroundColor: _getRoleColor(user.role),
                    ),
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCourses() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Courses',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => _navigateToCourseManagement(),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<Course>>(
              stream: _adminService.getAllCourses(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final courses = snapshot.data!.take(5).toList();
                
                return SingleChildScrollView(
                  child: Column(
                    children: courses.map((course) => ListTile(
                      leading: course.thumbnailUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                course.thumbnailUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.book),
                            ),
                      title: Text(course.title),
                      subtitle: Text('${course.totalStudents} students'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            course.isPublished ? Icons.published_with_changes : Icons.edit_note,
                            color: course.isPublished ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.more_vert),
                        ],
                      ),
                    )).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.red[100]!;
      case 'instructor':
        return Colors.blue[100]!;
      default:
        return Colors.green[100]!;
    }
  }

  void _navigateToUserManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserManagementScreen(),
      ),
    );
  }

  void _navigateToCourseManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CourseManagementScreen(),
      ),
    );
  }

  void _showAddInstructorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Instructor'),
        content: const Text('This feature will allow you to promote users to instructors.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement add instructor functionality
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showSystemSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('System settings and configuration options will be available here.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _populateSampleCourses();
              },
              child: const Text('Populate Sample Courses'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _populateSampleCourses() async {
    try {
      final courseService = CourseService();
      await courseService.createSampleCourses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample courses created successfully!')),
        );
        _loadStatistics(); // Refresh statistics
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating sample courses: $e')),
        );
      }
    }
  }

  void _showCourseDetails(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${course.description}'),
            const SizedBox(height: 8),
            Text('Students: ${course.totalStudents}'),
            Text('Lessons: ${course.totalLessons}'),
            Text('Status: ${course.isPublished ? "Published" : "Draft"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleCoursePublish(course);
            },
            child: Text(course.isPublished ? 'Unpublish' : 'Publish'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCoursePublish(Course course) async {
    try {
      await _adminService.toggleCoursePublish(course.id, !course.isPublished);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course ${course.isPublished ? 'unpublished' : 'published'} successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
} 