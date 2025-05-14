import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/login_or_signup_screen.dart';
import 'view_past_request.dart';
import 'package:graduation_project/donor_recipient_profile.dart';

class past_requests extends StatefulWidget {
  final String charityID;

  past_requests({required this.charityID});

  @override
  _past_requests createState() => _past_requests();
}

class _past_requests extends State<past_requests> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchDeliveredDonations() async {
    try {
      QuerySnapshot donationsSnapshot = await _firestore
          .collection('donation')
          .where('charityID', isEqualTo: widget.charityID)
          .where('status', isEqualTo: 'delivered')
          .get();

      List<Future<Map<String, dynamic>>> donationFutures = donationsSnapshot.docs.map((doc) async {
        Map<String, dynamic> donationData = doc.data() as Map<String, dynamic>;
        String donationID = doc.id;

        QuerySnapshot recipientsSnapshot = await _firestore
            .collection('recipients')
            .where('donationID', isEqualTo: donationID)
            .where('status', isEqualTo: 'delivered')
            .get();

        List<Map<String, dynamic>> recipients = [];

        for (var recipientDoc in recipientsSnapshot.docs) {
          var recipientData = recipientDoc.data() as Map<String, dynamic>;
          String recipientEmail = recipientData['recipientID'];

          DocumentSnapshot userDoc = await _firestore
              .collection('users')
              .doc(recipientEmail)
              .get();

          if (userDoc.exists) {
            recipients.add({
              'name': userDoc['name'] ?? 'غير معروف',
              'phone': userDoc['phone_number'] ?? 'غير متوفر',
              'email': recipientEmail,
            });
          }
        }

        donationData['donationID'] = donationID;
        donationData['recipients'] = recipients;
        donationData['recipientCount'] = recipients.length;

        //print("Donation $donationID has ${recipients.length} delivered recipients");

        return donationData;
      }).toList();

      return await Future.wait(donationFutures);
    } catch (e) {
      print("Error fetching donations: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        _confirmLogout();
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF1FAF2),
        body: Stack(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchDeliveredDonations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "لا توجد طلبات تم تسليمها",
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  );
                }

                var donations = snapshot.data!;

                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, 100, 16, 16),
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    var donation = donations[index];
                    int recipientCount = donation['recipientCount'] ?? 0;

                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Text(
                          "تبرع: ${donation['donationID']}",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32)),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              recipientCount == 0
                                  ? "لا يوجد مستفيدون"
                                  : "$recipientCount ${recipientCount == 1 ? 'مستفيد' : 'مستفيدين'}",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: recipientCount == 0
                                    ? Colors.red
                                    : Colors.grey[700],
                                fontFamily: 'Tajawal',
                                fontSize: 16,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Color(0xFF4CAF50)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => view_past_request(
                                donationData: donation,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),

            // Logout button
            Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              left: 20,
              child: InkWell(
                onTap: _confirmLogout,
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
            // Profile button (Top Right)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              right: 20,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => donor_recipient_profile(userEmail: widget.charityID),
                    ),
                  );
                },
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
                  child: Icon(Icons.person, color: Color(0xFF2E7D32)), // Deep Green
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            "تسجيل الخروج",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
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
                style: TextStyle(
                    color: Colors.black, fontSize: 16, fontFamily: 'Tajawal'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              child: Text(
                "نعم",
                style: TextStyle(
                    color: Colors.red, fontSize: 16, fontFamily: 'Tajawal'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => login_or_signup_screen()),
      (route) => false,
    );
  }
}
