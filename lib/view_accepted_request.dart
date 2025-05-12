import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/assign_recipient.dart';
import 'package:graduation_project/charity_dashboard.dart';

class view_accepted_request extends StatefulWidget {
  final Map<String, dynamic> donationData;
  final String charityID;

  view_accepted_request({required this.donationData, required this.charityID});

  @override
  State<view_accepted_request> createState() => _view_accepted_request();
}

class _view_accepted_request extends State<view_accepted_request> {
  late TextEditingController name;
  late TextEditingController phoneNumber;
  late TextEditingController city;
  late TextEditingController sublocation;
  late TextEditingController foodType;
  late TextEditingController additionalInfo;
  late TextEditingController pickupTime;
  late TextEditingController recipient;
  bool isAssigned = false;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: 'جاري تحميل الاسم...');
    phoneNumber = TextEditingController(text: 'جاري تحميل الرقم...');
    city = TextEditingController(text: widget.donationData['city'] ?? 'غير متوفر');
    sublocation = TextEditingController(text: widget.donationData['sublocation'] ?? 'غير متوفر');
    foodType = TextEditingController(text: widget.donationData['foodtype'] ?? 'غير متوفر');
    additionalInfo = TextEditingController(text: widget.donationData['additionalInfo'] ?? '');
    pickupTime = TextEditingController(text: widget.donationData['pickupTime'] ?? 'غير متوفر');

    isAssigned = widget.donationData['status'] == 'assigned';

    _initializeRecipientField();
    _fetchDonorDetails();
  }

  void _initializeRecipientField() {
    if (!isAssigned || widget.donationData['recipients'] == null || widget.donationData['recipients'].isEmpty) {
      recipient = TextEditingController(text: 'يجب تعيين المستلمين أولاً');
      return;
    }

    List<dynamic> recipients = widget.donationData['recipients'];
    String combined = recipients.map((r) {
      String name = r['name'] ?? 'غير معروف';
      String phone = r['phone'] ?? 'غير متوفر';
      return '$name ($phone)';
    }).join('\n');

    recipient = TextEditingController(text: combined.isEmpty ? 'غير متوفر' : combined);
  }

  void _fetchDonorDetails() async {
    String donorID = widget.donationData['donorID'];
    var snapshot = await FirebaseFirestore.instance.collection('users').doc(donorID).get();
    if (snapshot.exists) {
      var userData = snapshot.data();
      setState(() {
        name.text = userData?['name'] ?? 'غير معروف';
        phoneNumber.text = userData?['phone_number'] ?? 'غير متوفر';
      });
    } else {
      setState(() {
        name.text = 'غير معروف';
        phoneNumber.text = 'غير متوفر';
      });
    }
  }

  void _markAsDelivered() async {
    try {
      var recipientsSnapshot = await FirebaseFirestore.instance
          .collection('recipients')
          .where('donationID', isEqualTo: widget.donationData['donationID'])
          .get();

      if (recipientsSnapshot.docs.isEmpty) {
        throw Exception('لا يوجد مستلمين لهذا التبرع');
      }

      await FirebaseFirestore.instance
          .collection('donation')
          .doc(widget.donationData['donationID'])
          .update({'status': 'delivered'});

      for (var doc in recipientsSnapshot.docs) {
        await doc.reference.update({'status': 'delivered'});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث الحالة إلى تم التسليم لجميع المستلمين')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => charity_dashboard(charityID: widget.charityID),
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('خطأ أثناء تحديث الحالة: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحديث الحالة: $e')),
      );
    }
  }

  void _goToAssignRecipients() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => assign_recipient(
          donationId: widget.donationData['donationID'],
          charityID: widget.charityID,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, TextEditingController controller, {bool isMultiline = false}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF2E7D32),
            ),
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
              maxLines: isMultiline ? null : 1,
              decoration: InputDecoration.collapsed(hintText: ''),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFF1FAF2),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
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
                            SizedBox(height: 24),
                            _buildInfoCard('الاسم', name),
                            _buildInfoCard('رقم الهاتف', phoneNumber),
                            _buildInfoCard('وقت الاستلام', pickupTime),
                            _buildInfoCard('الموقع', TextEditingController(text: '${city.text} - ${sublocation.text}')),
                            _buildInfoCard('نوع الطعام', foodType),
                            _buildInfoCard('ملاحظات إضافية', additionalInfo, isMultiline: true),
                            _buildInfoCard('المستفيدين', recipient, isMultiline: true),
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: _goToAssignRecipients,
                                  child: Text('تعيين مستفيدين'),
                                ),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: isAssigned
                                      ? _markAsDelivered
                                      : () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('يرجى تعيين المستلمين أولاً')),
                                          );
                                        },
                                  child: Text('تم التسليم'),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.08,
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
                  child: Icon(Icons.arrow_forward, color: Color(0xFF2E7D32)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
