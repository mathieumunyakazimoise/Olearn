import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:olearn/models/lesson_model.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get lesson by ID
  Future<Lesson?> getLessonById(String courseId, String lessonId) async {
    try {
      final doc = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .get();
      
      if (doc.exists) {
        return Lesson.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update lesson
  Future<void> updateLesson(String courseId, String lessonId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .update(updates);
    } catch (e) {
      rethrow;
    }
  }

  // Delete lesson
  Future<void> deleteLesson(String courseId, String lessonId) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .doc(lessonId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // Upload lesson content
  Future<String> uploadLessonContent(String courseId, String lessonId, File file, String fileName) async {
    try {
      final ref = _storage.ref().child('courses/$courseId/content/$lessonId/$fileName');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Mark lesson as completed
  Future<void> markLessonCompleted(String userId, String courseId, String lessonId) async {
    try {
      final progressRef = _firestore
          .collection('progress')
          .doc('${userId}_$courseId');
      
      await progressRef.set({
        'userId': userId,
        'courseId': courseId,
        'completedLessons': FieldValue.arrayUnion([lessonId]),
        'lastAccessed': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  // Get user progress for a course
  Future<Map<String, dynamic>?> getUserProgress(String userId, String courseId) async {
    try {
      final doc = await _firestore
          .collection('progress')
          .doc('${userId}_$courseId')
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get all user progress
  Stream<List<Map<String, dynamic>>> getUserAllProgress(String userId) {
    return _firestore
        .collection('progress')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }

  // Calculate course completion percentage
  Future<double> getCourseCompletionPercentage(String userId, String courseId) async {
    try {
      final progress = await getUserProgress(userId, courseId);
      if (progress == null) return 0.0;
      
      final completedLessons = List<String>.from(progress['completedLessons'] ?? []);
      
      // Get total lessons in course
      final lessonsSnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .get();
      
      final totalLessons = lessonsSnapshot.docs.length;
      if (totalLessons == 0) return 0.0;
      
      return (completedLessons.length / totalLessons) * 100;
    } catch (e) {
      rethrow;
    }
  }

  // Get next lesson in course
  Future<Lesson?> getNextLesson(String courseId, String currentLessonId) async {
    try {
      final currentLesson = await getLessonById(courseId, currentLessonId);
      if (currentLesson == null) return null;
      
      final nextLessonSnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .where('order', isGreaterThan: currentLesson.order)
          .orderBy('order')
          .limit(1)
          .get();
      
      if (nextLessonSnapshot.docs.isNotEmpty) {
        return Lesson.fromJson({...nextLessonSnapshot.docs.first.data(), 'id': nextLessonSnapshot.docs.first.id});
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get previous lesson in course
  Future<Lesson?> getPreviousLesson(String courseId, String currentLessonId) async {
    try {
      final currentLesson = await getLessonById(courseId, currentLessonId);
      if (currentLesson == null) return null;
      
      final previousLessonSnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .where('order', isLessThan: currentLesson.order)
          .orderBy('order', descending: true)
          .limit(1)
          .get();
      
      if (previousLessonSnapshot.docs.isNotEmpty) {
        return Lesson.fromJson({...previousLessonSnapshot.docs.first.data(), 'id': previousLessonSnapshot.docs.first.id});
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
} 