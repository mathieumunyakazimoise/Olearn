import 'package:flutter/material.dart';
import 'package:olearn/constants/app_constants.dart';
import 'package:olearn/theme/app_theme.dart';
import 'package:olearn/l10n/app_localizations.dart';
import 'package:olearn/services/course_service.dart';
import 'package:olearn/models/course_model.dart';
import 'package:olearn/screens/lesson_screen.dart';
import 'package:olearn/services/enrollment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final CourseService _courseService = CourseService();
  String _selectedCategory = 'All';
  final List<String> _categories = ['All']; // You can fetch categories dynamically if needed

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final enrollmentService = EnrollmentService();
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter (optional, can be expanded)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      }
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          // Real-time Courses List
          Expanded(
            child: StreamBuilder<List<Course>>(
              stream: _courseService.getPublishedCourses(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: \\${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var courses = snapshot.data!;
                // Optionally filter by category
                if (_selectedCategory != 'All') {
                  courses = courses.where((c) => c.categories.contains(_selectedCategory)).toList();
                }
                if (courses.isEmpty) {
                  return const Center(child: Text('No courses found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/lesson',
                            arguments: {'course': course},
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Course Image
                            if (course.thumbnailUrl != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(
                                  course.thumbnailUrl!,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.title,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    course.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[700],
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(course.instructorName ?? 'Unknown', style: TextStyle(color: Colors.grey[600])),
                                      const SizedBox(width: 16),
                                      Icon(Icons.school, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text('${course.totalStudents} students', style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  if (currentUser != null)
                                    FutureBuilder<bool>(
                                      future: enrollmentService.isUserEnrolled(currentUser.uid, course.id),
                                      builder: (context, enrolledSnapshot) {
                                        if (!enrolledSnapshot.hasData) {
                                          return const SizedBox.shrink();
                                        }
                                        final isEnrolled = enrolledSnapshot.data!;
                                        return ElevatedButton(
                                          onPressed: isEnrolled
                                              ? () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/lesson',
                                                    arguments: {'course': course},
                                                  );
                                                }
                                              : () async {
                                                  await enrollmentService.enrollUserInCourse(currentUser.uid, course.id);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Enrolled in ${course.title}!')),
                                                  );
                                                  setState(() {});
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isEnrolled ? Colors.green : Theme.of(context).primaryColor,
                                          ),
                                          child: Text(isEnrolled ? 'Go to Course' : 'Enroll'),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 