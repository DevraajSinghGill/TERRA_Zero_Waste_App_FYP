import 'package:flutter/material.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';
import 'package:terra_zero_waste_app/gamification/review_task/approved_page_user.dart';
import 'package:terra_zero_waste_app/gamification/review_task/pending_page_user.dart';
import 'package:terra_zero_waste_app/gamification/review_task/rejected_page_user.dart';

class ReviewTaskStatusPage extends StatefulWidget {
  @override
  _ReviewTaskStatusPageState createState() => _ReviewTaskStatusPageState();
}

class _ReviewTaskStatusPageState extends State<ReviewTaskStatusPage> {
  String selectedStatus = 'Pending';

  Widget _buildStatusButton(String label, String status) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedStatus = status;
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: selectedStatus == status ? Colors.white : Colors.teal,
        backgroundColor: selectedStatus == status ? Colors.green[700] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.nunitoSemiBod.copyWith(
          color: selectedStatus == status ? Colors.white : Colors.green[700],
          fontSize: 12, // Smaller font size
        ),
      ),
    );
  }

  Widget _buildStatusPage() {
    switch (selectedStatus) {
      case 'Approved':
        return ApprovedPage();
      case 'Rejected':
        return RejectedPage();
      case 'Pending':
      default:
        return PendingPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Review Task Status',
          style: AppTextStyles.nunitoBold.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
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
                            'Review and Approve Tasks',
                            style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 30),
                          Text(
                            'Here you can review the status of your completed task. Your pending task will be either approved or rejected and displayed here.',
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusButton('Pending', 'Pending'),
                  SizedBox(width: 10),
                  _buildStatusButton('Approved', 'Approved'),
                  SizedBox(width: 10),
                  _buildStatusButton('Rejected', 'Rejected'),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildStatusPage(), // Display the appropriate page based on the selected status
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
