import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_group.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Task> _pendingTasks = [];
  List<Task> _completedTasks = [];
  String? _groupId;

  List<Task> get pendingTasks => _pendingTasks;
  List<Task> get completedTasks => _completedTasks;

  TaskProvider() {
  }

  void setGroupId(String groupId) {
    _groupId = groupId;
    fetchTasks();
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
    if (_groupId == null) return;

    await _firestore.collection('groupChats').doc(_groupId).collection('tasks').doc(task.id).update({'status': 'completed'});
    _pendingTasks.remove(task);
    _completedTasks.add(task);
    notifyListeners();
  }
}
