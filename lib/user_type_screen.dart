import 'package:flutter/material.dart';
import 'package:graduation_project/Donor_recipient_reg.dart';
import 'package:graduation_project/donor_interface_requests.dart';
import 'package:graduation_project/charity_reg.dart';

class user_type_screen extends StatefulWidget {
  @override
  _user_type_screen createState() => _user_type_screen();
}

class _user_type_screen extends State<user_type_screen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF1FAF2), 
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 70),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "اختر نوع المستخدم الخاص بك",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  buildUserTypeCard(
                    context,
                    title: 'متبرع',
                    description: 'يمكنك التبرع بالطعام للمحتاجين من خلال التطبيق',
                    color: Colors.white,
                    imagePath: 'assets/donor_logo2.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Donor_recipient_reg(userType: "donor")),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  buildUserTypeCard(
                    context,
                    title: 'متبرع له',
                    description: 'يمكنك الحصول على تبرعات الطعام من خلال التطبيق',
                    color: Colors.white,
                    imagePath: 'assets/recipient_logo2.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Donor_recipient_reg(userType: "recipient")),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  buildUserTypeCard(
                    context,
                    title: 'جمعية خيرية',
                    description: 'وظيفتكم هي استقبال التبرعات و ارسالها لمن يحتاجها',
                    color: Colors.white,
                    imagePath: 'assets/charity_logo2.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => charity_reg()),
                      );
                    },
                  ),
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
                      offset: Offset(0, 2),
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

  Widget buildUserTypeCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        shadowColor: Colors.grey.withOpacity(0.3),
        child: Container(
          width: screenWidth * 0.9,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF1FAF2),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                            color: Color(0xFF4CAF50), 
                          ),
                          textAlign: TextAlign.center, 
                        ),
                        const SizedBox(height: 10),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Tajawal',
                            color: Colors.grey[700], 
                          ),
                          textAlign: TextAlign.center, 
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
