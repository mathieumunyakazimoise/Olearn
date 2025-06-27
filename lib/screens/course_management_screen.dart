import 'package:flutter/material.dart';
import 'package:olearn/services/admin_service.dart';
import 'package:olearn/models/course_model.dart';
import 'package:olearn/widgets/custom_button.dart';
import 'package:olearn/screens/course_creation_screen.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  final AdminService _adminService = AdminService();
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search courses by title...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Status Filter
                Row(
                  children: [
                    const Text('Filter by status: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _statusFilter,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(value: 'published', child: Text('Published')),
                        DropdownMenuItem(value: 'draft', child: Text('Draft')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Courses List
          Expanded(
            child: StreamBuilder<List<Course>>(
              stream: _adminService.getAllCourses(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                var courses = snapshot.data!;
                
                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  courses = courses.where((course) =>
                    course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    course.description.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }
                
                // Apply status filter
                if (_statusFilter == 'published') {
                  courses = courses.where((course) => course.isPublished).toList();
                } else if (_statusFilter == 'draft') {
                  courses = courses.where((course) => !course.isPublished).toList();
                }
                
                if (courses.isEmpty) {
                  return const Center(
                    child: Text('No courses found matching your criteria.'),
                  );
                }
                
                return ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: course.thumbnailUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  course.thumbnailUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.book),
                              ),
                        title: Text(course.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 90),
                                    child: Text(
                                      course.instructorName ?? 'Unknown',
                                      style: TextStyle(color: Colors.grey[600]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.school, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text('${course.totalStudents} students', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 110,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Chip(
                                  label: Text(course.isPublished ? 'Published' : 'Draft'),
                                  backgroundColor: course.isPublished ? Colors.green[100] : Colors.orange[100],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) => _handleCourseAction(value, course),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'view',
                                    child: Text('View Details'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit Course'),
                                  ),
                                  PopupMenuItem(
                                    value: course.isPublished ? 'unpublish' : 'publish',
                                    child: Text(course.isPublished ? 'Unpublish' : 'Publish'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete Course'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        onTap: () => _showCourseDetails(course),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to CourseCreationScreen for new course
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CourseCreationScreen(),
            ),
          );
          if (result == 'published' || result == 'draft') {
            setState(() {}); // Refresh after returning if a course was created or published
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Create Course',
      ),
    );
  }

  void _showCourseDetails(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (course.thumbnailUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    course.thumbnailUrl!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),
              Text('Description: ${course.description}'),
              const SizedBox(height: 8),
              Text('Instructor: ${course.instructorName ?? 'Unknown'}'),
              Text('Level: ${course.level ?? 'N/A'}'),
              Text('Duration: ${course.duration ?? 'N/A'}'),
              Text('Lessons: ${course.totalLessons}'),
              Text('Students: ${course.totalStudents}'),
              Text('Rating: ${course.rating ?? 0}/5 (${course.totalRatings ?? 0} ratings)'),
              Text('Status: ${course.isPublished ? "Published" : "Draft"}'),
              Text('Created: ${_formatDate(course.createdAt)}'),
              if (course.categories.isNotEmpty)
                Text('Categories: ${course.categories.join(", ")}'),
            ],
          ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleCourseAction(String action, Course course) {
    switch (action) {
      case 'view':
        _showCourseDetails(course);
        break;
      case 'edit':
        _editCourse(course);
        break;
      case 'publish':
      case 'unpublish':
        _toggleCoursePublish(course);
        break;
      case 'delete':
        _deleteCourse(course);
        break;
    }
  }

  void _editCourse(Course course) {
    // TODO: Navigate to course editing screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course editing feature coming soon!')),
    );
  }

  void _toggleCoursePublish(Course course) {
    final action = course.isPublished ? 'unpublish' : 'publish';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.capitalize()} Course'),
        content: Text('Are you sure you want to $action "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _adminService.toggleCoursePublish(course.id, !course.isPublished);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Course ${action}ed successfully')),
              );
            },
            child: Text(action.capitalize()),
          ),
        ],
      ),
    );
  }

  void _deleteCourse(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to permanently delete "${course.title}"? This action cannot be undone and will also delete all associated lessons and student progress.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _adminService.deleteCourse(course.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Course "${course.title}" deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 