import 'package:flutter/material.dart';
import 'package:graduation_project/donor_interface_requests.dart';
import 'package:graduation_project/user_type_screen.dart';
import 'package:graduation_project/users_login.dart';

class login_or_signup_screen extends StatefulWidget {
  @override
  _login_or_signup_screen createState() => _login_or_signup_screen();
}

class _login_or_signup_screen extends State<login_or_signup_screen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFF1FAF2), // Light green background
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/logo2.png',
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.2,
                  fit: BoxFit.contain,
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/at3mni2.png',
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.2,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50), 
                  foregroundColor: Colors.white,
                  fixedSize: Size(screenWidth * 0.8, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => users_login()),
                  );
                },
                child: const Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF4CAF50), // Green border color
                  fixedSize: Size(screenWidth * 0.8, 50),
                  side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => user_type_screen()),
                  );
                },
                child: const Text(
                  'انشاء مستخدم جديد',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
