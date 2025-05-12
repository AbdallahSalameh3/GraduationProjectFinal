import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/admin_page.dart';
import 'package:graduation_project/login_or_signup_screen.dart';
import 'package:graduation_project/users_login.dart';
import 'package:graduation_project/admin_page.dart';

class admin_login extends StatefulWidget {
  @override
  _admin_login createState() => _admin_login();
}

class _admin_login extends State<admin_login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;
  int loginAttempts = 0; // Track failed login attempts

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, textAlign: TextAlign.center)),
    );
  }

  void _showAttemptsExceededDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: Text("تم تجاوز الحد"),
        content: Text("لقد تجاوزت 3 محاولات تسجيل دخول غير صحيحة."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => login_or_signup_screen()),
              );
            },
            child: Text("موافق"),
          ),
        ],
      ),
    );
  }

  Future<void> _loginAdmin() async {
    if (_formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      try {
        var querySnapshot = await FirebaseFirestore.instance
            .collection("admin")
            .where("email", isEqualTo: email)
            .where("password", isEqualTo: password)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Login successful, redirect to admin_page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => admin_page()),
          );
        } else {
          // Login failed
          loginAttempts++;
          if (loginAttempts >= 3) {
            _showAttemptsExceededDialog();
          } else {
            _showSnackbar("البريد الإلكتروني أو كلمة المرور غير صحيحة");
          }
        }
      } catch (e) {
        _showSnackbar("حدث خطأ أثناء تسجيل الدخول، حاول مرة أخرى");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => login_or_signup_screen()),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20), // Added extra right padding
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => users_login()),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 12),
                  Icon(Icons.person, size: 24, color: Colors.black),
                  SizedBox(height: 4),
                  Text(
                    "User",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

      ),
      body: SingleChildScrollView(
  child: Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100), // Add some top spacing
            Image.asset('assets/logo.png', width: 120, height: 120),
            Image.asset('assets/At3mni.png', width: 120, height: 120),
            _buildTextField("البريد الإلكتروني", "أدخل بريدك الإلكتروني", emailController, Icons.email, isEmail: true),
            SizedBox(height: 10),
            _buildPasswordField("كلمة المرور", passwordController),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _loginAdmin,
              child: Text('الدخول'),
            ),
            SizedBox(height: 50), // Add some bottom spacing
          ],
        ),
      ),
    ),
  ),
),

    );
  }

  Widget _buildTextField(String label, String placeholder, TextEditingController controller, IconData icon, {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
        suffixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "هذا الحقل مطلوب";
        }
        if (isEmail && !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
          return "يرجى إدخال بريد إلكتروني صحيح";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      obscureText: !_passwordVisible,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        hintText: "أدخل كلمة المرور",
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
        suffixIcon: Icon(Icons.lock, color: Colors.grey),
        prefixIcon: IconButton(
          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "هذا الحقل مطلوب";
        }
        if (value.length < 6) {
          return "يجب أن تكون كلمة المرور 6 أحرف على الأقل";
        }
        return null;
      },
    );
  }
}
