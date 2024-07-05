import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TotalPointsPage extends StatefulWidget {
  final int totalPoints;
  final List<Map<String, dynamic>> completedTasks;
  final String userId;
  final int pointsPerTask;

  TotalPointsPage({
    required this.totalPoints,
    required this.completedTasks,
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
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPointsSection(),
            SizedBox(height: 20),
            _buildCompletedTasksSection(),
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
          Text(
            'Total Points',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.green[900],
            ),
          ),
          SizedBox(height: 10),
          Text(
            '${widget.totalPoints}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: Colors.green[900],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Total Completed Tasks: $totalCompletedTasks',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTasksSection() {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.completedTasks.length,
        itemBuilder: (context, index) {
          final task = widget.completedTasks[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: task['icon'] != null
                  ? Image.asset(
                      task['icon'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.check_circle, size: 50, color: Colors.green),
              title: Text(
                task['task'],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                '${task['points']} points',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
