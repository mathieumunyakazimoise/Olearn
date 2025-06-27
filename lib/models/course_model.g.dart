// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      instructorId: json['instructorId'] as String,
      instructorName: json['instructorName'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      totalLessons: (json['totalLessons'] as num?)?.toInt() ?? 0,
      totalDuration: (json['totalDuration'] as num?)?.toInt() ?? 0,
      level: json['level'] as String?,
      duration: json['duration'] as String?,
      totalRatings: (json['totalRatings'] as num?)?.toInt(),
      prerequisites: (json['prerequisites'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      learningObjectives: (json['learningObjectives'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPublished: json['isPublished'] as bool? ?? false,
    );

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'instructorId': instance.instructorId,
      'instructorName': instance.instructorName,
      'thumbnailUrl': instance.thumbnailUrl,
      'categories': instance.categories,
      'rating': instance.rating,
      'totalStudents': instance.totalStudents,
      'totalLessons': instance.totalLessons,
      'totalDuration': instance.totalDuration,
      'level': instance.level,
      'duration': instance.duration,
      'totalRatings': instance.totalRatings,
      'prerequisites': instance.prerequisites,
      'learningObjectives': instance.learningObjectives,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isPublished': instance.isPublished,
    };
