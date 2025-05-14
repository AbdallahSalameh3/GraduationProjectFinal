import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';

class donor_recipient_profile extends StatefulWidget {
  final String userEmail;

  donor_recipient_profile({required this.userEmail});

  @override
  _donor_recipient_profile createState() => _donor_recipient_profile();
}

class _donor_recipient_profile extends State<donor_recipient_profile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController sublocationController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  String? storedPassword;
  String? selectedCity;

  final List<String> cities = [
    "عمان", "الزرقاء", "إربد", "العقبة", "السلط", "المفرق", "مادبا", "الكرك", "جرش", "معان", "عجلون", "الطفيلة"
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userEmail).get();
    if (userDoc.exists) {
      var userData = userDoc.data();
      setState(() {
        nameController.text = userData?['name'] ?? '';
        emailController.text = userData?['email'] ?? '';
        phoneController.text = userData?['phone_number'] ?? '';
        sublocationController.text = userData?['sublocation'] ?? '';
        storedPassword = userData?['password'];
        selectedCity = userData?['city'];
      });
    }
  }

  void updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    String newPassword = newPasswordController.text.trim();
    String currentPassword = currentPasswordController.text.trim();

    String passwordToSave = storedPassword!;

    // Only validate and update password if newPassword is not empty
    if (newPassword.isNotEmpty) {
      if (currentPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("يرجى إدخال كلمة المرور الحالية لتغيير كلمة المرور"), backgroundColor: Colors.red),
        );
        return;
      }

      bool isPasswordCorrect = BCrypt.checkpw(currentPassword, storedPassword ?? '');
      if (!isPasswordCorrect) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("كلمة المرور الحالية غير صحيحة"), backgroundColor: Colors.red),
        );
        return;
      }

      passwordToSave = BCrypt.hashpw(newPassword, BCrypt.gensalt());
    }

    await FirebaseFirestore.instance.collection('users').doc(widget.userEmail).update({
      'name': nameController.text.trim(),
      'phone_number': phoneController.text.trim(),
      'city': selectedCity,
      'sublocation': sublocationController.text.trim(),
      'password': passwordToSave,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم تحديث الملف الشخصي بنجاح"), backgroundColor: Colors.green),
    );

    // Clear password fields after update
    currentPasswordController.clear();
    newPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFF1FAF2),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  SizedBox(height: 60),
                  Center(
                    child: Text(
                      'تعديل الملف الشخصي',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField("الاسم", nameController, Icons.person),
                  _buildTextField("البريد الإلكتروني", emailController, Icons.email, enabled: false),
                  _buildTextField("رقم الهاتف", phoneController, Icons.phone),
                  _buildDropdownField("المدينة", cities),
                  _buildTextField("الموقع الفرعي", sublocationController, Icons.location_on),
                  _buildTextField("كلمة المرور الحالية", currentPasswordController, Icons.lock, obscureText: true, enabled: true),
                  _buildTextField("كلمة المرور الجديدة (اختياري)", newPasswordController, Icons.lock, obscureText: true, enabled: true),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: updateProfile,
                    child: Text("تحديث الملف الشخصي"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20)
                ],
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.05,
            left: 20,
            child: InkWell(
              onTap: () => Navigator.pop(context),
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
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool obscureText = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 18)),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: label == "رقم الهاتف" ? TextInputType.phone : TextInputType.text,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if ((label == "كلمة المرور الحالية" || label == "كلمة المرور الجديدة (اختياري)") && value!.isEmpty) {
              return null;
            }
            if (value == null || value.isEmpty) return "هذا الحقل مطلوب";
            if (label == "رقم الهاتف" && !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
              return "يجب أن يكون رقم الهاتف مكونًا من 10 أرقام";
            }
            return null;
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 18)),
        SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: selectedCity,
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              hint: Text("اختر المدينة", textAlign: TextAlign.right),
              icon: Icon(Icons.arrow_drop_down, color: Color(0xFF2E7D32)),
              items: items.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Text(city, textAlign: TextAlign.right),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value;
                });
              },
              validator: (value) => value == null ? "يرجى اختيار المدينة" : null,
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
