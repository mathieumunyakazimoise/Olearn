import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? photoUrl;
  String? bio;
  String? role; // 'student', 'instructor', 'admin'
  List<String>? enrolledCourses;
  Map<String, dynamic>? progress;
  String? phoneNumber;
  String? location;
  String? education;
  String? occupation;
  List<String>? interests;
  Map<String, dynamic>? preferences;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.bio,
    this.role = 'student',
    this.enrolledCourses,
    this.progress,
    this.phoneNumber,
    this.location,
    this.education,
    this.occupation,
    this.interests,
    this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? photoUrl,
    String? bio,
    String? role,
    List<String>? enrolledCourses,
    Map<String, dynamic>? progress,
    String? phoneNumber,
    String? location,
    String? education,
    String? occupation,
    List<String>? interests,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      progress: progress ?? this.progress,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      education: education ?? this.education,
      occupation: occupation ?? this.occupation,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
    );
  }

  // Helper methods
  bool get isAdmin => role == 'admin';
  bool get isInstructor => role == 'instructor' || role == 'admin';
  bool get isStudent => role == 'student' || role == null;
} 