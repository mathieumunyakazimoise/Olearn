// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      role: json['role'] as String? ?? 'student',
      enrolledCourses: (json['enrolledCourses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      progress: json['progress'] as Map<String, dynamic>?,
      phoneNumber: json['phoneNumber'] as String?,
      location: json['location'] as String?,
      education: json['education'] as String?,
      occupation: json['occupation'] as String?,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      preferences: json['preferences'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'photoUrl': instance.photoUrl,
      'bio': instance.bio,
      'role': instance.role,
      'enrolledCourses': instance.enrolledCourses,
      'progress': instance.progress,
      'phoneNumber': instance.phoneNumber,
      'location': instance.location,
      'education': instance.education,
      'occupation': instance.occupation,
      'interests': instance.interests,
      'preferences': instance.preferences,
    };
