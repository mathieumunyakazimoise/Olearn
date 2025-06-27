import 'package:flutter/material.dart';
import 'package:olearn/constants/app_constants.dart';
import 'package:olearn/theme/app_theme.dart';
import 'package:olearn/models/course_model.dart';
import 'package:olearn/models/lesson_model.dart';
import 'package:olearn/services/course_service.dart';

class LessonScreen extends StatefulWidget {
  final Course course;
  const LessonScreen({super.key, required this.course});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _isDownloaded = false;
  int _currentLessonIndex = 0;
  final CourseService _courseService = CourseService();

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        actions: [
          IconButton(
            icon: Icon(
              _isDownloaded ? Icons.download_done : Icons.download_outlined,
            ),
            onPressed: () {
              setState(() {
                _isDownloaded = !_isDownloaded;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isDownloaded
                        ? 'Lesson downloaded for offline access'
                        : 'Lesson removed from downloads',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Lesson>>(
        stream: _courseService.getCourseLessons(course.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final lessons = snapshot.data!;
          if (lessons.isEmpty) {
            return const Center(child: Text('No lessons found for this course.'));
          }
          final currentLesson = lessons[_currentLessonIndex];
          return Column(
            children: [
              // Lesson Progress
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: Row(
                  children: [
                    Text(
                      'Lesson \\${_currentLessonIndex + 1} of \\${lessons.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_currentLessonIndex + 1) / lessons.length,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              // Lesson Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentLesson.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildLessonContent(currentLesson),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<List<Lesson>>(
        stream: _courseService.getCourseLessons(course.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
          final lessons = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentLessonIndex > 0)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentLessonIndex--;
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),
                if (_currentLessonIndex < lessons.length - 1)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentLessonIndex++;
                      });
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to quiz screen for this course/lesson
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Quiz feature coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.quiz_outlined),
                    label: const Text('Take Quiz'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLessonContent(Lesson lesson) {
    // For now, support text and video. You can expand to interactive/quiz types as needed.
    if (lesson.content.startsWith('http') && (lesson.content.endsWith('.mp4') || lesson.content.endsWith('.mov')))
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.play_circle_outline,
            size: 64,
            color: Colors.white,
          ),
        ),
      );
    // Text content
    return Text(
      lesson.content,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
} 