import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'redeem_voucher_page.dart';

class TotalPointsPage extends StatefulWidget {
  final int totalPoints;
  final List<Map<String, dynamic>> completedTasks;
  final String userId;

  TotalPointsPage({
    required this.totalPoints,
    required this.completedTasks,
    required this.userId,
  });

  @override
  _TotalPointsPageState createState() => _TotalPointsPageState();
}

class _TotalPointsPageState extends State<TotalPointsPage> {
  late int totalPoints;
  late int completedTasksCount;

  @override
  void initState() {
    super.initState();
    totalPoints = widget.totalPoints;
    completedTasksCount = widget.completedTasks.length;
  }

  void updatePoints(int points) {
    setState(() {
      totalPoints = points;
    });
  }

  Future<void> updateCompletedTasksCount(int count) async {
    setState(() {
      completedTasksCount = count;
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'completedTasksCount': count});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 48.0),
              child: Text(
                'Points History',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 18.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTotalPointsBox(),
            SizedBox(height: 20),
            _buildCompletedTasksCountBox(),
            SizedBox(height: 20),
            Expanded(child: _buildCompletedTasksBox()),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.green[800]!,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16.sp, color: Colors.green[800]),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final points = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RedeemVoucherPage(
                            userId: widget.userId,
                            initialPoints: totalPoints,
                          ),
                        ),
                      );
                      if (points != null) {
                        updatePoints(points);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Redeem Voucher',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16.sp, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPointsBox() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green[800],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 10.0,
            ),
          ],
        ),
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.currency_exchange_outlined,
              color: Colors.white,
              size: 40.0,
            ),
            SizedBox(width: 10),
            Text(
              'Total Points: $totalPoints',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 20.sp, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTasksCountBox() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green[800],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 10.0,
            ),
          ],
        ),
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 40.0,
            ),
            SizedBox(width: 10),
            Text(
              'Completed Tasks: $completedTasksCount',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 20.sp, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTasksBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[800],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 10.0,
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0),
      child: widget.completedTasks.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              itemCount: widget.completedTasks.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(
                        IconData(widget.completedTasks[index]['icon'], fontFamily: 'MaterialIcons'),
                        color: Colors.green[800],
                        size: 30,
                      ),
                      title: Text(
                        widget.completedTasks[index]['task'],
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14.sp, color: Colors.black87),
                      ),
                      subtitle: Text(
                        '${widget.completedTasks[index]['points']} points',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 16.sp, color: Colors.black54),
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text(
                'No tasks completed yet.',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 16.sp, color: Colors.white),
              ),
            ),
    );
  }
}
