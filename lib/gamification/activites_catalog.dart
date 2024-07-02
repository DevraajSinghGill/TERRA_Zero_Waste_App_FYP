import 'package:flutter/material.dart';

class ActivitiesCatalogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 178, 99),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Activities Catalog',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'List of Activities will be shown here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
