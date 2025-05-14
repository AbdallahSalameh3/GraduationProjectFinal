import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'db_helper.dart';
import 'charity_reg_success.dart';
import 'package:bcrypt/bcrypt.dart';

class charity_reg extends StatefulWidget {
  @override
  _charity_reg createState() => _charity_reg();
}

class _charity_reg extends State<charity_reg> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController sublocationController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String userType = "charity";
  String? selectedCity;
  List<String> cities = [
    "عمان", "إربد", "الزرقاء", "السلط", "المفرق", "الكرك",
    "معان", "الطفيلة", "العقبة", "جرش", "عجلون", "مادبا"
  ];

  void _register() async {
    if (_formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();
      String confirmPassword = confirmPasswordController.text.trim();

      if (password != confirmPassword) {
        _showSnackbar("كلمتا المرور غير متطابقتين", Colors.red);
        return;
      }

      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      String name = nameController.text.trim();
      String phoneNumber = phoneNumberController.text.trim();
      String city = selectedCity ?? "";
      String sublocation = sublocationController.text.trim();
      String licenseNumber = licenseNumberController.text.trim();

      try {
        bool emailExists = await FirebaseDBHelper.checkIfEmailExists(email);
        if (emailExists) {
          _showSnackbar("هذا البريد الإلكتروني مستخدم بالفعل", Colors.red);
          return;
        }

        await FirebaseDBHelper.createUser(email, email, hashedPassword, name, phoneNumber, city, sublocation);
        await FirebaseDBHelper.createUserType(email, userType);
        await FirebaseDBHelper.createCharity(email, licenseNumber, false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => charity_reg_success()),
        );
      } catch (e) {
        _showSnackbar("حدث خطأ أثناء التسجيل: $e", Colors.red);
      }
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: color,
      ),
    );
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
             physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  // Title
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      "تسجيل جمعية خيرية جديدة",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  _buildTextField("اسم المؤسسة", "أدخل اسم المؤسسة", nameController, Icons.business, true),
                  _buildTextField("البريد الإلكتروني", "example@mail.com", emailController, Icons.email, true, isEmail: true),
                  _buildDropdown("المدينة", cities),
                  _buildTextField("المنطقة الفرعية", "أدخل المنطقة الفرعية", sublocationController, Icons.location_on, true),
                  _buildPhoneField("رقم الهاتف", "مثال: 0777777777", phoneNumberController),
                  _buildTextField("رقم شهادة الترخيص", "أدخل رقم شهادة الترخيص", licenseNumberController, Icons.article, false),
                  _buildPasswordField("كلمة المرور", passwordController, true),
                  _buildPasswordField("تأكيد كلمة المرور", confirmPasswordController, false),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                      onPressed: _register,
                      child: const Text("تسجيل"),
                    ),
                  ),
                  SizedBox(height: 20)
                ],
              ),
            ),
          ),
          // Floating Back Button
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

  Widget _buildTextField(
    String label,
    String placeholder,
    TextEditingController controller,
    IconData icon,
    bool isRequired, {
    bool isEmail = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey),
            hintTextDirection: TextDirection.rtl,
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return "هذا الحقل مطلوب";
            }
             if (isEmail && value != null && !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
              return "يرجى إدخال بريد إلكتروني صحيح";
            }
            return null;
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPhoneField(String label, String placeholder, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey),
            hintTextDirection: TextDirection.rtl,
            prefixIcon: Icon(Icons.phone, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "هذا الحقل مطلوب";
            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
              return "يجب أن يحتوي على أرقام فقط";
            }
            return null;
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2E7D32),
        ),
      ),
      SizedBox(height: 8),
      Directionality(
        textDirection: TextDirection.rtl,
        child: DropdownButtonFormField<String>(
          value: selectedCity,
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
          ),
          hint: Text(
            "اختر المدينة",
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.grey), // Apply style here
          ),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, textDirection: TextDirection.ltr),
          items: items.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(city),
                ),
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
      SizedBox(height: 10),
    ],
  );
}


  Widget _buildPasswordField(String label, TextEditingController controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? !_passwordVisible : !_confirmPasswordVisible,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            prefixIcon: IconButton(
              icon: Icon(
                isPassword
                    ? (_passwordVisible ? Icons.visibility : Icons.visibility_off)
                    : (_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  if (isPassword) {
                    _passwordVisible = !_passwordVisible;
                  } else {
                    _confirmPasswordVisible = !_confirmPasswordVisible;
                  }
                });
              },
            ),
            hintText: isPassword ? "أدخل كلمة المرور" : "تأكيد كلمة المرور",
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return "هذا الحقل مطلوب";
            return null;
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
