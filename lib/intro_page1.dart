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
    double imageSize = screenWidth * 0.55; 

    return Scaffold(
      backgroundColor: Color(0xFFF1FAF2), 
      body: Center(
        child: SingleChildScrollView( 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo2.png',
                width: imageSize,
                height: imageSize,
                fit: BoxFit.contain,
              ),
              Image.asset(
                'assets/at3mni2.png',
                width: imageSize,
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
