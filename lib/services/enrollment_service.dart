import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:olearn/models/course_model.dart';

class EnrollmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enroll user in a course
  Future<void> enrollUserInCourse(String userId, String courseId) async {
    try {
      final enrollmentId = '${userId}_$courseId';
      
      await _firestore.collection('enrollments').doc(enrollmentId).set({
        'userId': userId,
        'courseId': courseId,
        'enrolledAt': DateTime.now().toIso8601String(),
        'status': 'active',
        'progress': 0.0,
        'lastAccessed': DateTime.now().toIso8601String(),
      });

      // Update user's enrolled courses
      await _firestore.collection('users').doc(userId).update({
        'enrolledCourses': FieldValue.arrayUnion([courseId]),
      });

      // Update course total students count
      await _updateCourseStudentCount(courseId, 1);
    } catch (e) {
      rethrow;
    }
  }

  // Unenroll user from a course
  Future<void> unenrollUserFromCourse(String userId, String courseId) async {
    try {
      final enrollmentId = '${userId}_$courseId';
      
      await _firestore.collection('enrollments').doc(enrollmentId).delete();

      // Remove from user's enrolled courses
      await _firestore.collection('users').doc(userId).update({
        'enrolledCourses': FieldValue.arrayRemove([courseId]),
      });

      // Delete user's progress for this course
      await _firestore.collection('progress').doc(enrollmentId).delete();

      // Update course total students count
      await _updateCourseStudentCount(courseId, -1);
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is enrolled in a course
  Future<bool> isUserEnrolled(String userId, String courseId) async {
    try {
      final enrollmentId = '${userId}_$courseId';
      final doc = await _firestore.collection('enrollments').doc(enrollmentId).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  // Get user's enrolled courses
  Stream<List<Course>> getUserEnrolledCourses(String userId) {
    return _firestore
        .collection('enrollments')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((snapshot) async {
      final courseIds = snapshot.docs.map((doc) => doc.data()['courseId'] as String).toList();
      
      if (courseIds.isEmpty) return [];
      
      final coursesSnapshot = await _firestore
          .collection('courses')
          .where(FieldPath.documentId, whereIn: courseIds)
          .get();
      
      return coursesSnapshot.docs
          .map((doc) => Course.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get enrollment details
  Future<Map<String, dynamic>?> getEnrollmentDetails(String userId, String courseId) async {
    try {
      final enrollmentId = '${userId}_$courseId';
      final doc = await _firestore.collection('enrollments').doc(enrollmentId).get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update enrollment progress
  Future<void> updateEnrollmentProgress(String userId, String courseId, double progress) async {
    try {
      final enrollmentId = '${userId}_$courseId';
      
      await _firestore.collection('enrollments').doc(enrollmentId).update({
        'progress': progress,
        'lastAccessed': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get course enrollment count
  Future<int> getCourseEnrollmentCount(String courseId) async {
    try {
      final snapshot = await _firestore
          .collection('enrollments')
          .where('courseId', isEqualTo: courseId)
          .where('status', isEqualTo: 'active')
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      rethrow;
    }
  }

  // Get all enrollments for a course (admin/instructor only)
  Stream<List<Map<String, dynamic>>> getCourseEnrollments(String courseId) {
    return _firestore
        .collection('enrollments')
        .where('courseId', isEqualTo: courseId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  // Helper method to update course student count
  Future<void> _updateCourseStudentCount(String courseId, int change) async {
    try {
      final courseRef = _firestore.collection('courses').doc(courseId);
      
      await _firestore.runTransaction((transaction) async {
        final courseDoc = await transaction.get(courseRef);
        final currentCount = courseDoc.data()?['totalStudents'] ?? 0;
        final newCount = currentCount + change;
        
        transaction.update(courseRef, {
          'totalStudents': newCount,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      rethrow;
    }
  }
} 