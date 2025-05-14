import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/donation_request_form.dart';
import 'package:graduation_project/login_or_signup_screen.dart';
import 'package:graduation_project/donor_view_donation.dart';
import 'package:intl/intl.dart';
import 'package:graduation_project/donor_recipient_profile.dart';

class donor_interface_requests extends StatefulWidget {
  final String donoremail;

  donor_interface_requests({required this.donoremail});

  @override
  _donor_interface_requests createState() => _donor_interface_requests();
}

class _donor_interface_requests extends State<donor_interface_requests> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _confirmLogout() {
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
                _logout();
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

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => login_or_signup_screen()),
      (Route<dynamic> route) => false,
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _confirmLogout();
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF1FAF2),
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80.0), // Space for floating button
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 70),
                      Center(
                        child: Text(
                          'طلبات التبرع السابقة',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('donation')
                            .where('donorID', isEqualTo: widget.donoremail.trim())
                            .orderBy('donationdate', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(child: Text("لا يوجد تبرعات"));
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var donation = snapshot.data!.docs[index];
                              return Card(
                                color: Colors.white,
                                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 5,
                                child: ListTile(
                                  title: Text(
                                    "تبرع - ${donation['foodtype']}",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                  ),
                                  subtitle: Text(
                                    "التاريخ: ${_formatDate(donation['donationdate'])}",
                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF4CAF50)),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => donor_view_donation(donation: donation),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Floating Donate Now Button
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => donation_request_form(donoremail: widget.donoremail),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('تبرع الآن', style: TextStyle(fontSize: 16)),
              ),
            ),

            // Logout button (Top Left)
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
                      builder: (context) => donor_recipient_profile(userEmail: widget.donoremail),
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
                  child: Icon(Icons.person, color: Color(0xFF2E7D32)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
