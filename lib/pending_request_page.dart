import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/pending_requests.dart';
import 'package:graduation_project/charity_dashboard.dart';

class pending_request_page extends StatefulWidget {
  final QueryDocumentSnapshot donation;
  final String charityID;

  pending_request_page({required this.donation, required this.charityID});

  @override
  _pending_request_page createState() => _pending_request_page();
}

class _pending_request_page extends State<pending_request_page> {
  late TextEditingController Name;
  late TextEditingController phoneNumber;
  late TextEditingController city;
  late TextEditingController sublocation;
  late TextEditingController foodType;
  late TextEditingController additionalInfo;
  late TextEditingController pickupTime;

  @override
  void initState() {
    super.initState();

    city = TextEditingController(text: widget.donation['city']);
    sublocation = TextEditingController(text: widget.donation['sublocation']);
    foodType = TextEditingController(text: widget.donation['foodtype']);
    additionalInfo = TextEditingController(text: widget.donation['additionalInfo']);
    pickupTime = TextEditingController(text: widget.donation['pickupTime']);

    Name = TextEditingController(text: "جاري التحميل...");
    phoneNumber = TextEditingController(text: "جاري التحميل...");
    fetchDonorPhoneNumber();
    fetchDonorName();
    city = TextEditingController(text: "${widget.donation['city']} - ${widget.donation['sublocation']}");

  }

  Future<void> fetchDonorPhoneNumber() async {
    String donorId = widget.donation['donorID'];

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(donorId).get();

      if (userDoc.exists) {
        setState(() {
          phoneNumber.text = userDoc['phone_number'];
        });
      } else {
        setState(() {
          phoneNumber.text = "غير متوفر";
        });
      }
    } catch (e) {
      print("Error fetching donor phone number: $e");
      setState(() {
        phoneNumber.text = "خطأ في تحميل الرقم";
      });
    }
  }

  Future<void> fetchDonorName() async {
    String donorId = widget.donation['donorID'];

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(donorId).get();

      if (userDoc.exists) {
        setState(() {
          Name.text = userDoc['name'];
        });
      } else {
        setState(() {
          Name.text = "غير متوفر";
        });
      }
    } catch (e) {
      print("Error fetching donor name: $e");
      setState(() {
        Name.text = "خطأ في تحميل الاسم";
      });
    }
  }

  @override
  void dispose() {
    Name.dispose();
    phoneNumber.dispose();
    city.dispose();
    sublocation.dispose();
    foodType.dispose();
    additionalInfo.dispose();
    pickupTime.dispose();
    super.dispose();
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
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    SizedBox(height: 10),
                    _buildInfoCard('اسم المتبرع', Name),
                    _buildInfoCard('رقم الهاتف', phoneNumber),
                    _buildInfoCard('الموقع', city),
                    //_buildInfoCard('الموقع الفرعي', sublocation),
                    _buildInfoCard('نوع الطعام', foodType),
                    _buildInfoCard('تفاصيل / ملاحظات اضافية', additionalInfo, isMultiline: true),
                    _buildInfoCard('وقت الاستلام المفضل', pickupTime),
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                            .collection('donation')
                            .doc(widget.donation.id)
                            .update({
                          'status': 'accepted',
                          'charityID': widget.charityID,
                        });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم قبول التبرع بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => charity_dashboard(charityID: widget.charityID),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('حدث خطأ أثناء قبول التبرع'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Text('قبول التبرع'),
                      ),
                    ),
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

  Widget _buildInfoCard(String title, TextEditingController controller, {bool isMultiline = false}) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end, 
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF2E7D32),
          ),
          textAlign: TextAlign.right, 
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
            textAlign: TextAlign.right, 
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}


}
