import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:olearn/models/course_model.dart';
import 'package:olearn/models/lesson_model.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get all published courses
  Stream<List<Course>> getPublishedCourses() {
    return _firestore
        .collection('courses')
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Course.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get courses by instructor
  Stream<List<Course>> getCoursesByInstructor(String instructorId) {
    return _firestore
        .collection('courses')
        .where('instructorId', isEqualTo: instructorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Course.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get course by ID
  Future<Course?> getCourseById(String courseId) async {
    try {
      final doc = await _firestore.collection('courses').doc(courseId).get();
      if (doc.exists) {
        return Course.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Create new course
  Future<String> createCourse(Course course) async {
    try {
      final docRef = await _firestore.collection('courses').add(course.toJson());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Update course
  Future<void> updateCourse(String courseId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection('courses').doc(courseId).update(updates);
    } catch (e) {
      rethrow;
    }
  }

  // Delete course
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
      
      // Delete course files from storage
      await _deleteCourseFiles(courseId);
    } catch (e) {
      rethrow;
    }
  }

  // Upload course thumbnail
  Future<String> uploadCourseThumbnail(String courseId, File imageFile) async {
    try {
      final ref = _storage.ref().child('courses/$courseId/thumbnail/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      await updateCourse(courseId, {'thumbnailUrl': downloadUrl});
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Upload course content file
  Future<String> uploadCourseContent(String courseId, String lessonId, File file, String fileName) async {
    try {
      final ref = _storage.ref().child('courses/$courseId/content/$lessonId/$fileName');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Get lessons for a course
  Stream<List<Lesson>> getCourseLessons(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Lesson.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Add lesson to course
  Future<String> addLesson(String courseId, Lesson lesson) async {
    try {
      final docRef = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .add(lesson.toJson());
      
      // Update course total lessons count
      await _updateCourseLessonCount(courseId);
      
      return docRef.id;
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
      
      // Update course total lessons count
      await _updateCourseLessonCount(courseId);
    } catch (e) {
      rethrow;
    }
  }

  // Search courses
  Stream<List<Course>> searchCourses(String query) {
    return _firestore
        .collection('courses')
        .where('isPublished', isEqualTo: true)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Course.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get courses by category
  Stream<List<Course>> getCoursesByCategory(String category) {
    return _firestore
        .collection('courses')
        .where('isPublished', isEqualTo: true)
        .where('categories', arrayContains: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Course.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Update course rating
  Future<void> updateCourseRating(String courseId, double rating) async {
    try {
      final courseRef = _firestore.collection('courses').doc(courseId);
      
      await _firestore.runTransaction((transaction) async {
        final courseDoc = await transaction.get(courseRef);
        final currentRating = courseDoc.data()?['rating'] ?? 0.0;
        final totalRatings = courseDoc.data()?['totalRatings'] ?? 0;
        
        final newTotalRatings = totalRatings + 1;
        final newRating = ((currentRating * totalRatings) + rating) / newTotalRatings;
        
        transaction.update(courseRef, {
          'rating': newRating,
          'totalRatings': newTotalRatings,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to update course lesson count
  Future<void> _updateCourseLessonCount(String courseId) async {
    try {
      final lessonsSnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .get();
      
      await updateCourse(courseId, {'totalLessons': lessonsSnapshot.docs.length});
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to delete course files from storage
  Future<void> _deleteCourseFiles(String courseId) async {
    try {
      final courseRef = _storage.ref().child('courses/$courseId');
      final result = await courseRef.listAll();
      
      for (var item in result.items) {
        await item.delete();
      }
      
      for (var prefix in result.prefixes) {
        final subResult = await prefix.listAll();
        for (var item in subResult.items) {
          await item.delete();
        }
      }
    } catch (e) {
      // Ignore storage deletion errors
      print('Error deleting course files: $e');
    }
  }

  // Create sample courses with real content
  Future<void> createSampleCourses() async {
    try {
      final sampleCourses = [
        {
          'title': 'Mathematics Fundamentals',
          'description': 'Master the basics of mathematics including arithmetic, algebra, and geometry. Perfect for beginners and those looking to strengthen their foundation.',
          'categories': ['Mathematics', 'Education'],
          'level': 'Beginner',
          'duration': '8 weeks',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400&h=300&fit=crop',
          'lessons': [
            {
              'title': 'Introduction to Numbers',
              'description': 'Learn about natural numbers, integers, and real numbers',
              'content': 'Numbers are the foundation of mathematics. In this lesson, we will explore different types of numbers and their properties. Natural numbers (1, 2, 3...) are used for counting, while integers include negative numbers and zero. Real numbers encompass all rational and irrational numbers.',
              'duration': 45,
              'order': 1,
            },
            {
              'title': 'Basic Operations',
              'description': 'Addition, subtraction, multiplication, and division',
              'content': 'The four basic operations of arithmetic are addition (+), subtraction (-), multiplication (×), and division (÷). These operations form the foundation for all mathematical calculations. We will learn the properties of each operation and how to perform them efficiently.',
              'duration': 60,
              'order': 2,
            },
            {
              'title': 'Fractions and Decimals',
              'description': 'Understanding fractions, decimals, and their relationships',
              'content': 'Fractions represent parts of a whole, while decimals are another way to express the same concept. We will learn how to convert between fractions and decimals, perform operations with them, and solve real-world problems.',
              'duration': 75,
              'order': 3,
            },
          ],
        },
        {
          'title': 'English Grammar Essentials',
          'description': 'Improve your English grammar skills with comprehensive lessons on parts of speech, sentence structure, and writing techniques.',
          'categories': ['Language', 'Education'],
          'level': 'Intermediate',
          'duration': '6 weeks',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=400&h=300&fit=crop',
          'lessons': [
            {
              'title': 'Parts of Speech',
              'description': 'Nouns, verbs, adjectives, adverbs, and more',
              'content': 'Understanding parts of speech is crucial for proper sentence construction. We will explore nouns (people, places, things), verbs (actions), adjectives (descriptions), adverbs (modifiers), and other essential parts of speech.',
              'duration': 50,
              'order': 1,
            },
            {
              'title': 'Sentence Structure',
              'description': 'Subject, predicate, and sentence types',
              'content': 'Every sentence has a subject (who or what the sentence is about) and a predicate (what the subject does or is). We will learn about simple, compound, and complex sentences, and how to construct clear, effective sentences.',
              'duration': 55,
              'order': 2,
            },
            {
              'title': 'Punctuation Rules',
              'description': 'Proper use of commas, periods, and other punctuation marks',
              'content': 'Punctuation helps clarify meaning and improve readability. We will cover the rules for using periods, commas, semicolons, colons, apostrophes, and other punctuation marks correctly.',
              'duration': 40,
              'order': 3,
            },
          ],
        },
        {
          'title': 'Computer Science Basics',
          'description': 'Introduction to programming concepts, algorithms, and problem-solving techniques using Python.',
          'categories': ['Technology', 'Programming'],
          'level': 'Beginner',
          'duration': '10 weeks',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?w=400&h=300&fit=crop',
          'lessons': [
            {
              'title': 'Introduction to Programming',
              'description': 'What is programming and why it matters',
              'content': 'Programming is the process of creating instructions for computers to follow. We will explore what programming is, why it\'s important in today\'s world, and how it can solve real-world problems. We\'ll also discuss different programming languages and their uses.',
              'duration': 60,
              'order': 1,
            },
            {
              'title': 'Python Basics',
              'description': 'Variables, data types, and basic syntax',
              'content': 'Python is a popular programming language known for its simplicity and readability. We will learn about variables (containers for data), different data types (strings, numbers, lists), and basic syntax rules. We\'ll write our first Python programs!',
              'duration': 70,
              'order': 2,
            },
            {
              'title': 'Control Structures',
              'description': 'Conditionals and loops for program flow',
              'content': 'Control structures allow programs to make decisions and repeat actions. We will learn about if statements (conditional execution), for loops (repeating actions), and while loops (repeating until a condition is met).',
              'duration': 80,
              'order': 3,
            },
          ],
        },
        {
          'title': 'Business Fundamentals',
          'description': 'Learn essential business concepts including marketing, finance, and entrepreneurship.',
          'categories': ['Business', 'Economics'],
          'level': 'Intermediate',
          'duration': '8 weeks',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&h=300&fit=crop',
          'lessons': [
            {
              'title': 'Introduction to Business',
              'description': 'What is business and types of business organizations',
              'content': 'Business is the activity of making, buying, or selling goods or providing services in exchange for money. We will explore different types of business organizations (sole proprietorship, partnership, corporation) and their characteristics.',
              'duration': 55,
              'order': 1,
            },
            {
              'title': 'Marketing Principles',
              'description': 'Understanding customer needs and market research',
              'content': 'Marketing is about understanding customer needs and creating value. We will learn about the marketing mix (Product, Price, Place, Promotion), market research techniques, and how to develop effective marketing strategies.',
              'duration': 65,
              'order': 2,
            },
            {
              'title': 'Financial Management',
              'description': 'Basic accounting and financial planning',
              'content': 'Financial management involves planning, organizing, and controlling financial resources. We will cover basic accounting concepts, financial statements, budgeting, and financial planning for businesses.',
              'duration': 70,
              'order': 3,
            },
          ],
        },
        {
          'title': 'Environmental Science',
          'description': 'Explore environmental issues, sustainability, and our impact on the planet.',
          'categories': ['Science', 'Environment'],
          'level': 'Beginner',
          'duration': '6 weeks',
          'thumbnailUrl': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=300&fit=crop',
          'lessons': [
            {
              'title': 'Ecosystems and Biodiversity',
              'description': 'Understanding natural systems and species diversity',
              'content': 'Ecosystems are communities of living organisms interacting with their environment. We will explore different types of ecosystems, the importance of biodiversity, and how species depend on each other for survival.',
              'duration': 50,
              'order': 1,
            },
            {
              'title': 'Climate Change',
              'description': 'Causes, effects, and solutions to climate change',
              'content': 'Climate change is one of the most pressing environmental issues of our time. We will examine the causes of climate change, its effects on ecosystems and human societies, and potential solutions to mitigate its impact.',
              'duration': 60,
              'order': 2,
            },
            {
              'title': 'Sustainable Living',
              'description': 'How to reduce our environmental footprint',
              'content': 'Sustainable living involves making choices that reduce our impact on the environment. We will learn about renewable energy, waste reduction, sustainable agriculture, and how individuals can contribute to environmental conservation.',
              'duration': 45,
              'order': 3,
            },
          ],
        },
      ];

      for (final courseData in sampleCourses) {
        // Create course document
        final course = Course(
          id: '',
          title: courseData['title'] as String,
          description: courseData['description'] as String,
          instructorId: 'system', // System-generated courses
          instructorName: 'OLearn Team',
          categories: List<String>.from(courseData['categories'] as List),
          level: courseData['level'] as String?,
          duration: courseData['duration'] as String?,
          thumbnailUrl: courseData['thumbnailUrl'] as String?,
          rating: 4.5,
          totalRatings: 0,
          totalStudents: 0,
          totalLessons: (courseData['lessons'] as List).length,
          totalDuration: 0,
          prerequisites: const [],
          learningObjectives: const [],
          metadata: null,
          isPublished: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final courseId = await createCourse(course);

        // Create lessons for the course
        final lessonsList = courseData['lessons'] as List?;
        if (lessonsList != null) {
          for (final lessonData in lessonsList) {
            final lesson = Lesson(
              id: '',
              courseId: courseId,
              title: lessonData['title'] as String,
              description: lessonData['description'] as String,
              content: lessonData['content'] as String,
              duration: (lessonData['duration'] as num).toInt(),
              order: (lessonData['order'] as num).toInt(),
              videoUrl: null,
              thumbnailUrl: null,
              resources: const [],
              metadata: null,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isPublished: false,
            );
            await addLesson(courseId, lesson);
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }
} 