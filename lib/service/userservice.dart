import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _users => _firestore.collection('users');

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final doc = await _users.doc(currentUser.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Create new user
  Future<void> createUser(UserModel user) async {
    try {
      await _users.doc(user.id).set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      throw e;
    }
  }

  // Update user data
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _users.doc(userId).update(data);
    } catch (e) {
      print('Error updating user: $e');
      throw e;
    }
  }

  // Update user settings
  Future<void> updateUserSettings(String userId, Map<String, dynamic> newSettings) async {
    try {
      final userRef = _users.doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final UserModel user = UserModel.fromFirestore(userDoc);
      final updatedUser = user.updateSettings(newSettings);

      await userRef.update({'settings': updatedUser.settings});
    } catch (e) {
      print('Error updating user settings: $e');
      throw e;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Query tasks collection to get statistics
      final tasksRef = _firestore.collection('tasks').where('userId', isEqualTo: userId);
      final tasks = await tasksRef.get();

      final totalTasks = tasks.docs.length;
      final completedTasks = tasks.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['completed'] == true;
      }).length;

      return {
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'pendingTasks': totalTasks - completedTasks,
        'completionRate': totalTasks > 0 ? (completedTasks / totalTasks) : 0,
      };
    } catch (e) {
      print('Error getting user statistics: $e');
      return {
        'totalTasks': 0,
        'completedTasks': 0,
        'pendingTasks': 0,
        'completionRate': 0,
      };
    }
  }

  // Get user recent activity
  Future<List<Map<String, dynamic>>> getUserActivity(String userId, {int limit = 10}) async {
    try {
      final activityRef = _firestore
          .collection('activity')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      final activity = await activityRef.get();

      return activity.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'type': data['type'],
          'description': data['description'],
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      print('Error getting user activity: $e');
      return [];
    }
  }

  // Delete user account
  Future<void> deleteUser(String userId) async {
    try {
      // Delete user document
      await _users.doc(userId).delete();

      // Delete user's tasks
      final tasksRef = _firestore.collection('tasks').where('userId', isEqualTo: userId);
      final tasks = await tasksRef.get();

      for (var doc in tasks.docs) {
        await doc.reference.delete();
      }

      // Delete user's activity
      final activityRef = _firestore.collection('activity').where('userId', isEqualTo: userId);
      final activities = await activityRef.get();

      for (var doc in activities.docs) {
        await doc.reference.delete();
      }

      // Delete Firebase Auth user
      final User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      print('Error deleting user: $e');
      throw e;
    }
  }
}