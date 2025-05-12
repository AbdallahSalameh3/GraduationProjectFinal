import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/charity_dashboard.dart';
import 'package:graduation_project/donor_interface_requests.dart';
import 'package:graduation_project/recipient_page.dart';
import 'package:graduation_project/login_or_signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/admin_page.dart';
import 'package:graduation_project/admin_dashboard.dart';
import 'package:bcrypt/bcrypt.dart';

class users_login extends StatefulWidget {
  @override
  _users_login createState() => _users_login();
}

class _users_login extends State<users_login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.center)),
    );
  }

  int _failedAttempts = 0;

  Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    if (_failedAttempts >= 3) {
      _showSnackbar("تم إدخال معلومات خاطئة 3 مرات. حاول لاحقًا.");
      return;
    }

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      // -------- Admin Login (Plain Text Password) --------
      var adminQuery = await _firestore.collection("admin")
          .where("email", isEqualTo: email)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        String adminStoredPassword = adminQuery.docs.first['password'];

        if (adminStoredPassword == password) {
          _failedAttempts = 0;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => admin_dashboard()),
            (Route<dynamic> route) => false,
          );
          return;
        } else {
          _failedAttempts++;
          _showSnackbar("كلمة المرور غير صحيحة للمسؤول");
          return;
        }
      }

      // -------- Regular User Login (Hashed Password with Bcrypt) --------
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(email).get();

      if (!userDoc.exists) {
        _failedAttempts++;
        _showSnackbar("المستخدم غير مسجل في النظام");
        return;
      }

      String storedPassword = userDoc['password'];
      if (!BCrypt.checkpw(password, storedPassword)) {
        _failedAttempts++;
        _showSnackbar("البريد الإلكتروني أو كلمة المرور غير صحيحة");
        return;
      }

      _failedAttempts = 0;

      DocumentSnapshot userTypeDoc = await _firestore.collection('usertype').doc(email).get();
      String userType = userTypeDoc.exists ? userTypeDoc['type'] : '';

      if (userType == 'donor') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => donor_interface_requests(donoremail: email)),
          (Route<dynamic> route) => false,
        );
      } else if (userType == 'recipient') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => recipient_page(email: email)),
          (Route<dynamic> route) => false,
        );
      } else if (userType == 'charity') {
        DocumentSnapshot charityDoc = await _firestore.collection('charity').doc(email).get();
        bool validStatus = charityDoc.exists ? charityDoc['validstatus'] : false;

        if (validStatus) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => charity_dashboard(charityID: email)),
            (Route<dynamic> route) => false,
          );
        } else {
          _showSnackbar("لم يتم الموافقة على تسجيلك من قبل المسؤولين بعد");
        }
      }
    } catch (e) {
      _showSnackbar("حدث خطأ، يرجى المحاولة لاحقًا");
    }
  }
}



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF1FAF2), // Light green background
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.20),
                  Image.asset('assets/logo2.png', width: 150, height: 150),
                  Image.asset('assets/at3mni2.png', width: 150, height: 150),
                  _buildTextField("البريد الإلكتروني", "البريد الإلكتروني", emailController, Icons.email, isEmail: true),
                  SizedBox(height: 10),
                  _buildPasswordField("كلمة المرور", passwordController),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: () => _showSnackbar("يرجى التواصل مع الدعم لاستعادة كلمة المرور"),
                    child: Text(
                      "نسيت الرقم السري",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50), // Medium green button color
                      foregroundColor: Colors.white,
                      fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _login,
                    child: Text('الدخول'),
                  ),
                ],
              ),
            ),
          ),

          // Floating Back Button
          Positioned(
            top: screenHeight * 0.05,
            left: 20,
            child: InkWell(
              // onTap: () => Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => login_or_signup_screen()),
              // ),
              onTap: () => Navigator.pop(
                context,
              ),
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

  Widget _buildTextField(String label, String placeholder, TextEditingController controller, IconData icon, {bool isEmail = false}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          //labelText: label,
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.grey),
          hintTextDirection: TextDirection.rtl,
          suffixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            fillColor:Colors.white,
            filled:true,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "هذا الحقل مطلوب";
          if (isEmail && !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}").hasMatch(value)) {
            return "يرجى إدخال بريد إلكتروني صحيح";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        controller: controller,
        obscureText: !_passwordVisible,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          //labelText: label,
          hintText: "أدخل كلمة المرور",
          hintStyle: TextStyle(color: Colors.grey),
          hintTextDirection: TextDirection.rtl,
          prefixIcon: Icon(Icons.lock, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
          ),
          border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            fillColor:Colors.white,
            filled:true,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
        validator: (value) => value == null || value.length < 6 ? "يجب أن تكون كلمة المرور 6 أحرف على الأقل" : null,
      ),
    );
  }
}
