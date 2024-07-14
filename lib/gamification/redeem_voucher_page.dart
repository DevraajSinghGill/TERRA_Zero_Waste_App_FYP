import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
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
  String data = '';
  final GlobalKey _qrkey = GlobalKey();

  @override
  void initState() {
    super.initState();
    totalPoints = widget.initialPoints;
  }

  Future<void> _redeemVoucher(BuildContext context, int points, String voucherId) async {
    try {
      await FirebaseFirestore.instance.collection('voucherRequests').add({
        'userId': widget.userId,
        'voucherId': voucherId,
        'points': points,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'redemptionCode': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Voucher redemption request sent for approval!'),
        backgroundColor: Colors.teal[800],
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Redeem Voucher'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vouchers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var vouchers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: vouchers.length,
            itemBuilder: (context, index) {
              var voucher = vouchers[index];
              return _buildVoucherCard(
                context,
                voucher['title'],
                voucher['description'],
                voucher['iconPath'],
                voucher['points'],
                voucher.id,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVoucherCard(BuildContext context, String title, String description, String iconPath, int points, String voucherId) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(iconPath, width: 50, height: 50),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(description),
                    ],
                  ),
                ),
                Text(
                  '$points pts',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (totalPoints >= points) {
                  await _redeemVoucher(context, points, voucherId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Not enough points to redeem this voucher.'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Text('Redeem'),
            ),
          ],
        ),
      ),
    );
  }
}
