import 'package:flutter/material.dart';
import 'package:graduation_project/intro_page2.dart';

class intro_page1 extends StatefulWidget {
  @override
  _intro_page1 createState() => _intro_page1();
}

class _intro_page1 extends State<intro_page1> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => intro_page2()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double imageSize = screenWidth * 0.55; // Adjusted a bit smaller for elegance

    return Scaffold(
      // Soft background color
      backgroundColor: Color(0xFFF1FAF2), // very light greenish background

      body: Center(
        child: SingleChildScrollView( // Prevent overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hands Logo
              Image.asset(
                'assets/logo2.png',
                width: imageSize,
                height: imageSize,
                fit: BoxFit.contain,
              ),
              
              //SizedBox(height: 20), // Space between images

              // App Name Text Logo
              Image.asset(
                'assets/at3mni2.png',
                width: imageSize, // slightly smaller for balance
                height: imageSize,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
