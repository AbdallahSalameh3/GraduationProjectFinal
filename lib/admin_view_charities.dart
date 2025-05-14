import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/login_or_signup_screen.dart';

class admin_view_charities extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            "تسجيل الخروج",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
          ),
          content: Text(
            "هل أنت متأكد أنك تريد تسجيل الخروج؟",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontFamily: 'Tajawal'),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "لا",
                style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Tajawal'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => login_or_signup_screen()),
                );
              },
              child: Text(
                "نعم",
                style: TextStyle(color: Colors.red, fontSize: 16, fontFamily: 'Tajawal'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> getUserDetails(String email) async {
    var userDoc = await _firestore.collection('users').doc(email).get();
    return userDoc.exists ? userDoc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl, // Whole page RTL
      child: Scaffold(
        backgroundColor: Color(0xFFF1FAF2),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 60),
                  Center(
                    child: Text(
                      'الجمعيات المعتمدة',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('charity')
                          .where('validstatus', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              "لا يوجد جمعيات معتمدة",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Tajawal',
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        }

                        var charities = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: charities.length,
                          itemBuilder: (context, index) {
                            var charityData = charities[index].data() as Map<String, dynamic>;
                            String email = charities[index].id;
                            String license = charityData['license'] ?? "N/A";

                            return FutureBuilder<Map<String, dynamic>?>( 
                              future: getUserDetails(email),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                  return buildLoadingCard(email);
                                }

                                if (!userSnapshot.hasData) {
                                  return buildErrorCard(email);
                                }

                                var userData = userSnapshot.data!;
                                String name = userData['name'] ?? "غير معروف";
                                String phoneNumber = userData['phone_number'] ?? "لا يوجد رقم";
                                String location = "${userData['city'] ?? 'غير معروف'}, ${userData['sublocation'] ?? ''}";

                                return buildCharityCard(email, license, name, phoneNumber, location);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                top: screenHeight * 0.025,
                left: 10,
                child: InkWell(
                  onTap: () => _confirmLogout(context),
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
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.1416), 
                      child: Icon(Icons.logout, color: Colors.red),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: WillPopScope(
                  onWillPop: () async {
                    _confirmLogout(context);
                    return false; // Prevent default back navigation
                  },
                  child: SizedBox.shrink(), // Empty container to attach WillPopScope
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoadingCard(String email) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: ListTile(
        title: Text(
          "Email: $email",
          style: TextStyle(fontFamily: 'Tajawal'),
          textAlign: TextAlign.right,
        ),
        subtitle: Text(
          "جاري تحميل البيانات...",
          style: TextStyle(fontFamily: 'Tajawal'),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  Widget buildErrorCard(String email) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: ListTile(
        title: Text(
          "Email: $email",
          style: TextStyle(fontFamily: 'Tajawal'),
          textAlign: TextAlign.right,
        ),
        subtitle: Text(
          "لم يتم العثور على بيانات المستخدم",
          style: TextStyle(fontFamily: 'Tajawal'),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  Widget buildCharityCard(String email, String license, String name, String phoneNumber, String location) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to full width
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "البريد الإلكتروني: $email",
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "رقم الترخيص: $license",
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "الاسم: $name",
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "رقم الهاتف: $phoneNumber",
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "الموقع: $location",
                style: TextStyle(fontFamily: 'Tajawal', fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
