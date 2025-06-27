import 'package:flutter/material.dart';
import 'package:olearn/services/admin_service.dart';
import 'package:olearn/models/user_model.dart';
import 'package:olearn/widgets/custom_button.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AdminService _adminService = AdminService();
  String _searchQuery = '';
  String _roleFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
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
                    hintText: 'Search users by name or email...',
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
                // Role Filter
                Row(
                  children: [
                    const Text('Filter by role: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _roleFilter,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(value: 'student', child: Text('Students')),
                        DropdownMenuItem(value: 'instructor', child: Text('Instructors')),
                        DropdownMenuItem(value: 'admin', child: Text('Admins')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _roleFilter = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Users List
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _adminService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                var users = snapshot.data!;
                
                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  users = users.where((user) =>
                    user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    user.email.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }
                
                // Apply role filter
                if (_roleFilter != 'all') {
                  users = users.where((user) => user.role == _roleFilter).toList();
                }
                
                if (users.isEmpty) {
                  return const Center(
                    child: Text('No users found matching your criteria.'),
                  );
                }
                
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(user.name[0].toUpperCase())
                              : null,
                        ),
                        title: Text(user.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            Text('Joined: ${_formatDate(user.createdAt)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(user.role ?? 'student'),
                              backgroundColor: _getRoleColor(user.role),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) => _handleUserAction(value, user),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Text('View Details'),
                                ),
                                if (user.role != 'admin')
                                  const PopupMenuItem(
                                    value: 'promote',
                                    child: Text('Promote to Instructor'),
                                  ),
                                if (user.role == 'instructor')
                                  const PopupMenuItem(
                                    value: 'demote',
                                    child: Text('Demote to Student'),
                                  ),
                                const PopupMenuItem(
                                  value: 'disable',
                                  child: Text('Disable Account'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete Account'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => _showUserDetails(user),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Role: ${user.role ?? 'student'}'),
            Text('Joined: ${_formatDate(user.createdAt)}'),
            if (user.bio != null && user.bio!.isNotEmpty)
              Text('Bio: ${user.bio}'),
            if (user.location != null)
              Text('Location: ${user.location}'),
            if (user.education != null)
              Text('Education: ${user.education}'),
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

  void _handleUserAction(String action, UserModel user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'promote':
        _promoteUser(user);
        break;
      case 'demote':
        _demoteUser(user);
        break;
      case 'disable':
        _disableUser(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _promoteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote User'),
        content: Text('Are you sure you want to promote ${user.name} to instructor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _adminService.updateUserRole(user.id, 'instructor');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name} promoted to instructor')),
              );
            },
            child: const Text('Promote'),
          ),
        ],
      ),
    );
  }

  void _demoteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Demote User'),
        content: Text('Are you sure you want to demote ${user.name} to student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _adminService.updateUserRole(user.id, 'student');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name} demoted to student')),
              );
            },
            child: const Text('Demote'),
          ),
        ],
      ),
    );
  }

  void _disableUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable User'),
        content: Text('Are you sure you want to disable ${user.name}\'s account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _adminService.disableUser(user.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name}\'s account disabled')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to permanently delete ${user.name}\'s account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _adminService.deleteUser(user.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name}\'s account deleted')),
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