import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TotalPointsPage extends StatefulWidget {
  final int totalPoints;
  final String userId;
  final int pointsPerTask;

  TotalPointsPage({
    required this.totalPoints,
    required this.userId,
    required this.pointsPerTask,
  });

  @override
  _TotalPointsPageState createState() => _TotalPointsPageState();
}

class _TotalPointsPageState extends State<TotalPointsPage> {
  late int totalCompletedTasks;

  @override
  void initState() {
    super.initState();
    _initializeCompletedTasks();
  }

  Future<void> _initializeCompletedTasks() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the stored points per task and completed tasks count
    int storedPointsPerTask = prefs.getInt('${widget.userId}_pointsPerTask') ?? widget.pointsPerTask;
    int storedCompletedTasks = prefs.getInt('${widget.userId}_completedTasks') ?? 0;

    // Calculate completed tasks with current points per task
    int calculatedCompletedTasks = widget.totalPoints ~/ widget.pointsPerTask;

    // Ensure that the total completed tasks doesn't decrease
    if (widget.pointsPerTask == storedPointsPerTask) {
      totalCompletedTasks = calculatedCompletedTasks > storedCompletedTasks
          ? calculatedCompletedTasks
          : storedCompletedTasks;
    } else {
      // If points per task have changed, recalculate the completed tasks
      totalCompletedTasks = calculatedCompletedTasks;
    }

    // Update the stored values if necessary
    if (totalCompletedTasks > storedCompletedTasks || widget.pointsPerTask != storedPointsPerTask) {
      await prefs.setInt('${widget.userId}_completedTasks', totalCompletedTasks);
      await prefs.setInt('${widget.userId}_pointsPerTask', widget.pointsPerTask);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Total Points',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPointsSection(),
            SizedBox(height: 20),
            _buildCompletedTasksSection(),
            SizedBox(height: 20),
            Expanded(child: _buildCompletedTasksBox()),  // Make the list scrollable within the remaining space
          ],
        ),
      ),
    );
  }

  Widget _buildPointsSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: Colors.green[900], size: 28),
              SizedBox(width: 10),
              Text(
                'Total Points',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.green[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '${widget.totalPoints}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w900,
              fontSize: 28,  // Adjusted font size
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTasksSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[900], size: 28),
              SizedBox(width: 10),
              Text(
                'Total Completed Tasks',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.green[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '$totalCompletedTasks',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w900,
              fontSize: 28,  // Adjusted font size
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTasksBox() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('completedTasks')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var completedTasks = snapshot.data!.docs.map((doc) {
          return {
            'task': doc['task'],
            'points': _parsePoints(doc['points']),
            'icon': _parseIcon(doc['icon']),
          };
        }).toList();

        if (completedTasks.isEmpty) {
          return Center(
            child: Text(
              'No tasks completed yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: completedTasks.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 229, 245, 224),
                      Color.fromARGB(255, 204, 235, 197),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Icon(
                      IconData(completedTasks[index]['icon'], fontFamily: 'MaterialIcons'),
                      color: Colors.green[800],
                      size: 24,
                    ),
                  ),
                  title: Text(
                    completedTasks[index]['task'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    '${completedTasks[index]['points']} points',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _parsePoints(dynamic points) {
    if (points is int) {
      return points;
    } else if (points is String) {
      return int.tryParse(points) ?? 0;
    } else {
      return 0;
    }
  }

  int _parseIcon(dynamic icon) {
    if (icon is int) {
      return icon;
    } else if (icon is String) {
      return int.tryParse(icon) ?? Icons.task.codePoint;
    } else {
      return Icons.task.codePoint;
    }
  }
}
