import 'package:json_annotation/json_annotation.dart';

part 'course_model.g.dart';

@JsonSerializable()
class Course {
  final String id;
  final String title;
  final String description;
  final String instructorId;
  final String? instructorName;
  final String? thumbnailUrl;
  final List<String> categories;
  final double rating;
  final int totalStudents;
  final int totalLessons;
  final int totalDuration; // in minutes
  final String? level;
  final String? duration;
  final int? totalRatings;
  final List<String> prerequisites;
  final List<String> learningObjectives;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    this.instructorName,
    this.thumbnailUrl,
    this.categories = const [],
    this.rating = 0.0,
    this.totalStudents = 0,
    this.totalLessons = 0,
    this.totalDuration = 0,
    this.level,
    this.duration,
    this.totalRatings,
    this.prerequisites = const [],
    this.learningObjectives = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? instructorId,
    String? instructorName,
    String? thumbnailUrl,
    List<String>? categories,
    double? rating,
    int? totalStudents,
    int? totalLessons,
    int? totalDuration,
    String? level,
    String? duration,
    int? totalRatings,
    List<String>? prerequisites,
    List<String>? learningObjectives,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      totalStudents: totalStudents ?? this.totalStudents,
      totalLessons: totalLessons ?? this.totalLessons,
      totalDuration: totalDuration ?? this.totalDuration,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      totalRatings: totalRatings ?? this.totalRatings,
      prerequisites: prerequisites ?? this.prerequisites,
      learningObjectives: learningObjectives ?? this.learningObjectives,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
    );
  }
} 