import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';

class AdminVoucherValidationPage extends StatefulWidget {
  @override
  _AdminVoucherValidationPageState createState() => _AdminVoucherValidationPageState();
}

class _AdminVoucherValidationPageState extends State<AdminVoucherValidationPage> {
  final TextEditingController _pinController = TextEditingController();
  Map<String, dynamic>? voucherData;

  Future<void> _fetchVoucherByPIN(String pin) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('redeemVoucherRequests')
        .where('pin', isEqualTo: pin)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        voucherData = snapshot.docs.first.data();
      });
    } else {
      setState(() {
        voucherData = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voucher not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Voucher Validation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              decoration: InputDecoration(labelText: 'Enter PIN'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final pin = _pinController.text;
                if (pin.isNotEmpty) {
                  _fetchVoucherByPIN(pin);
                }
              },
              child: Text('Validate Voucher'),
            ),
            SizedBox(height: 20),
            if (voucherData != null)
              Card(
                elevation: 6,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Voucher ID: ${voucherData!['voucherId']}', style: AppTextStyles.nunitoBold),
                      Text('Title: ${voucherData!['title']}', style: AppTextStyles.nunitoBold),
                      Text('Description: ${voucherData!['description']}', style: AppTextStyles.nunitoRegular),
                      Text('Points: ${voucherData!['points']}', style: AppTextStyles.nunitoRegular),
                      Text('Submitted on: ${voucherData!['timestamp']}', style: AppTextStyles.nunitoRegular),
                      if (voucherData!['approvalTimestamp'] != null)
                        Text('Approved on: ${voucherData!['approvalTimestamp']}', style: AppTextStyles.nunitoRegular),
                      if (voucherData!['rejectionTimestamp'] != null)
                        Text('Rejected on: ${voucherData!['rejectionTimestamp']}', style: AppTextStyles.nunitoRegular),
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
