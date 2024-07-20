import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:terra_zero_waste_app/gamification/redeem_voucher_page.dart';
import 'package:terra_zero_waste_app/gamification/review_task/review_task_status_page.dart';
import 'package:terra_zero_waste_app/gamification/review_voucher/review_voucher_page_user.dart';
import 'package:terra_zero_waste_app/gamification/zero_waste_activities.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePageActivities extends StatefulWidget {
  @override
  _HomePageActivitiesState createState() => _HomePageActivitiesState();
}

class _HomePageActivitiesState extends State<HomePageActivities> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

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
          Map<String, dynamic> userData = userSnapshot.data?.data() as Map<String, dynamic>;
          String formattedName = _formatName(userData['username'] ?? '');

          return StreamBuilder<int>(
            stream: _getCombinedPointsStream(user.uid),
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

                return _buildScaffoldWithAppBar(
                  context,
                  'TERRA Activities',
                  body: _buildUserInterface(context, formattedName, combinedPoints),
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
        } else {
          return _buildScaffoldWithAppBar(
            context,
            'TERRA Activities',
            body: Center(child: Text("No user data available")),
          );
        }
      },
    );
  }

  Stream<int> _getCombinedPointsStream(String userId) async* {
    final userDocStream = _firestore.collection('users').doc(userId).snapshots();
    final tasksStream = _firestore.collection('tasks').snapshots();

    await for (var userDocSnapshot in userDocStream) {
      if (userDocSnapshot.exists) {
        int combinedPoints = (userDocSnapshot.data() as Map<String, dynamic>)['combinedPoints']?.toInt() ?? 0;
        yield combinedPoints;
      } else {
        yield 0;
      }
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
          _buildTabSection(context, combinedPoints), // Pass combinedPoints here
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
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/earth_banner_icon.gif?alt=media&token=4102ccf2-e0b9-4fe0-85aa-1ceed9c76d3d',
                fit: BoxFit.cover,
              ),
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

  Widget _buildPointsSection(int combinedPoints) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _buildBoxDecoration(),
      child: Column(
        children: [
          _buildIconContainer(
            'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/money-bag.gif?alt=media&token=1c2de905-fce2-476a-bd7c-03b5d3220193',
            70.0,
          ),
          SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'You have ',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Colors.green[900]),
              children: <TextSpan>[
                TextSpan(
                  text: '$combinedPoints',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Color.fromARGB(255, 217, 25, 25)),
                ),
                TextSpan(
                  text: ' points',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.green[900]),
                ),
              ],
            ),
          ),
          Text(
            'remaining',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.green[900]),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(BuildContext context, int combinedPoints) {
    List<String> statuses = ["Activities", "Voucher"];
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(20),
            fillColor: _getToggleColor(_selectedIndex),
            selectedColor: Colors.white,
            color: Colors.teal,
            selectedBorderColor: _getToggleColor(_selectedIndex),
            borderColor: Colors.teal,
            isSelected: statuses.map((status) => statuses[_selectedIndex] == status).toList(),
            onPressed: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: statuses.map((status) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: statuses[_selectedIndex] == status ? Colors.white : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20),
        IndexedStack(
          index: _selectedIndex,
          children: [
            _buildActivitiesTab(context),
            _buildVoucherTab(context, combinedPoints),
          ],
        ),
      ],
    );
  }

  Color _getToggleColor(int selectedIndex) {
    return selectedIndex == 0 ? Colors.orange : Colors.green;
  }

  Widget _buildActivitiesTab(BuildContext context) {
    return Column(
      children: [
        _buildOptionCard(
          context,
          'View Catalog of Activities',
          'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/list.gif?alt=media&token=c9bbc1c3-5cfb-4fe5-879d-73004afcea65', // URL directly used
          'Explore various activities to promote zero waste and earn more points.',
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ZeroWasteActivities())),
          Colors.green[600]!,
          Colors.green[900]!,
        ),
        SizedBox(height: 20), // Add spacing between sections
        _buildOptionCard(
          context,
          'Review Activities Status',
          'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/no_task.gif?alt=media&token=cfdc586e-5068-4b98-b563-540ebce5f32f', // Add a suitable URL for the icon
          'Check the status of your submitted activities.',
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReviewTaskStatusPage())), // Navigate to the new page
          Colors.orange[400]!,
          Colors.orange[900]!,
        ),
      ],
    );
  }

  Widget _buildVoucherTab(BuildContext context, int combinedPoints) {
    return Column(
      children: [
        _buildRedeemSection(context, combinedPoints), // Use combinedPoints here
        SizedBox(height: 20), // Add spacing between sections
        _buildOptionCard(
          context,
          'Review Voucher Status',
          'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/no_task.gif?alt=media&token=cfdc586e-5068-4b98-b563-540ebce5f32f', // Add a suitable URL for the icon
          'Check the status of your redeemed vouchers.',
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReviewVoucherStatusPage())), // Navigate to the voucher status page
          Colors.blue[400]!,
          Colors.blue[900]!,
        ),
      ],
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

  Widget _buildOptionCard(
      BuildContext context,
      String title,
      String gifUrl,
      String description,
      VoidCallback onTap,
      Color startColor,
      Color endColor) {
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
            children: [
              _buildIconContainer(gifUrl, 70.0),
              SizedBox(height: 10),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white)),
              SizedBox(height: 8),
              Text(description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRedeemSection(BuildContext context, int combinedPoints) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[600]!]),
      ),
      child: Column(
        children: [
          _buildIconContainer(
            'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/coupon.gif?alt=media&token=4b180f0f-67db-48e9-b467-07f5fbafebbc',
            70.0,
          ),
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
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), // Increased padding for a bigger button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pin_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Redeem Now',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white)),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text('Use this PIN to check out points',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Colors.white),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
