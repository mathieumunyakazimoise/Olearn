import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:olearn/models/course_model.dart';
import 'package:olearn/models/user_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if user is admin
  Future<bool> isUserAdmin(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        return userData['role'] == 'admin';
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is instructor
  Future<bool> isUserInstructor(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        return userData['role'] == 'instructor' || userData['role'] == 'admin';
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Promote user to admin
  Future<void> promoteToAdmin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'admin',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Promote user to instructor
  Future<void> promoteToInstructor(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'instructor',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Demote user to student
  Future<void> demoteToStudent(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': 'student',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get all users (admin only)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get users by role
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get all courses (admin only)
  Stream<List<Course>> getAllCourses() {
    return _firestore
        .collection('courses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Course.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Publish/unpublish course
  Future<void> toggleCoursePublish(String courseId, bool isPublished) async {
    try {
      await _firestore.collection('courses').doc(courseId).update({
        'isPublished': isPublished,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete course (admin only)
  Future<void> deleteCourse(String courseId) async {
    try {
      // Delete course document
      await _firestore.collection('courses').doc(courseId).delete();
      
      // Delete all lessons in the course
      final lessonsSnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .get();
      
      for (var doc in lessonsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Delete all enrollments for this course
      final enrollmentsSnapshot = await _firestore
          .collection('enrollments')
          .where('courseId', isEqualTo: courseId)
          .get();
      
      for (var doc in enrollmentsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Delete all progress for this course
      final progressSnapshot = await _firestore
          .collection('progress')
          .where('courseId', isEqualTo: courseId)
          .get();
      
      for (var doc in progressSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get app statistics (admin only)
  Future<Map<String, dynamic>> getAppStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final coursesSnapshot = await _firestore.collection('courses').get();
      final enrollmentsSnapshot = await _firestore.collection('enrollments').get();
      
      final totalUsers = usersSnapshot.docs.length;
      final totalCourses = coursesSnapshot.docs.length;
      final totalEnrollments = enrollmentsSnapshot.docs.length;
      
      // Count users by role
      int adminCount = 0;
      int instructorCount = 0;
      int studentCount = 0;
      
      for (var doc in usersSnapshot.docs) {
        final userData = doc.data();
        switch (userData['role']) {
          case 'admin':
            adminCount++;
            break;
          case 'instructor':
            instructorCount++;
            break;
          default:
            studentCount++;
        }
      }
      
      // Count published courses
      int publishedCourses = 0;
      for (var doc in coursesSnapshot.docs) {
        if (doc.data()['isPublished'] == true) {
          publishedCourses++;
        }
      }
      
      return {
        'totalUsers': totalUsers,
        'totalCourses': totalCourses,
        'totalEnrollments': totalEnrollments,
        'adminCount': adminCount,
        'instructorCount': instructorCount,
        'studentCount': studentCount,
        'publishedCourses': publishedCourses,
        'draftCourses': totalCourses - publishedCourses,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Get course analytics (instructor/admin only)
  Future<Map<String, dynamic>> getCourseAnalytics(String courseId) async {
    try {
      final enrollmentsSnapshot = await _firestore
          .collection('enrollments')
          .where('courseId', isEqualTo: courseId)
          .get();
      
      final progressSnapshot = await _firestore
          .collection('progress')
          .where('courseId', isEqualTo: courseId)
          .get();
      
      final totalEnrollments = enrollmentsSnapshot.docs.length;
      
      // Calculate average progress
      double totalProgress = 0;
      int progressCount = 0;
      
      for (var doc in progressSnapshot.docs) {
        final progressData = doc.data();
        final completedLessons = List<String>.from(progressData['completedLessons'] ?? []);
        totalProgress += completedLessons.length;
        progressCount++;
      }
      
      final averageProgress = progressCount > 0 ? totalProgress / progressCount : 0;
      
      // Get recent enrollments (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      int recentEnrollments = 0;
      
      for (var doc in enrollmentsSnapshot.docs) {
        final enrollmentData = doc.data();
        final enrolledAt = DateTime.parse(enrollmentData['enrolledAt']);
        if (enrolledAt.isAfter(thirtyDaysAgo)) {
          recentEnrollments++;
        }
      }
      
      return {
        'totalEnrollments': totalEnrollments,
        'averageProgress': averageProgress,
        'recentEnrollments': recentEnrollments,
        'completionRate': totalEnrollments > 0 ? (progressCount / totalEnrollments) * 100 : 0,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Disable user account
  Future<void> disableUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isDisabled': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Enable user account
  Future<void> enableUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isDisabled': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteUser(String userId) async {
    try {
      // Delete user document
      await _firestore.collection('users').doc(userId).delete();
      
      // Delete user's enrollments
      final enrollmentsSnapshot = await _firestore
          .collection('enrollments')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in enrollmentsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Delete user's progress
      final progressSnapshot = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in progressSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Delete user's created courses (if they were an instructor)
      final coursesSnapshot = await _firestore
          .collection('courses')
          .where('instructorId', isEqualTo: userId)
          .get();
      
      for (var doc in coursesSnapshot.docs) {
        await deleteCourse(doc.id);
      }
    } catch (e) {
      rethrow;
    }
  }
} 