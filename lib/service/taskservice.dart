import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'authservice.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tasks';
  final AuthService _authService;

  // Singleton pattern
  static TaskService? _instance;

  // Private constructor
  TaskService._internal(this._authService);

  // Factory method to get instance
  static Future<TaskService> getInstance() async {
    if (_instance == null) {
      final authService = await AuthService.getInstance();
      _instance = TaskService._internal(authService);
    }
    return _instance!;
  }

  // Get user's tasks
  Stream<List<Task>> getTasks() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Task.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Get single task
  Future<Task> getTask(String taskId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection(_collection).doc(taskId).get();
    if (!doc.exists) throw Exception('Task not found');

    final task = Task.fromMap(doc.data()!, doc.id);
    if (task.userId != userId) throw Exception('Unauthorized access');

    return task;
  }

  // Create task
  Future<String> createTask(Task task) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final taskMap = task.toMap()..['userId'] = userId;
    final docRef = await _firestore.collection(_collection).add(taskMap);
    return docRef.id;
  }

  // Update task
  Future<void> updateTask(Task task) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final existingTask = await getTask(task.id);
    if (existingTask.userId != userId) throw Exception('Unauthorized access');

    await _firestore
        .collection(_collection)
        .doc(task.id)
        .update(task.toMap());
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final existingTask = await getTask(taskId);
    if (existingTask.userId != userId) throw Exception('Unauthorized access');

    await _firestore.collection(_collection).doc(taskId).delete();
  }

  // Get task statistics
  Future<Map<String, dynamic>> getTaskStatistics() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();

    final tasks = snapshot.docs.map((doc) => Task.fromMap(doc.data(), doc.id));

    return {
      'total': tasks.length,
      'completed': tasks.where((task) => task.isCompleted).length,
      'pending': tasks.where((task) => !task.isCompleted).length,
      'highPriority': tasks.where((task) => task.priority == 'high').length,
      'mediumPriority': tasks.where((task) => task.priority == 'medium').length,
      'lowPriority': tasks.where((task) => task.priority == 'low').length,
    };
  }

  // Get tasks by priority
  Stream<List<Task>> getTasksByPriority(String priority) {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('priority', isEqualTo: priority)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Task.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Get tasks by date range
  Stream<List<Task>> getTasksByDateRange(DateTime start, DateTime end) {
    final userId = _authService.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('dueDate', isGreaterThanOrEqualTo: start)
        .where('dueDate', isLessThanOrEqualTo: end)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Task.fromMap(doc.data(), doc.id))
        .toList());
  }
}