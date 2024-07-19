import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';

class ReviewVoucherStatusPage extends StatefulWidget {
  @override
  _ReviewVoucherStatusPageState createState() => _ReviewVoucherStatusPageState();
}

class _ReviewVoucherStatusPageState extends State<ReviewVoucherStatusPage> {
  int selectedIndex = 0;
  final List<String> statuses = ['Pending', 'Approved', 'Rejected'];
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  // Generate PIN function
  String _generatePIN() {
    final random = Random();
    const length = 6; // Length of the PIN
    const chars = '1234567890';
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Example function to add a voucher with PIN
  Future<void> _addVoucher(Map<String, dynamic> voucherData) async {
    final pin = _generatePIN();
    voucherData['pin'] = pin;
    await FirebaseFirestore.instance.collection('redeemVoucherRequests').add(voucherData);
  }

  Stream<QuerySnapshot> _fetchTasks(String status) {
    if (currentUser == null) {
      return Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('redeemVoucherRequests')
        .where('userId', isEqualTo: currentUser!.uid) // Filter by the current user's uid
        .where('status', isEqualTo: status.toLowerCase()) // Filter by status
        .snapshots();
  }

  Color _getToggleColor(int index) {
    switch (statuses[index].toLowerCase()) {
      case 'approved':
        return Colors.green[700]!;
      case 'rejected':
        return Colors.red[700]!;
      case 'pending':
      default:
        return Colors.yellow[700]!;
    }
  }

  void _showPINBottomSheet(BuildContext context, String pin) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Voucher PIN',
                style: AppTextStyles.nunitoBold.copyWith(fontSize: 18.sp),
              ),
              SizedBox(height: 20),
              Text(
                'PIN: $pin',
                style: AppTextStyles.nunitoBold.copyWith(fontSize: 24.sp, color: Colors.red),
              ),
              SizedBox(height: 20),
              Text(
                'Provide this PIN to the admin for voucher validation.',
                style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskList(Stream<QuerySnapshot> taskStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: taskStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildPlaceholder();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(), // Prevent ListView from scrolling separately
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot task = snapshot.data!.docs[index];
            Map<String, dynamic> data = task.data()! as Map<String, dynamic>;

            return Card(
              color: Colors.white, // Make the card white
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // More rounded edges
              ),
              elevation: 6, // Add depth
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // Center the content
                      children: [
                        if (data['iconPath'] != null)
                          Center(
                            child: Image.network(
                              data['iconPath'], // Retrieve and display the icon
                              height: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/task_image.png', // Fallback to a default image
                                  height: 80,
                                );
                              },
                            ),
                          ),
                        SizedBox(height: 10),
                        Text(
                          data['title'],
                          style: AppTextStyles.nunitoBold.copyWith(fontSize: 18.sp),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          data['description'] ?? '',
                          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 12.sp),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Submitted on: ${_formatTimestamp(data['timestamp'])}',
                            style: AppTextStyles.nunitoRegular.copyWith(fontSize: 10.sp),
                          ),
                        ),
                        if (data['approvalTimestamp'] != null)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'Approved on: ${_formatTimestamp(data['approvalTimestamp'])}',
                              style: AppTextStyles.nunitoRegular.copyWith(fontSize: 10.sp),
                            ),
                          ),
                        if (data['rejectionTimestamp'] != null)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'Rejected on: ${_formatTimestamp(data['rejectionTimestamp'])}',
                              style: AppTextStyles.nunitoRegular.copyWith(fontSize: 10.sp),
                            ),
                          ),
                        if (statuses[selectedIndex].toLowerCase() == 'approved')
                          Column(
                            children: [
                              SizedBox(height: 10),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showPINBottomSheet(context, data['pin']),
                                  icon: Icon(Icons.pin),
                                  label: Text(
                                    'Show PIN',
                                    style: AppTextStyles.nunitoBold.copyWith(fontSize: 16.sp, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white, backgroundColor: Colors.orange, // Set the text color to white
                                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${data['points']} pts',
                          style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 14.sp),
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

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/no_task.gif?alt=media&token=cfdc586e-5068-4b98-b563-540ebce5f32f', // Placeholder image
            height: 100,
          ),
          SizedBox(height: 20),
          Text(
            'No vouchers found',
            style: AppTextStyles.nunitoBold.copyWith(fontSize: 18.sp),
          ),
          SizedBox(height: 10),
          Text(
            'You have no vouchers in this category.',
            style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
      appBar: AppBar(
        title: Text(
          'Review Voucher Status',
          style: AppTextStyles.nunitoBold.copyWith(fontSize: 18.sp, color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 10), // Space between the app bar and the box
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/review_user.jpg?alt=media&token=faad5325-8cc5-474e-983a-8c5de0233fb9'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Review and Approve Vouchers',
                            style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 30),
                          Text(
                            'Here you can review the status of your redeemed vouchers. Your pending vouchers will be either approved or rejected and displayed here.',
                            style: AppTextStyles.nunitoRegular.copyWith(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(20),
                fillColor: _getToggleColor(selectedIndex),
                selectedColor: Colors.white,
                color: Colors.teal,
                selectedBorderColor: _getToggleColor(selectedIndex),
                borderColor: Colors.teal,
                isSelected: statuses.map((status) => statuses[selectedIndex] == status).toList(),
                onPressed: (int index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                children: statuses.map((status) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      status,
                      style: AppTextStyles.nunitoSemiBod.copyWith(
                        fontSize: 14,
                        color: statuses[selectedIndex] == status ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            _buildTaskList(_fetchTasks(statuses[selectedIndex])),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
