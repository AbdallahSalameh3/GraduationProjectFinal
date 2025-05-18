import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graduation_project/donor_recipient_reg_success.dart';
import 'db_helper.dart';
import 'package:bcrypt/bcrypt.dart';

class Donor_recipient_reg extends StatefulWidget {
  final String userType;
  const Donor_recipient_reg({Key? key, required this.userType}) : super(key: key);

  @override
  _Donor_recipient_reg createState() => _Donor_recipient_reg();
}

class _Donor_recipient_reg extends State<Donor_recipient_reg> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController sublocationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? selectedCity;
  final List<String> cities = [
    "عمان", "الزرقاء", "إربد", "العقبة", "السلط", "المفرق",
    "مادبا", "الكرك", "جرش", "معان", "عجلون", "الطفيلة"
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF1FAF2),
      body: Stack(
        children: [
          SingleChildScrollView(
             physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      widget.userType == "donor"
                          ? "تسجيل متبرع جديد"
                          : "تسجيل متبرع له جديد",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField("الاسم", "اسمك الكامل", nameController, Icons.person),
                  _buildTextField("البريد الإلكتروني", "example@mail.com", emailController, Icons.email),
                  _buildPhoneField("رقم الهاتف", "مثال:0799999999", phoneNumberController),
                  _buildDropdownField("المدينة", cities),
                  _buildTextField("الموقع الفرعي", "مثال: الدوار السابع", sublocationController, Icons.location_on),
                  const SizedBox(height: 10),
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
                  SizedBox(height: 20),
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

  Widget _buildTextField(String label, String placeholder, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey),
            hintTextDirection: TextDirection.rtl,
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
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
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPhoneField(String label, String placeholder, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey),
            hintTextDirection: TextDirection.rtl,
            prefixIcon: const Icon(Icons.phone, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
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
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isPassword) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        obscureText: isPassword ? !_passwordVisible : !_confirmPasswordVisible,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: isPassword ? "أدخل كلمة المرور" : "تأكيد كلمة المرور",
          hintStyle: TextStyle(color: Colors.grey),
          hintTextDirection: TextDirection.rtl,
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
          suffixIcon: const Icon(Icons.lock, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
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
          if (isPassword && value.length < 6) {
            return "يجب أن تكون كلمة المرور 6 أحرف على الأقل";
          }
          if (!isPassword && value != passwordController.text) {
            return "كلمات المرور غير متطابقة";
          }
          return null;
        },
      ),
      const SizedBox(height: 10),
    ],
  );
}


  Widget _buildDropdownField(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.rtl,
          child: DropdownButtonFormField<String>(
            value: selectedCity,
            dropdownColor: Colors.white,
            decoration:  InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
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

            hint: const Text("اختر المدينة", textAlign: TextAlign.right),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, textDirection: TextDirection.ltr),
            items: items.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
        const SizedBox(height: 10),
      ],
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        String email = emailController.text.trim();
        bool emailExists = await FirebaseDBHelper.checkIfEmailExists(email);

        if (emailExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("البريد الإلكتروني مستخدم بالفعل", textAlign: TextAlign.right),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Hash the password using BCrypt
        String hashedPassword = BCrypt.hashpw(passwordController.text.trim(), BCrypt.gensalt());

        await FirebaseDBHelper.createUser(
          email,
          emailController.text.trim(),
          hashedPassword, // Store the hashed password
          nameController.text.trim(),
          phoneNumberController.text.trim(),
          selectedCity!,
          sublocationController.text.trim(),
        );

        await FirebaseDBHelper.createUserType(email, widget.userType);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => donor_recipient_Reg_success()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ أثناء التسجيل: $e", textAlign: TextAlign.right),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
