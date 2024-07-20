import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_group.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Task> _pendingTasks = [];
  List<Task> _completedTasks = [];
  String? _groupId;
  String? _userId; // Variable to store user ID

  List<Task> get pendingTasks => _pendingTasks;
  List<Task> get completedTasks => _completedTasks;

  void setGroupId(String groupId) {
    _groupId = groupId;
    fetchTasks();
  }

  void setUserId(String userId) {
    _userId = userId;
  }

  Future<void> fetchTasks() async {
    if (_groupId == null) return;

    final snapshot = await _firestore.collection('groupChats').doc(_groupId).collection('tasks').get();
    _pendingTasks = snapshot.docs
        .map((doc) => Task.fromFirestore(doc))
        .where((task) => task.status == 'pending')
        .toList();
    _completedTasks = snapshot.docs
        .map((doc) => Task.fromFirestore(doc))
        .where((task) => task.status == 'completed')
        .toList();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    if (_groupId == null) return;

    final docRef = await _firestore.collection('groupChats').doc(_groupId).collection('tasks').add(task.toMap());
    task.id = docRef.id;  // Assign the document ID to the task
    _pendingTasks.add(task);
    notifyListeners();
  }

  Future<void> completeTask(Task task) async {
    if (_groupId == null || _userId == null) return;

    // Update task status to completed
    await _firestore.collection('groupChats').doc(_groupId).collection('tasks').doc(task.id).update({'status': 'completed'});
    _pendingTasks.remove(task);
    _completedTasks.add(task);

    // Fetch the current combined points for the user
    final userDoc = await _firestore.collection('users').doc(_userId).get();
    int currentCombinedPoints = userDoc.data()?['combinedPoints'] ?? 0;

    // Update the combined points
    int updatedCombinedPoints = currentCombinedPoints + task.points;
    await _firestore.collection('users').doc(_userId).update({'combinedPoints': updatedCombinedPoints});

    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    if (_groupId == null || updatedTask.id == null) return;

    await _firestore.collection('groupChats').doc(_groupId).collection('tasks').doc(updatedTask.id).update(updatedTask.toMap());
    int index = _pendingTasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _pendingTasks[index] = updatedTask;
    } else {
      index = _completedTasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _completedTasks[index] = updatedTask;
      }
    }
    notifyListeners();
  }

  Future<void> deleteTask(Task task) async {
    if (_groupId == null || task.id == null) return;

    await _firestore.collection('groupChats').doc(_groupId).collection('tasks').doc(task.id).delete();
    _pendingTasks.removeWhere((t) => t.id == task.id);
    _completedTasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }
}
