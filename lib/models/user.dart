import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> settings;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? settings, required String name,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.lastLoginAt = lastLoginAt ?? DateTime.now(),
        this.settings = settings ?? {
          'taskSortBy': 'dueDate',
          'taskSortDirection': 'asc',
          'showCompletedTasks': true,
          'theme': 'system',
          'notifications': true,
        };

  // Create UserModel from Firebase document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      settings: data['settings'] ?? {},
      name: data['name'],
    );
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert UserModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'settings': settings,
    };
  }

  // Create copy of UserModel with modified fields
  UserModel copyWith({
    String? displayName,
    String? photoURL,
    DateTime? lastLoginAt,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      id: this.id,
      email: this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: this.createdAt,
      lastLoginAt: lastLoginAt ?? DateTime.now(),
      settings: settings ?? this.settings,
      name: '',
    );
  }

  // Update user settings
  UserModel updateSettings(Map<String, dynamic> newSettings) {
    return copyWith(
      settings: {...settings, ...newSettings},
      lastLoginAt: DateTime.now(),
    );
  }

  // Validation methods
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Display name is optional
    }
    if (value.length < 3) {
      return 'Display name must be at least 3 characters';
    }
    if (value.length > 50) {
      return 'Display name must be less than 50 characters';
    }
    return null;
  }
}