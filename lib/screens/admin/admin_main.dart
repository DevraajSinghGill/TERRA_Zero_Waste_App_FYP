import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:terra_zero_waste_app/constants/app_text_styles.dart';

class AdminPendingPage extends StatefulWidget {
  const AdminPendingPage({super.key});

  @override
  _AdminPendingPageState createState() => _AdminPendingPageState();
}

class _AdminPendingPageState extends State<AdminPendingPage> {
  String selectedStatus = 'pending';

  Future<void> _approveTask(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('pendingTasks').doc(taskId).update({
        'status': 'approved',
      });
    } catch (e) {
      print('Error approving task: $e');
    }
  }

  Future<void> _rejectTask(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('pendingTasks').doc(taskId).update({
        'status': 'rejected',
      });
    } catch (e) {
      print('Error rejecting task: $e');
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    var format = DateFormat('yyyy-MM-dd HH:mm'); // Use any format you prefer
    return format.format(timestamp.toDate());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: double.infinity,
                  height: 240, // Increase the height to avoid overflow
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/terra-zero-waste-app-a10c9.appspot.com/o/admin_pic.jpg?alt=media&token=6c03623e-f703-4eed-9981-5ae47597058e'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5), BlendMode.darken),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review and Approve Tasks',
                        style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 16.sp),
                      ),
                      SizedBox(height: 40), // Reduce height between text
                      Text(
                        'As an admin, you can review the tasks submitted by users and approve or reject them. Each task contains details and points that the user can earn upon approval.',
                        style: AppTextStyles.nunitoRegular.copyWith(color: Colors.white, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusButton('Pending', 'pending'),
                  SizedBox(width: 10),
                  _buildStatusButton('Approved', 'approved'),
                  SizedBox(width: 10),
                  _buildStatusButton('Rejected', 'rejected'),
                ],
              ),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('pendingTasks').where('status', isEqualTo: selectedStatus).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No tasks.'));
                }

                final tasks = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // Prevent ListView from scrolling separately
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final data = task.data() as Map<String, dynamic>;
                    final uid = data['uid'];

                    return FutureBuilder(
                      future: _getUsername(uid),
                      builder: (context, AsyncSnapshot<String> userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final username = userSnapshot.data ?? 'Unknown User';

                        return Card(
                          color: Colors.white, // Make the card white
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0), // More rounded edges
                          ),
                          elevation: 6, // Add depth
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 20, color: Colors.black),
                                    SizedBox(width: 5),
                                    Text(
                                      'Submitted by: $username',
                                      style: AppTextStyles.nunitoBold.copyWith(fontSize: 14.sp),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Column(
                                  children: [
                                    Image.network(
                                      data['icon'], // Retrieve and display the icon path
                                      height: 80,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/task_image.png', // Fallback to a default image
                                          height: 80,
                                        );
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      data['task'],
                                      style: AppTextStyles.nunitoBold.copyWith(fontSize: 18.sp),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Create and use your own cleaning products using natural ingredients.',
                                      style: AppTextStyles.nunitoRegular.copyWith(fontSize: 14.sp),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _approveTask(task.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          child: Text('Approve', style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 14.sp)),
                                        ),
                                        SizedBox(width: 20),
                                        ElevatedButton(
                                          onPressed: () => _rejectTask(task.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          child: Text('Reject', style: AppTextStyles.nunitoBold.copyWith(color: Colors.white, fontSize: 14.sp)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.bottomRight,
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
                                    SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        'Submitted on: ${_formatTimestamp(data['timestamp'])}',
                                        style: AppTextStyles.nunitoRegular.copyWith(fontSize: 12.sp),
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
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, String status) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedStatus = status;
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: selectedStatus == status ? Colors.white : Colors.teal,
        backgroundColor: selectedStatus == status ? Colors.blue[600] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.nunitoSemiBod.copyWith(fontSize: 12.sp, color: selectedStatus == status ? Colors.white : Colors.blue[600]),
      ),
    );
  }
}

