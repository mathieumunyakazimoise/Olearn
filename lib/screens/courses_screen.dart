import 'package:flutter/material.dart';
import 'package:olearn/constants/app_constants.dart';
import 'package:olearn/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:olearn/l10n/app_localizations.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Text', 'Video', 'Audio', 'Interactive'];

  @override
  Widget build(BuildContext context) {
    final filteredCourses = _selectedCategory == 'All'
        ? AppConstants.sampleCourses
        : AppConstants.sampleCourses
            .where((course) => course['category'] == _selectedCategory)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.courses),
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
          // Category Filter
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
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
          // Course List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final course = filteredCourses[index];
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
                        AppConstants.lessonRoute,
                        arguments: course,
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course Image
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              _getCategoryIcon(course['category']),
                              size: 64,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      course['title'],
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      course['category'],
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                course['description'],
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.timer_outlined,
                                        size: 16,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        course['duration'],
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.download_outlined,
                                        size: 16,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Download',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Text':
        return Icons.article_outlined;
      case 'Video':
        return Icons.video_library_outlined;
      case 'Audio':
        return Icons.headphones_outlined;
      case 'Interactive':
        return Icons.touch_app_outlined;
      default:
        return Icons.school_outlined;
    }
  }
} 