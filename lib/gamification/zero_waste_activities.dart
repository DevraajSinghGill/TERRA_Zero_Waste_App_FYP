import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activity_card.dart'; // Import the ActivityCard widget
import 'package:intl/intl.dart'; // Import for date formatting

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
                      'completionDate': doc['completionDate'], // Add completionDate
                    })
                .toList();
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Handle error accordingly (e.g., show a message to the user)
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
            'days': List<String>.from(data['days'] ?? []), // Fetch days field
          };
        }).toList();
      });
      print('Fetched activities: $activities');
    } catch (e) {
      print('Error fetching activities: $e');
      // Handle error accordingly (e.g., show a message to the user)
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
      _saveTaskToFirestore(user.uid, task, points, iconPath, todayDate);
      _updateUserPoints(user.uid, points);
      _showSuccessDialog(task, points);
    } else {
      // Prompt user to sign in
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

  void _saveTaskToFirestore(
      String uid, String task, int points, String iconPath, String completionDate) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('completedTasks')
          .add({
        'task': task,
        'points': points,
        'icon': iconPath,
        'completionDate': completionDate, // Save completionDate
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving task to Firestore: $e');
    }
  }

  void _updateUserPoints(String uid, int points) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'totalPoints': FieldValue.increment(points),
      });
    } catch (e) {
      print('Error updating user points: $e');
    }
  }

  void _showSuccessDialog(String task, int points) {
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
              Image.asset(
                'lib/assets/gif_icons/tick.gif',
                height: 150,
                width: 150,
              ),
              SizedBox(height: 15),
              Text(
                'Congratulations!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.sp,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You have successfully completed the task: $task',
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
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
    ).then((_) {
      _showConfetti();
      _showPointsFlyAnimation(points);
    });
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
