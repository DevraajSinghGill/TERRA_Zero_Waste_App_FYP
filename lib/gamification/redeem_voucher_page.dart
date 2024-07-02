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

  Future<void> _redeemVoucher(BuildContext context, int points) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);

        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }

        final currentPoints = snapshot.get('totalPoints');
        if (currentPoints < points) {
          throw Exception("Not enough points!");
        }

        transaction.update(userDoc, {'totalPoints': currentPoints - points});
        setState(() {
          totalPoints = currentPoints - points;
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Voucher redeemed successfully!'),
        backgroundColor: Colors.teal[800],
      ));

      _showQRCodeBottomSheet(context);
    } catch (e) {
      if (e.toString().contains("Not enough points")) {
        _showErrorDialog(context, "Not enough points", "You do not have enough points to redeem this voucher.");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _showQRCodeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.80,
          minChildSize: 0.25,
          maxChildSize: 1.0,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, 4),
                            blurRadius: 10.0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Scan this QR Code to redeem your voucher',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Present this QR code at the participating outlet to avail your voucher benefits.',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 10.sp,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Image.asset(
                      'lib/assets/images/qr_code.png',
                      width: 200.0,
                      height: 200.0,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
              ),
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w900,
              fontSize: 14.sp,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "OK",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.sp,
                  color: Colors.teal[800],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
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
                  _buildVoucherCard(
                    context,
                    '10% Off Coupon',
                    'Redeem this voucher for a 10% discount on your next purchase.',
                    'lib/assets/gif_icons/10-percent.gif',
                    100,
                  ),
                  SizedBox(height: 16),
                  _buildVoucherCard(
                    context,
                    'Free Coffee',
                    'Enjoy a free cup of coffee at our participating outlets.',
                    'lib/assets/gif_icons/coffee-cup.gif',
                    100,
                  ),
                  SizedBox(height: 16),
                  _buildVoucherCard(
                    context,
                    'Movie Ticket',
                    'Redeem a free movie ticket at any of our partner cinemas.',
                    'lib/assets/gif_icons/clapperboard.gif',
                    100,
                  ),
                  SizedBox(height: 16),
                  _buildVoucherCard(
                    context,
                    'Grocery Discount',
                    "Get a RM5 discount on your next grocery purchase.",
                    'lib/assets/gif_icons/basket.gif',
                    100,
                  ),
                  SizedBox(height: 16),
                  _buildVoucherCard(
                    context,
                    '10% Off Coupon',
                    'Redeem this voucher for a 10% discount on your next purchase.',
                    'lib/assets/gif_icons/10-percent.gif',
                    100,
                  ),
                  SizedBox(height: 16),
                  _buildVoucherCard(
                    context,
                    'Free Coffee',
                    'Enjoy a free cup of coffee at our participating outlets.',
                    'lib/assets/gif_icons/coffee-cup.gif',
                    100,
                  ),
                  SizedBox(height: 16),
                  _buildVoucherCard(
                    context,
                    'Movie Ticket',
                    'Redeem a free movie ticket at any of our partner cinemas.',
                    'lib/assets/gif_icons/clapperboard.gif',
                    100,
                  ),
                  SizedBox(height: 16),
                  _buildVoucherCard(
                    context,
                    'Grocery Discount',
                    "Get a RM5 discount on your next grocery purchase.",
                    'lib/assets/gif_icons/basket.gif',
                    100,
                  ),
                  SizedBox(height: 16),
                  _buildVoucherCard(
                    context,
                    'Movie Ticket',
                    'Redeem a free movie ticket at any of our partner cinemas.',
                    'lib/assets/gif_icons/clapperboard.gif',
                    100,
                  ),
                  SizedBox(height: 16),
                  _buildVoucherCard(
                    context,
                    'Grocery Discount',
                    "Get a RM5 discount on your next grocery purchase.",
                    'lib/assets/gif_icons/basket.gif',
                    100,
                  ),
                  // Add more voucher cards here as needed
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
                      child: Image.asset(
                        gifPath,
                        width: 50,
                        height: 50,
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
                    ),
                    SizedBox(height: 6),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _redeemVoucher(context, points);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ));
                  }
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
