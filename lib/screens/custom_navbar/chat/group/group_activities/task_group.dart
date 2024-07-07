import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  final String title;
  final String description;
  final int points;
  final List<String> images;
  final String status;

  Task({
    this.id = '',
    required this.title,
    required this.description,
    required this.points,
    required this.images,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'points': points,
      'images': images,
      'status': status,
    };
  }

  static Task fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      points: data['points'],
      images: List<String>.from(data['images']),
      status: data['status'],
    );
  }
}
