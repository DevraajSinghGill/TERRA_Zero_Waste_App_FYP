import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:terra_zero_waste_app/gamification/redeem_voucher_page.dart';
import 'package:terra_zero_waste_app/gamification/total_points_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'activity_card.dart'; // Import the ActivityCard widget

class ZeroWasteActivities extends StatefulWidget {
  @override
  _ZeroWasteActivitiesState createState() => _ZeroWasteActivitiesState();
}

class _ZeroWasteActivitiesState extends State<ZeroWasteActivities>
    with SingleTickerProviderStateMixin {
  int totalPoints = 0;
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  GlobalKey _totalPointsKey = GlobalKey();
  List<Map<String, dynamic>> completedTasks = [];
  late String userId;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
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
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          totalPoints = userDoc['totalPoints'] ?? 0;
        });

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
                  })
              .toList();
        });
      }
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
      setState(() {
        completedTasks.add({'task': task, 'points': points, 'icon': iconPath});
      });
      _saveTaskToFirestore(user.uid, task, points, iconPath);
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
        _totalPointsKey.currentContext!.findRenderObject() as RenderBox;
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
      setState(() {
        totalPoints += points;
      });
    });
  }

  void _saveTaskToFirestore(
      String uid, String task, int points, String iconPath) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('completedTasks')
          .add({
        'task': task,
        'points': points,
        'icon': iconPath,
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
                  ActivityCard(
                    title: 'Carry out Composting',
                    description:
                        'Set up a compost bin at home and start composting food scraps and yard waste for a month.',
                    iconPath: 'lib/assets/gif_icons/composting.gif',
                    imagePath: '',
                    points: 100,
                    onComplete: () => completeTask('Carry out Composting', 100,
                        'lib/assets/gif_icons/composting.gif'),
                  ),
                  SizedBox(height: 8),
                  ActivityCard(
                    title: 'Use Reusable Bags',
                    description:
                        'Bring your own reusable shopping bags to the store.',
                    iconPath: 'lib/assets/gif_icons/shopping_bag.gif',
                    imagePath: '',
                    points: 100,
                    onComplete: () => completeTask('Use Reusable Bags', 100,
                        'lib/assets/gif_icons/shopping_bag.gif'),
                  ),
                  SizedBox(height: 8),
                  ActivityCard(
                    title: 'Donate Items Away',
                    description:
                        'Donate items such as clothes, furniture, and other items you no longer need to a local thrift store or charity.',
                    iconPath: 'lib/assets/gif_icons/charity.gif',
                    imagePath: '',
                    points: 100,
                    onComplete: () => completeTask('Donate Items Away', 100,
                        'lib/assets/gif_icons/charity.gif'),
                  ),
                  SizedBox(height: 8),
                  ActivityCard(
                    title: 'Carpool',
                    description:
                        'Organize and participate in carpooling with friends and family to reduce the number of vehicles on the road',
                    iconPath: 'lib/assets/gif_icons/mini-car.gif',
                    imagePath: '',
                    points: 100,
                    onComplete: () => completeTask(
                        'Carpool', 100, 'lib/assets/gif_icons/mini-car.gif'),
                  ),
                  SizedBox(height: 8),
                  ActivityCard(
                    title: 'Collect Rainwater',
                    description:
                        'Set up a rainwater harvesting system and use the collected water for watering your garden and plants.',
                    iconPath: 'lib/assets/gif_icons/water.gif',
                    imagePath: '',
                    points: 100,
                    onComplete: () => completeTask('Collect Rainwater', 100,
                        'lib/assets/gif_icons/water.gif'),
                  ),
                  SizedBox(height: 8),
                  ActivityCard(
                    title: 'Use Public Transport',
                    description:
                        'Use public transportation for your daily commute for a month.',
                    iconPath: 'lib/assets/gif_icons/train.gif',
                    imagePath: '',
                    points: 100,
                    onComplete: () => completeTask('Use Public Transport', 100,
                        'lib/assets/gif_icons/train.gif'),
                  ),
                  SizedBox(height: 8),
                  ActivityCard(
                    title: 'Do a Meal Plan',
                    description:
                        'Plan your meals for a week to minimize food waste and leftovers.',
                    iconPath: 'lib/assets/gif_icons/meal_plan.gif',
                    imagePath: '',
                    points: 100,
                    onComplete: () => completeTask('Do a Meal Plan', 100,
                        'lib/assets/gif_icons/meal_plan.gif'),
                  ),
                  SizedBox(height: 8),
                  ActivityCard(
                    title: 'Reusable Water Bottle',
                    description:
                        'Carry and use a reusable water bottle for a month instead of buying bottled water.',
                    iconPath: 'lib/assets/gif_icons/bottle.gif',
                    imagePath: '',
                    points: 100,
                    onComplete: () => completeTask('Reusable Water Bottle', 100,
                        'lib/assets/gif_icons/bottle.gif'),
                  ),
                  SizedBox(height: 8),
                  ActivityCard(
                    title: 'Grow Your Own Food',
                    description:
                        'Create and use your own cleaning products using natural ingredients.',
                    iconPath: 'lib/assets/gif_icons/plant.gif',
                    imagePath: '',
                    points: 100,
                    onComplete: () => completeTask('Grow Your Own Food', 100,
                        'lib/assets/gif_icons/plant.gif'),
                  ),
                  SizedBox(height: 8),
                  ActivityCard(
                    title: 'DIY Cleaning Products',
                    description:
                        'Create and use your own cleaning products using natural ingredients.',
                    iconPath: 'lib/assets/gif_icons/cleaning.gif',
                    imagePath: '',
                    points: 100,
                    onComplete: () => completeTask('DIY Cleaning Products', 100,
                        'lib/assets/gif_icons/cleaning.gif'),
                  ),
                  SizedBox(height: 8),
                  // Add more activity cards here
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
