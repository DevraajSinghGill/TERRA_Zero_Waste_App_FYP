import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Panel'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestList('pending'),
            _buildRequestList('approved'),
            _buildRequestList('denied'),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('voucherRequests').where('status', isEqualTo: status).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var requests = snapshot.data!.docs;
        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var request = requests[index];
            return ListTile(
              title: Text('User: ${request['userId']}'),
              subtitle: Text('Points: ${request['points']}'),
              trailing: status == 'pending'
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () => _approveRequest(request.id, request['userId'], request['points']),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _denyRequest(request.id),
                        ),
                      ],
                    )
                  : Text(request['redemptionCode'] ?? ''),
            );
          },
        );
      },
    );
  }

  Future<void> _approveRequest(String requestId, String userId, int points) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      final currentPoints = snapshot.get('totalPoints');
      if (currentPoints < points) {
        throw Exception("Not enough points");
      }
      transaction.update(userDoc, {'totalPoints': currentPoints - points});

      // Generate unique redemption code
      String redemptionCode = _generateRedemptionCode();

      transaction.update(FirebaseFirestore.instance.collection('voucherRequests').doc(requestId), {
        'status': 'approved',
        'redemptionCode': redemptionCode,
      });
    });
  }

  Future<void> _denyRequest(String requestId) async {
    FirebaseFirestore.instance.collection('voucherRequests').doc(requestId).update({'status': 'denied'});
  }

  String _generateRedemptionCode() {
    // Generate a unique code
    return 'CODE-${DateTime.now().millisecondsSinceEpoch}';
  }
}
