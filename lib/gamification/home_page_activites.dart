import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:terra_zero_waste_app/gamification/redeem_voucher_page.dart';
import 'package:terra_zero_waste_app/gamification/total_points_page.dart';
import 'package:terra_zero_waste_app/gamification/zero_waste_activities.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePageActivities extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    return FutureBuilder<int>(
      future: _getCombinedPoints(user.uid),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildScaffoldWithAppBar(
            context,
            'Home TERRA Activities',
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return _buildScaffoldWithAppBar(
            context,
            'Home TERRA Activities',
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        } else if (snapshot.hasData) {
          int combinedPoints = snapshot.data ?? 0;

          return StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('users').doc(user.uid).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return _buildScaffoldWithAppBar(
                  context,
                  'Home TERRA Activities',
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (userSnapshot.hasError) {
                return _buildScaffoldWithAppBar(
                  context,
                  'Home TERRA Activities',
                  body: Center(child: Text("Error: ${userSnapshot.error}")),
                );
              } else if (userSnapshot.hasData && userSnapshot.data!.exists) {
                Map<String, dynamic> userData =
                    userSnapshot.data?.data() as Map<String, dynamic>;
                String formattedName = _formatName(userData['username'] ?? '');

                return _buildScaffoldWithAppBar(
                  context,
                  'TERRA Activities',
                  body: _buildUserInterface(context, formattedName, combinedPoints),
                );
              } else {
                return _buildScaffoldWithAppBar(
                  context,
                  'TERRA Activities',
                  body: Center(child: Text("No user data available")),
                );
              }
            },
          );
        } else {
          return _buildScaffoldWithAppBar(
            context,
            'TERRA Activities',
            body: Center(child: Text("No points data available")),
          );
        }
      },
    );
  }

  Future<int> _getCombinedPoints(String userId) async {
    int totalPoints = 0;
    int taskPoints = 0;

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        totalPoints = (userDoc.data() as Map<String, dynamic>)['totalPoints']?.toInt() ?? 0;
      }

      QuerySnapshot taskSnapshot = await _firestore.collection('tasks').get();
      for (QueryDocumentSnapshot doc in taskSnapshot.docs) {
        Map<String, dynamic> taskData = doc.data() as Map<String, dynamic>;
        taskPoints += (taskData['points'] ?? 0) as int;
      }

      return totalPoints + taskPoints;
    } catch (e) {
      print('Error fetching combined points: $e');
      return 0;
    }
  }

  Scaffold _buildScaffoldWithAppBar(BuildContext context, String title,
      {required Widget body}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: body,
      backgroundColor: Colors.white, // Set background color to white
    );
  }

  Widget _buildUserInterface(
      BuildContext context, String formattedName, int combinedPoints) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10),
          _buildWelcomeSection(formattedName),
          SizedBox(height: 10),
          _buildPointsSection(combinedPoints),
          SizedBox(height: 20),
          _buildOptionCard(
            context,
            'View Catalog of Activities',
            'image_icon.gif', // Firebase Storage path
            'Explore various activities to promote zero waste and earn more points.',
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ZeroWasteActivities())),
            Colors.green[800]!,
            Colors.green[900]!,
          ),
          SizedBox(height: 20),
          _buildOptionCard(
            context,
            'View Total Points',
            'history.gif', // Firebase Storage path
            'Review your accumulated points and completed tasks.',
            () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TotalPointsPage(
                        totalPoints: combinedPoints,
                        userId: _auth.currentUser!.uid))),
            Colors.green[800]!,
            Colors.green[900]!,
          ),
          SizedBox(height: 20),
          _buildRedeemSection(context, combinedPoints),
        ],
      ),
    );
  }

  String _formatName(String fullName) {
    return fullName
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
        .join(' ');
  }

  Widget _buildWelcomeSection(String userName) {
    return FutureBuilder<String>(
      future: _getGifUrl('mother-earth-day.gif'), // Firebase Storage path
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Hello, $userName ",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black)),
              CircularProgressIndicator(),
            ],
          );
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("Hello, $userName ",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.black)),
                  Container(
                    width: 50,
                    height: 50,
                    child: Image.network(snapshot.data ?? '', fit: BoxFit.cover),
                  ),
                ],
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPointsSection(int combinedPoints) {
    return FutureBuilder<String>(
      future: _getGifUrl('money-bag.gif'), // Firebase Storage path
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: _buildBoxDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconContainer(snapshot.data ?? '', 50.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'You have ',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.green[900]),
                          children: <TextSpan>[
                            TextSpan(
                              text: '$combinedPoints',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 217, 25, 25)),
                            ),
                            TextSpan(
                              text: ' points',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.green[900]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'remaining',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            color: Colors.green[900]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildRedeemSection(BuildContext context, int combinedPoints) {
    return FutureBuilder<String>(
      future: _getGifUrl('coupon.gif'), // Firebase Storage path
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!]),
            ),
            child: Column(
              children: [
                _buildIconContainer(snapshot.data ?? '', 70.0),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RedeemVoucherPage(
                                userId: _auth.currentUser!.uid,
                                initialPoints: combinedPoints)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text('Redeem Now',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white)),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text('Use this QR code when you checkout to get points',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.white),
                    textAlign: TextAlign.center),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildOptionCard(
      BuildContext context,
      String title,
      String gifPath,
      String description,
      VoidCallback onTap,
      Color startColor,
      Color endColor) {
    return FutureBuilder<String>(
      future: _getGifUrl(gifPath), // Firebase Storage path
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildIconContainer(snapshot.data ?? '', 50.0),
                        SizedBox(width: 20),
                        Expanded(
                          child: Text(title,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white)),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: Colors.white, size: 20),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(description,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.white70)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3))
      ],
      gradient: LinearGradient(
        colors: [Colors.lightGreenAccent[100]!, Colors.green[200]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  Widget _buildIconContainer(String gifUrl, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, 3))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(gifUrl, fit: BoxFit.cover),
      ),
    );
  }

  Future<String> _getGifUrl(String fileName) async {
    try {
      return await FirebaseStorage.instance.ref(fileName).getDownloadURL();
    } catch (e) {
      print('Error loading GIF icon: $e');
      return '';
    }
  }
}
