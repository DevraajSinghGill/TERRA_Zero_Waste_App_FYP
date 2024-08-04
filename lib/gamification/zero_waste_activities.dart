import 'dart:io';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activity_card.dart'; // Import the ActivityCard widget
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:firebase_storage/firebase_storage.dart'; // Import for Firebase Storage

class ZeroWasteActivities extends StatefulWidget {
  @override
  _ZeroWasteActivitiesState createState() => _ZeroWasteActivitiesState();
}

class _ZeroWasteActivitiesState extends State<ZeroWasteActivities> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  List<Map<String, dynamic>> completedTasks = [];
  List<Map<String, dynamic>> activities = [];
  String? userId;
  String? username;
  String selectedDay = 'All';

  final List<String> daysOfWeek = [
    'All',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -2),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fetchUserData();
    _fetchActivities();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        userId = user.uid;
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          username = userDoc['username'];
          QuerySnapshot completedTasksSnapshot = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('completedTasks')
              .get();
          setState(() {
            completedTasks = completedTasksSnapshot.docs
                .map((doc) => {
                      'task': doc['task'],
                      'points': doc['points'],
                      'icon': doc['icon'],
                      'completionDate': doc['completionDate'], 
                    })
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      
    }
  }

  Future<void> _fetchActivities() async {
    try {
      QuerySnapshot activitiesSnapshot = await _firestore.collection('zeroActivities').get();
      setState(() {
        activities = activitiesSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'title': data['title'] ?? 'No Title',
            'description': data['description'] ?? 'No Description',
            'iconPath': data['iconPath'] ?? 'https://example.com/default-icon.png',
            'points': data['points'] ?? 0,
            'days': List<String>.from(data['days'] ?? []), 
          };
        }).toList();
      });
      print('Fetched activities: $activities');
    } catch (e) {
      print('Error fetching activities: $e');
      
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void completeTask(String task, int points, String iconPath) {
    User? user = _auth.currentUser;
    if (user != null) {
      String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      bool alreadyCompleted = completedTasks.any((completedTask) =>
          completedTask['task'] == task && completedTask['completionDate'] == todayDate);

      if (alreadyCompleted) {
        _showAlreadyCompletedDialog(task);
        return;
      }

      setState(() {
        completedTasks.add({'task': task, 'points': points, 'icon': iconPath, 'completionDate': todayDate});
      });
      _saveTaskToPending(user.uid, task, points, iconPath, todayDate, username!);
      _showPendingApprovalDialog(task, points);
    } else {

      print('User not signed in');
    }
  }

  void _showConfetti() {
    _confettiController.play();
  }

  void _showPointsFlyAnimation(int points) {
    RenderBox renderBox =
        context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    double targetX = offset.dx + renderBox.size.width / 2;
    double targetY = offset.dy;

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: targetY - 50,
        left: targetX - 10,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Material(
            color: Colors.transparent,
            child: Text(
              '+$points',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(overlayEntry);

    _animationController.forward().then((value) {
      overlayEntry.remove();
      _animationController.reset();
    });
  }

  void _saveTaskToPending(
      String uid, String task, int points, String iconPath, String completionDate, String username) async {
    try {
      await _firestore
          .collection('pendingTasks')
          .add({
        'username': username,
        'uid': uid,
        'task': task,
        'points': points,
        'icon': iconPath,
        'completionDate': completionDate,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      print('Error saving task to pending tasks: $e');
    }
  }

  void _showPendingApprovalDialog(String task, int points) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.all(12.0),
          backgroundColor: Colors.white, 
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/pending_task.gif?alt=media&token=fdd5bd7e-a8a5-4d90-a80c-197035a28399',
                height: 150,
                width: 150,
              ),
              SizedBox(height: 15),
              Text(
                'Task Pending Approval',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.sp,
                  color: Colors.black, 
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your task "$task" is pending approval. You will be notified once it has been reviewed.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 10.sp,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                ),
                child: Text(
                  'CLOSE',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w900,
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAlreadyCompletedDialog(String task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.all(12.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error,
                size: 50,
                color: Colors.red,
              ),
              SizedBox(height: 15),
              Text(
                'Task Already Completed!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.sp,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You have already completed the task: $task today.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 10.sp,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                ),
                child: Text(
                  'CLOSE',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w900,
                    fontSize: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Tasks',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w900,
            fontSize: 14.sp,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildDescriptionBox(context),
                  SizedBox(height: 20),
                  _buildDayFilter(), // Place the day filter here
                  SizedBox(height: 20),
                  _buildActivityCards(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
              numberOfParticles: 100,
              maxBlastForce: 150,
              minBlastForce: 50,
              emissionFrequency: 0.01,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayFilter() {
    return Container(
      height: 65,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: daysOfWeek.length,
        itemBuilder: (context, index) {
          final day = daysOfWeek[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDay = day;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: selectedDay == day ? Colors.teal : Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Colors.teal),
              ),
              child: Center(
                child: Text(
                  day,
                  style: GoogleFonts.poppins(
                    fontSize: 14, // Increased font size
                    color: selectedDay == day ? Colors.white : Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityCards() {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    final filteredActivities = selectedDay == 'All'
        ? activities
        : activities.where((activity) => activity['days'].contains(selectedDay)).toList();

    if (filteredActivities.isEmpty) {
      return Center(child: Text('No activities available for the selected day.'));
    }

    return Column(
      children: filteredActivities.map((activity) {
        bool isCompletedToday = completedTasks.any((completedTask) =>
          completedTask['task'] == activity['title'] && completedTask['completionDate'] == todayDate);

        return ActivityCard(
          title: activity['title'],
          description: activity['description'],
          iconPath: activity['iconPath'],
          imagePath: '', // You can add logic to handle imagePath if needed
          points: activity['points'],
          onComplete: () => completeTask(activity['title'], activity['points'], activity['iconPath']),
          disabled: isCompletedToday,
        );
      }).toList(),
    );
  }

  Widget _buildDescriptionBox(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('lib/assets/images/gardening.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5), BlendMode.darken),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earn Rewards for Zero Waste Actions',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w900,
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Complete zero-waste tasks to earn points! From composting to using reusable bags, every action you take helps the environment and earns you points.',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 10.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
