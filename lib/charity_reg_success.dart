import 'package:flutter/material.dart';
import 'package:graduation_project/login_or_signup_screen.dart';
import 'db_helper.dart';

class charity_reg_success extends StatefulWidget {
  @override
  _charity_reg_success createState() => _charity_reg_success();
}

class _charity_reg_success extends State<charity_reg_success> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF1FAF2),
      body: Stack(
        children: [
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "تم ارسال طلب التسجيل يرجى انتظار الموافقة",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
               SizedBox(height: 30),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4CAF50),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
                
              ],
            ),
          ),

          Positioned(
            top: screenHeight * 0.05,
            left: 20,
            child: InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => login_or_signup_screen()),
                  (route) => false,
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
                child: Icon(Icons.arrow_back, color: Color(0xFF2E7D32)), 
              ),
            ),
          ),
        ],
      ),
    );
  }
}
