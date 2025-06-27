import 'package:flutter/material.dart';
import 'package:olearn/services/auth_service.dart';
import 'package:olearn/models/user_model.dart';
import 'package:olearn/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        if (mounted) {
          setState(() {
            _user = userData;
            _isLoading = false;
            if (_user != null) {
              _nameController.text = _user!.name;
              _bioController.text = _user!.bio ?? '';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() { _isLoading = true; });
    try {
      await _authService.updateProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
      );
      await _loadUserData();
      setState(() { _isEditing = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _deleteAccount() async {
    // You may want to add a confirmation dialog here
    try {
      final user = _authService.currentUser;
      if (user != null) {
        await _authService.signOut();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
        await user.delete();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_user == null) {
      return Center(
        child: Text(l10n.userNotFound),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() { _isEditing = true; });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isEditing ? _buildEditForm(context) : _buildProfileView(context),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progressValue = (_user!.progress != null && _user!.progress!['overall'] is num)
        ? (_user!.progress!['overall'] as num).toDouble()
        : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundImage: _user!.photoUrl != null
                ? NetworkImage(_user!.photoUrl!)
                : null,
            child: _user!.photoUrl == null
                ? Text(
                    _user!.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 32),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 24),
        Text(l10n.profileName, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(_user!.name, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        Text(l10n.profileEmail, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(_user!.email, style: Theme.of(context).textTheme.bodyLarge),
        if (_user!.bio != null && _user!.bio!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.bio, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(_user!.bio!, style: Theme.of(context).textTheme.bodyLarge),
        ],
        const SizedBox(height: 24),
        Text(l10n.progress, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progressValue / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 8),
        Text('${progressValue.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _deleteAccount,
          icon: const Icon(Icons.delete),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          label: const Text('Delete Account'),
        ),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundImage: _user!.photoUrl != null
                ? NetworkImage(_user!.photoUrl!)
                : null,
            child: _user!.photoUrl == null
                ? Text(
                    _user!.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 32),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _bioController,
          decoration: const InputDecoration(labelText: 'Bio'),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Save'),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () {
                setState(() { _isEditing = false; });
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }
} 