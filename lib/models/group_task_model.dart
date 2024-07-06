class GroupTaskModel {
  String taskId;
  String groupId;
  String taskName;
  String description;
  int points;
  String imageUrl;
  bool completed;

  GroupTaskModel({
    required this.taskId,
    required this.groupId,
    required this.taskName,
    required this.description,
    required this.points,
    required this.imageUrl,
    this.completed = false,
  });

  factory GroupTaskModel.fromMap(Map<String, dynamic> map) {
    return GroupTaskModel(
      taskId: map['taskId'],
      groupId: map['groupId'],
      taskName: map['taskName'],
      description: map['description'],
      points: map['points'],
      imageUrl: map['imageUrl'],
      completed: map['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'groupId': groupId,
      'taskName': taskName,
      'description': description,
      'points': points,
      'imageUrl': imageUrl,
      'completed': completed,
    };
  }
}
