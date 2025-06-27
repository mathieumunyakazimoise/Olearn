import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:olearn/theme/app_theme.dart';
import 'package:olearn/services/enrollment_service.dart';
import 'package:olearn/services/lesson_service.dart';
import 'package:olearn/models/course_model.dart';
import 'package:olearn/models/lesson_model.dart';

class ProgressScreen extends StatelessWidget {
  final String? userId;
  const ProgressScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Center(child: Text('No user found.'));
    }
    final enrollmentService = EnrollmentService();
    final lessonService = LessonService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Progress'),
      ),
      body: StreamBuilder<List<Course>>(
        stream: enrollmentService.getUserEnrolledCourses(userId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final courses = snapshot.data!;
          if (courses.isEmpty) {
            return const Center(child: Text('You are not enrolled in any courses yet.'));
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      FutureBuilder<double>(
                        future: lessonService.getUserProgress(userId!, course.id).then((progress) {
                          if (progress == null) return 0.0;
                          final completed = List<String>.from(progress['completedLessons'] ?? []);
                          final total = course.totalLessons;
                          if (total == 0) return 0.0;
                          return (completed.length / total) * 100;
                        }),
                        builder: (context, progressSnapshot) {
                          if (!progressSnapshot.hasData) {
                            return const LinearProgressIndicator();
                          }
                          final percent = progressSnapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: percent / 100,
                                minHeight: 8,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                              ),
                              const SizedBox(height: 8),
                              Text('Progress: \\${percent.toStringAsFixed(1)}%'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
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
} 