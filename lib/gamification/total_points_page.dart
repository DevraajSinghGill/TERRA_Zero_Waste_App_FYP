import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TotalPointsPage extends StatelessWidget {
  final int totalPoints;
  final List<Map<String, dynamic>> completedTasks;
  final String userId;
  final int totalCompletedTasks;

  TotalPointsPage({
    required this.totalPoints,
    required this.completedTasks,
    required this.userId,
  }) : totalCompletedTasks = calculateTotalCompletedTasks(totalPoints);

  static int calculateTotalCompletedTasks(int totalPoints) {
    const int pointsPerTask = 10; // Assuming each task gives 10 points
    return totalPoints ~/ pointsPerTask;
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
            '$totalPoints',
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
        itemCount: completedTasks.length,
        itemBuilder: (context, index) {
          final task = completedTasks[index];
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
