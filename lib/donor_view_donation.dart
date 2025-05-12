import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class donor_view_donation extends StatelessWidget {
  final QueryDocumentSnapshot donation;

  donor_view_donation({required this.donation});

  // Method to format the Timestamp fields
  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(date); // Change the format as needed
  }
  String _getArabicStatus(String status) {
    switch (status) {
      case 'sent':
        return 'قيد الانتظار';
      case 'assigned':
        return 'تم التعيين';
      case 'delivered':
        return 'تم التسليم';
      case 'accepted':
        return 'تم القبول';
      default:
        return 'غير معروف';
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF1FAF2), // Light green background
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 80),
                  Center(
                    child: Text(
                      'تفاصيل التبرع',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildReadOnlyField('المدينة', donation['city']),
                  _buildReadOnlyField('الموقع الفرعي', donation['sublocation']),
                  _buildReadOnlyField('نوع الطعام', donation['foodtype']),
                  _buildReadOnlyField('تفاصيل / ملاحظات اضافية', donation['additionalInfo']),
                  _buildReadOnlyField('وقت الاستلام', donation['pickupTime']),
                  _buildReadOnlyField('تاريخ التبرع', _formatDate(donation['donationdate'])),
                  _buildReadOnlyField('تاريخ الانتهاء', _formatDate(donation['expirydate'])),
                  _buildReadOnlyField('حالة التبرع', _getArabicStatus(donation['status'])),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // Corrected floating back button using Positioned inside Stack
          Positioned(
            top: screenHeight * 0.05,
            left: 20,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32), // Label deep green
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white, // White field background
            borderRadius: BorderRadius.circular(5),
            //border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black, // Field value medium green
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
