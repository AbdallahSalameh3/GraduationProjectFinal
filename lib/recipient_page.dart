import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/login_or_signup_screen.dart';
import 'package:graduation_project/donor_recipient_profile.dart';
import 'package:graduation_project/recipient_donation_details.dart';

class recipient_page extends StatefulWidget {
  final String email;  

  const recipient_page({Key? key, required this.email}) : super(key: key);  

  @override
  _recipient_page createState() => _recipient_page();
}

class _recipient_page extends State<recipient_page> {
  int _donationCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDonationCount(widget.email);  
  }

  // Count donations for this recipient
  void _fetchDonationCount(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('recipients')
        .where('recipientID', isEqualTo: email)
        .get();

    setState(() {
      _donationCount = querySnapshot.docs.length;
    });
  }

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


  @override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "أنت الآن مسجل وستتواصل معك الجمعيات الخيرية بمجرد توفر التبرعات لك",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Container(
                  child: Image.asset('assets/recipient_interface.png'),
                  height: 250,
                  width: 250,
                ),
                SizedBox(height: 20),
                Text(
                  "عدد التبرعات التي تلقيتها: $_donationCount",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => recipient_donation_details(email: widget.email),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50), 
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'عرض تفاصيل التبرعات',
                    style: TextStyle(fontSize: 16, fontFamily: 'Tajawal', color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: screenHeight * 0.05,
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

          Positioned(
            top: screenHeight * 0.05,
            right: 20,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => donor_recipient_profile(userEmail: widget.email),
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
