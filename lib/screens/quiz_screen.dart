import 'package:flutter/material.dart';
import 'package:olearn/constants/app_constants.dart';
import 'package:olearn/theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  String? _selectedAnswer;

  // Sample quiz questions
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the result of 15 + 27?',
      'options': ['32', '42', '52', '62'],
      'correctAnswer': '42',
    },
    {
      'question': 'Which of these is a prime number?',
      'options': ['4', '6', '7', '8'],
      'correctAnswer': '7',
    },
    {
      'question': 'What is 8 × 9?',
      'options': ['63', '72', '81', '90'],
      'correctAnswer': '72',
    },
    {
      'question': 'Solve: 24 ÷ 6 = ?',
      'options': ['3', '4', '6', '8'],
      'correctAnswer': '4',
    },
    {
      'question': 'What is the next number in the sequence: 2, 4, 8, 16, ?',
      'options': ['24', '32', '48', '64'],
      'correctAnswer': '32',
    },
  ];

  void _handleAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _handleNext() {
    if (_selectedAnswer == null) return;

    if (_selectedAnswer == _questions[_currentQuestionIndex]['correctAnswer']) {
      setState(() {
        _score++;
      });
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _quizCompleted = false;
      _selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: _quizCompleted ? _buildResults() : _buildQuiz(),
    );
  }

  Widget _buildQuiz() {
    final question = _questions[_currentQuestionIndex];

    return Column(
      children: [
        // Progress Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
            ],
          ),
        ),
        // Question
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question['question'],
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                ...(question['options'] as List).map((option) {
                  final isSelected = option == _selectedAnswer;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _handleAnswer(option),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.grey.shade400,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        // Next Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedAnswer == null ? null : _handleNext,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
            child: Text(
              _currentQuestionIndex < _questions.length - 1
                  ? 'Next Question'
                  : 'Finish Quiz',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final percentage = (_score / _questions.length) * 100;
    String message;
    IconData icon;

    if (percentage >= 80) {
      message = 'Excellent! You have a great understanding of the topic.';
      icon = Icons.emoji_events;
    } else if (percentage >= 60) {
      message = 'Good job! Keep practicing to improve your score.';
      icon = Icons.thumb_up;
    } else {
      message = 'Keep learning! Review the material and try again.';
      icon = Icons.school;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Quiz Completed!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your Score: $_score/${_questions.length}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _restartQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 56),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
              },
              icon: const Icon(Icons.home_outlined),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
} 