import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Stream<QuerySnapshot> _fetchTasks(String status) {
    if (currentUser == null) {
      return Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('redeemVoucher')
        .where('userId', isEqualTo: currentUser!.uid)
        .where('status', isEqualTo: status.toLowerCase())
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
          return Center(child: Text('No tasks found'));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (data['iconPath'] != null)
                      Center(child: Image.network(data['iconPath'], height: 50)),
                    SizedBox(height: 10),
                    Text(
                      data['title'],
                      style: AppTextStyles.nunitoBold.copyWith(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      data['description'],
                      style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Points: ${data['points']}',
                          style: AppTextStyles.nunitoRegular.copyWith(fontSize: 12, color: Colors.black),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${data['points']} pts',
                            style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Review Voucher Status',
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
      body: Column(
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
          Expanded(
            child: _buildTaskList(_fetchTasks(statuses[selectedIndex])),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
