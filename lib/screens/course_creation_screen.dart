import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olearn/models/course_model.dart';
import 'package:olearn/services/course_service.dart';
import 'package:olearn/services/auth_service.dart';
import 'package:olearn/widgets/custom_button.dart';
import 'package:olearn/widgets/custom_text_field.dart';

class CourseCreationScreen extends StatefulWidget {
  final Course? course; // If provided, we're editing an existing course

  const CourseCreationScreen({super.key, this.course});

  @override
  State<CourseCreationScreen> createState() => _CourseCreationScreenState();
}

class _CourseCreationScreenState extends State<CourseCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorNameController = TextEditingController();
  final CourseService _courseService = CourseService();
  final AuthService _authService = AuthService();
  
  File? _thumbnailFile;
  List<String> _selectedCategories = [];
  List<String> _prerequisites = [];
  List<String> _learningObjectives = [];
  bool _isPublished = false;

  final List<String> _availableCategories = [
    'Technology',
    'Business',
    'Health & Fitness',
    'Arts & Design',
    'Education',
    'Language',
    'Music',
    'Photography',
    'Cooking',
    'Sports',
    'Science',
    'History',
    'Literature',
    'Mathematics',
    'Programming',
    'Marketing',
    'Finance',
    'Psychology',
    'Philosophy',
    'Religion',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _loadCourseData();
    }
  }

  void _loadCourseData() {
    final course = widget.course!;
    _titleController.text = course.title;
    _descriptionController.text = course.description;
    _instructorNameController.text = course.instructorName ?? '';
    _selectedCategories = List.from(course.categories);
    _prerequisites = List.from(course.prerequisites);
    _learningObjectives = List.from(course.learningObjectives);
    _isPublished = course.isPublished;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructorNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course != null ? 'Edit Course' : 'Create Course'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnailSection(),
              const SizedBox(height: 24),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildCategoriesSection(),
              const SizedBox(height: 24),
              _buildPrerequisitesSection(),
              const SizedBox(height: 24),
              _buildLearningObjectivesSection(),
              const SizedBox(height: 24),
              _buildPublishSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Thumbnail',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 200,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _thumbnailFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _thumbnailFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : widget.course?.thumbnailUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.course!.thumbnailUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add Thumbnail',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _titleController,
              label: 'Course Title',
              hint: 'Enter course title',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a course title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter course description',
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a course description';
                }
                if (value.length < 50) {
                  return 'Description must be at least 50 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _instructorNameController,
              label: 'Instructor Name',
              hint: 'Enter instructor name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter instructor name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableCategories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrerequisitesSection() {
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
                  'Prerequisites',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addPrerequisite,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._prerequisites.asMap().entries.map((entry) {
              final index = entry.key;
              final prerequisite = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter prerequisite',
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: prerequisite),
                        onChanged: (value) {
                          _prerequisites[index] = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removePrerequisite(index),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningObjectivesSection() {
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
                  'Learning Objectives',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addLearningObjective,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._learningObjectives.asMap().entries.map((entry) {
              final index = entry.key;
              final objective = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter learning objective',
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: objective),
                        onChanged: (value) {
                          _learningObjectives[index] = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeLearningObjective(index),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Publish Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Publish Course'),
              subtitle: const Text('Make this course available to students'),
              value: _isPublished,
              onChanged: (value) {
                setState(() {
                  _isPublished = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Save Draft',
            onPressed: _saveDraft,
            backgroundColor: Colors.grey,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: widget.course?.isPublished == true ? 'Update Course' : 'Publish Course',
            onPressed: _confirmAndPublish,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _thumbnailFile = File(pickedFile.path);
      });
    }
  }

  void _addPrerequisite() {
    setState(() {
      _prerequisites.add('');
    });
  }

  void _removePrerequisite(int index) {
    setState(() {
      _prerequisites.removeAt(index);
    });
  }

  void _addLearningObjective() {
    setState(() {
      _learningObjectives.add('');
    });
  }

  void _removeLearningObjective(int index) {
    setState(() {
      _learningObjectives.removeAt(index);
    });
  }

  Future<void> _saveDraft() async {
    await _saveCourse(isPublishing: false);
  }

  Future<void> _confirmAndPublish() async {
    final shouldPublish = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Course'),
        content: const Text('Are you sure you want to publish this course? It will be visible to all students.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
    if (shouldPublish == true) {
      await _saveCourse(isPublishing: true);
    }
  }

  Future<void> _saveCourse({required bool isPublishing}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
      );
      return;
    }
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      final course = Course(
        id: widget.course?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        instructorId: currentUser.uid,
        instructorName: _instructorNameController.text.trim(),
        categories: _selectedCategories,
        prerequisites: _prerequisites.where((p) => p.isNotEmpty).toList(),
        learningObjectives: _learningObjectives.where((o) => o.isNotEmpty).toList(),
        isPublished: isPublishing,
        createdAt: widget.course?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      String courseId;
      if (widget.course != null) {
        await _courseService.updateCourse(course.id, course.toJson());
        courseId = course.id;
      } else {
        courseId = await _courseService.createCourse(course);
      }
      if (_thumbnailFile != null) {
        await _courseService.uploadCourseThumbnail(courseId, _thumbnailFile!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.course != null
                ? (isPublishing ? 'Course updated and published successfully' : 'Course updated as draft')
                : (isPublishing ? 'Course published successfully' : 'Course saved as draft'),
          ),
        ),
      );
      // Return a flag to force refresh in course management
      Navigator.pop(context, isPublishing ? 'published' : 'draft');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
} 