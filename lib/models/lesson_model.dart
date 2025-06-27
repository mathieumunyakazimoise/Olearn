import 'package:json_annotation/json_annotation.dart';

part 'lesson_model.g.dart';

@JsonSerializable()
class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final String content;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int duration; // in minutes
  final int order;
  final List<String> resources;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.content,
    this.videoUrl,
    this.thumbnailUrl,
    this.duration = 0,
    this.order = 0,
    this.resources = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
  Map<String, dynamic> toJson() => _$LessonToJson(this);

  Lesson copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    String? content,
    String? videoUrl,
    String? thumbnailUrl,
    int? duration,
    int? order,
    List<String>? resources,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
  }) {
    return Lesson(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      order: order ?? this.order,
      resources: resources ?? this.resources,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
    );
  }
} 