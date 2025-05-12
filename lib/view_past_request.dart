import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class view_past_request extends StatefulWidget {
  final Map<String, dynamic> donationData;

  view_past_request({required this.donationData});

  @override
  _view_past_request createState() => _view_past_request();
}

class _view_past_request extends State<view_past_request> {
  late TextEditingController name;
  late TextEditingController phoneNumber;
  late TextEditingController cityAndSublocation;
  late TextEditingController foodType;
  late TextEditingController additionalInfo;
  late TextEditingController pickupTime;
  late TextEditingController recipients;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: 'جاري تحميل الاسم...');
    phoneNumber = TextEditingController(text: 'جاري تحميل الرقم...');
    cityAndSublocation = TextEditingController(text: '${widget.donationData['city'] ?? 'غير متوفر'} - ${widget.donationData['sublocation'] ?? 'غير متوفر'}');
    foodType = TextEditingController(text: widget.donationData['foodtype'] ?? 'غير متوفر');
    additionalInfo = TextEditingController(text: widget.donationData['additionalInfo'] ?? '');
    pickupTime = TextEditingController(text: widget.donationData['pickupTime'] ?? 'غير متوفر');

    recipients = TextEditingController(text: 'جاري تحميل المستلمين...'); // 🔹 initialize here

    _initializeRecipientFields();
    _fetchDonorDetails();
  }

  void _initializeRecipientFields() async {
    String donationID = widget.donationData['donationID']; // Make sure donationID is passed

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('recipients')
          .where('donationID', isEqualTo: donationID)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          recipients = TextEditingController(text: 'غير متوفر');
        });
        return;
      }

      List<String> recipientInfoList = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String recipientID = data['recipientID'];

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(recipientID)
            .get();

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          String name = userData['name'] ?? 'غير معروف';
          String phone = userData['phone_number'] ?? 'غير متوفر';
          recipientInfoList.add('$name ($phone)');
        }
      }

      setState(() {
        recipients = TextEditingController(
          text: recipientInfoList.join('\n'),
        );
      });
    } catch (e) {
      print('Error fetching recipient details: $e');
      setState(() {
        recipients = TextEditingController(text: 'خطأ في تحميل المستلمين');
      });
    }
  }

  Future<void> _fetchDonorDetails() async {
    try {
      String donorID = widget.donationData['donorID'];
      if (donorID.isNotEmpty) {
        DocumentSnapshot donorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(donorID)
            .get();

        if (donorDoc.exists) {
          var donorData = donorDoc.data() as Map<String, dynamic>;
          setState(() {
            name.text = donorData['name'] ?? 'غير متوفر';
            phoneNumber.text = donorData['phone_number'] ?? 'غير متوفر';
          });
        }
      }
    } catch (e) {
      print("Error fetching donor details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFF1FAF2),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 60),
                    Center(
                      child: Text(
                        'معلومات التبرع',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildInfoCard('الاسم', name),
                    _buildInfoCard('رقم الهاتف', phoneNumber),
                    _buildInfoCard('الموقع', cityAndSublocation),
                    _buildInfoCard('نوع الطعام', foodType),
                    _buildMultilineInfoCard('تفاصيل / ملاحظات اضافية', additionalInfo),
                    _buildMultilineInfoCard('المستفيدين', recipients),
                    _buildInfoCard('وقت الاستلام', pickupTime),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
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
      ),
    );
  }

  Widget _buildInfoCard(String title, TextEditingController controller) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Align to the right
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF2E7D32),
          ),
          textAlign: TextAlign.right, // Align text to the right
          textDirection: TextDirection.rtl, // Set text direction to RTL
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
          ),
          child: TextField(
            controller: controller,
            readOnly: true,
            maxLines: 1,
            decoration: InputDecoration.collapsed(hintText: ''),
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.right, // Align text to the right
            textDirection: TextDirection.rtl, // Set text direction to RTL
          ),
        ),
      ],
    ),
  );
}

Widget _buildMultilineInfoCard(String title, TextEditingController controller) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Align to the right
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF2E7D32),
          ),
          textAlign: TextAlign.right, // Align text to the right
          textDirection: TextDirection.rtl, // Set text direction to RTL
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
          ),
          child: TextField(
            controller: controller,
            readOnly: true,
            maxLines: null,
            decoration: InputDecoration.collapsed(hintText: ''),
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.right, // Align text to the right
            textDirection: TextDirection.rtl, // Set text direction to RTL
          ),
        ),
      ],
    ),
  );
}

}
