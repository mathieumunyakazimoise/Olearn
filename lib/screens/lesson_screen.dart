import 'package:flutter/material.dart';
import 'package:olearn/constants/app_constants.dart';
import 'package:olearn/theme/app_theme.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _isDownloaded = false;
  int _currentLessonIndex = 0;

  // Sample lesson content
  final List<Map<String, dynamic>> _lessons = [
    {
      'title': 'Introduction to Mathematics',
      'type': 'Text',
      'content': '''
Mathematics is the study of numbers, shapes, and patterns. It is a fundamental subject that helps us understand the world around us.

Key Concepts:
1. Numbers and Operations
2. Algebra and Equations
3. Geometry and Shapes
4. Statistics and Probability

Let's start with basic arithmetic operations:
- Addition: Combining numbers
- Subtraction: Taking away numbers
- Multiplication: Repeated addition
- Division: Sharing equally
''',
    },
    {
      'title': 'Basic Arithmetic Operations',
      'type': 'Video',
      'content': 'https://example.com/video1.mp4',
    },
    {
      'title': 'Practice Problems',
      'type': 'Interactive',
      'content': [
        {
          'question': 'What is 5 + 7?',
          'options': ['10', '12', '14', '15'],
          'correctAnswer': '12',
        },
        {
          'question': 'What is 8 × 4?',
          'options': ['24', '28', '32', '36'],
          'correctAnswer': '32',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final course = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final currentLesson = _lessons[_currentLessonIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(course['title']),
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
      body: Column(
        children: [
          // Lesson Progress
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Text(
                  'Lesson ${_currentLessonIndex + 1} of ${_lessons.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentLessonIndex + 1) / _lessons.length,
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
                    currentLesson['title'],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildLessonContent(currentLesson),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
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
              if (_currentLessonIndex < _lessons.length - 1)
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
                    Navigator.pushNamed(context, AppConstants.quizRoute);
                  },
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('Take Quiz'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonContent(Map<String, dynamic> lesson) {
    switch (lesson['type']) {
      case 'Text':
        return Text(
          lesson['content'],
          style: Theme.of(context).textTheme.bodyLarge,
        );
      case 'Video':
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
      case 'Audio':
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(
              Icons.play_arrow,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
        );
      case 'Interactive':
        return Column(
          children: (lesson['content'] as List).map((question) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question['question'],
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ...(question['options'] as List).map((option) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Handle answer selection
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: Text(option),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      default:
        return const Center(
          child: Text('Unsupported content type'),
        );
    }
  }
} 