import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';

class AdminVerifyVoucherPage extends StatefulWidget {
  @override
  _AdminVerifyVoucherPageState createState() => _AdminVerifyVoucherPageState();
}

class _AdminVerifyVoucherPageState extends State<AdminVerifyVoucherPage> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<bool> _isFilled = List.generate(6, (index) => false);
  Map<String, dynamic>? voucherData;
  String username = '';

  Future<void> _verifyVoucher() async {
    final pin = _controllers.map((controller) => controller.text.trim()).join();

    if (pin.isEmpty || pin.length != 6) {
      _showErrorDialog('Please enter a valid 6-digit PIN.');
      return;
    }

    try {
      print('Entered PIN: $pin');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('redeemVoucherRequests')
          .where('pin', isEqualTo: int.parse(pin)) 
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showErrorDialog('Invalid PIN. Please try again.');
      } else {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        print('Voucher Data: $data');

        if (data['isRedeemed'] == true) {
          _showErrorDialog('This voucher has already been redeemed.');
          return;
        }

        if (data['isVerified'] == true) {
          _showErrorDialog('This voucher has already been verified.');
          return;
        }

        if (data['status'] == 'approved') {
          setState(() {
            voucherData = data;
          });
          username = await _getUsername(data['userId']);
          _showVoucherInfo();
          await _updateVoucherField('isVerified', true); 
        } else {
          _showErrorDialog('This voucher is not approved.');
        }
      }
    } catch (error) {
      print('Error: $error');
      _showErrorDialog('An error occurred while verifying the voucher. Please try again.');
    }
  }

  Future<String> _getUsername(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['username'] ?? 'Unknown User';
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
    return 'Unknown User';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showVoucherInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: _buildVoucherTicket(),
        );
      },
    );
  }

  Future<void> _markVoucherAsRedeemed() async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference voucherRef = FirebaseFirestore.instance.collection('redeemVoucherRequests').doc(voucherData!['pin'].toString());
        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(voucherData!['userId']);

        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (userSnapshot.exists) {
          int currentPoints = (userSnapshot['combinedPoints'] ?? 0).toInt();
          int voucherPoints = (voucherData!['points'] ?? 0).toInt();
          int newPoints = currentPoints - voucherPoints;

          transaction.update(voucherRef, {
            'isRedeemed': true,
          });

          transaction.update(userRef, {
            'combinedPoints': newPoints,
          });
        }
      });
    } catch (e) {
      print('Error marking voucher as redeemed: $e');
    }
  }

  Future<void> _updateVoucherField(String field, dynamic value) async {
    try {
      await FirebaseFirestore.instance
          .collection('redeemVoucherRequests')
          .doc(voucherData!['pin'].toString())
          .update({field: value});
    } catch (e) {
      print('Error updating voucher field: $e');
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Unknown';
    }
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/redeem_voucher.gif?alt=media&token=767dd3ff-278d-4fe0-839b-62431dccfc41',
                height: 150,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Verify Voucher',
                style: AppTextStyles.nunitoBold.copyWith(fontSize: 24.sp),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Enter the voucher PIN below to verify the voucher.',
                style: AppTextStyles.nunitoRegular.copyWith(fontSize: 16.sp),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 60, // Slightly increased width
                    height: 70, // Slightly increased height
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _isFilled[index] ? Colors.blueAccent : Colors.grey,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: _isFilled[index] ? Colors.blue.shade100 : Colors.transparent,
                        counterText: "",
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: AppTextStyles.nunitoRegular.copyWith(fontSize: 24.sp),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _isFilled[index] = value.isNotEmpty;
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _verifyVoucher,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  backgroundColor: Colors.blue, 
                ),
                child: Text(
                  'Verify Voucher',
                  style: AppTextStyles.nunitoBold.copyWith(fontSize: 16.sp, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherTicket() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'VOUCHER INFORMATION',
              style: AppTextStyles.nunitoBold.copyWith(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            Divider(color: Colors.black),
            if (voucherData!['iconPath'] != null)
              Center(
                child: Image.network(
                  voucherData!['iconPath'],
                  height: 130,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/task_image.png',
                      height: 150,
                    );
                  },
                ),
              ),
            SizedBox(height: 10),
            _buildInfoRow('Title', voucherData!['title']),
            _buildInfoRow('Description', voucherData!['description'] ?? ''),
            _buildInfoRow('Username', username),
            _buildInfoRow('Submitted On', _formatTimestamp(voucherData!['timestamp'])),
            _buildInfoRow('Approved On', _formatTimestamp(voucherData!['approvalTimestamp'])),
            _buildInfoRow('Points', '${voucherData!['points']} pts'),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                await _markVoucherAsRedeemed();
                Navigator.of(context).pop(); 
                _showCongratulationsDialog();
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Redeemed',
                    style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 16.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.nunitoBold.copyWith(fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCongratulationsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/completed_task.gif?alt=media&token=d0a7b8bf-52b9-4dc1-b40f-1a1d6cf6e245',
                height: 150,
              ),
              SizedBox(height: 16),
              Text(
                'Congratulations!',
                style: AppTextStyles.nunitoBold.copyWith(fontSize: 20.sp),
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  _clearTextFields(); // Clear the text fields
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'OK',
                    style: AppTextStyles.nunitoBold.copyWith(fontSize: 16.sp, color: Colors.blue),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearTextFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    setState(() {
      _isFilled.fillRange(0, _isFilled.length, false);
    });
  }
}
