import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPendingPage extends StatelessWidget {
  const AdminPendingPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20), // Reduce height between text
                    Text(
                      'As an admin, you can review the tasks submitted by users and approve or reject them. Each task contains details and points that the user can earn upon approval.',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('pendingTasks').where('status', isEqualTo: 'pending').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No pending tasks.'));
                }

                final pendingTasks = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: pendingTasks.length,
                  itemBuilder: (context, index) {
                    final task = pendingTasks[index];
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
                          children: [
                            Image.network(
                              task['icon'], // Retrieve and display the icon path
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
                              task['task'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Create and use your own cleaning products using natural ingredients.',
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
                                  child: Text('Approve'),
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
                                  child: Text('Reject'),
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
                                  '${task['points']} pts',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }
}
