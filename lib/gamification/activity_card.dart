import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final String description;
  final String iconPath;
  final String imagePath;
  final int points;
  final VoidCallback onComplete;
  final bool disabled;

  const ActivityCard({
    Key? key,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.imagePath,
    required this.points,
    required this.onComplete,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0), // Adds space between cards
      padding: EdgeInsets.all(12.0), // Adjusted padding
      width: MediaQuery.of(context).size.width * 0.9, // Set width to 90% of screen width
      decoration: BoxDecoration(
        color: disabled ? Colors.grey[300] : Colors.white, // Background color of the card
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: Offset(0, 3), // Offset in x and y direction
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Centered GIF Icon
          Container(
            width: 80.0, // Increased size
            height: 80.0, // Increased size
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: EdgeInsets.all(3.0),
            child: ClipOval(
              child: Image.network(iconPath, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 12.0), // Adjusted spacing
          // Title and description
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w900,
              fontSize: 12.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.0), // Adjusted spacing
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 10.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.0), // Adjusted spacing
          // Complete button
          Center(
            child: ElevatedButton(
              onPressed: disabled ? null : onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: disabled ? Colors.grey : Color.fromARGB(255, 16, 111, 62),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
              ),
              child: Text(
                disabled ? 'COMPLETED' : 'COMPLETE',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 12.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.0), // Adjusted spacing
          // Points badge
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: EdgeInsets.all(6.0), // Adjusted padding
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$points pts',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 12.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
