import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserVoucherStatus extends StatelessWidget {
  final String userId;

  UserVoucherStatus({required this.userId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Voucher Status'),
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
      stream: FirebaseFirestore.instance.collection('voucherRequests').where('userId', isEqualTo: userId).where('status', isEqualTo: status).snapshots(),
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
              title: Text('Voucher: ${request['voucherId']}'),
              subtitle: Text('Status: ${request['status']}'),
              trailing: status == 'approved' ? Text('Code: ${request['redemptionCode']}') : null,
            );
          },
        );
      },
    );
  }
}
