import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RedeemVoucherPage extends StatefulWidget {
  final String userId;
  final int initialPoints;

  RedeemVoucherPage({required this.userId, required this.initialPoints});

  @override
  _RedeemVoucherPageState createState() => _RedeemVoucherPageState();
}

class _RedeemVoucherPageState extends State<RedeemVoucherPage> {
  late int totalPoints;

  @override
  void initState() {
    super.initState();
    totalPoints = widget.initialPoints;
  }

  Future<void> _redeemVoucher(BuildContext context, String title, int points, String iconPath, String description) async {
    final redeemVoucherCollection = FirebaseFirestore.instance.collection('redeemVoucherRequests');
    
    try {
      await redeemVoucherCollection.add({
        'userId': widget.userId,
        'title': title,
        'points': points,
        'iconPath': iconPath,
        'description': description,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _showPendingApprovalDialog(context, title);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to submit request: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _showPendingApprovalDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: EdgeInsets.all(12.0),
          backgroundColor: Colors.white, // Set background color to white
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
                'Voucher Redemption Pending Approval',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.sp,
                  color: Colors.black, // Set text color to black
                ),
                textAlign: TextAlign.center, // Center the text
              ),
              SizedBox(height: 8),
              Text(
                'Your voucher redemption for "$title" is pending approval.',
                textAlign: TextAlign.center, // Center the text
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 10.sp,
                  color: Colors.black, // Set text color to black
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal[800]!,
                Colors.teal[600]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Redeem Voucher',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w900,
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildRedeemBox(),
                  SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('redeemVoucher').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var vouchers = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: vouchers.length,
                        itemBuilder: (context, index) {
                          var voucher = vouchers[index];
                          return _buildVoucherCard(
                            context,
                            voucher['title'],
                            voucher['description'],
                            voucher['iconPath'],
                            voucher['points'],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemBox() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage('lib/assets/images/voucher.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.3),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Redeem Voucher',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 160),
              Text(
                'You can redeem your points for various vouchers here. '
                'Choose from a wide range of options available and enjoy your rewards!',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 10.sp,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoucherCard(BuildContext context, String title,
      String description, String gifPath, int points) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[800],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    child: Text(
                      '$points pts',
                      style: GoogleFonts.robotoSlab(
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.network(
                        gifPath,
                        width: 80,
                        height: 80, // Increased size
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  _redeemVoucher(context, title, points, gifPath, description);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  shadowColor: Colors.black,
                  elevation: 8,
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'REDEEM VOUCHER',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
