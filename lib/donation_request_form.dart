import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class donation_request_form extends StatefulWidget {
  final String donoremail;

  donation_request_form({required this.donoremail});

  @override
  _donation_request_form createState() => _donation_request_form();
}

class _donation_request_form extends State<donation_request_form> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> cities = [
    'عمان', 'إربد', 'المفرق', 'معان', 'الكرك', 'جرش', 'عجلون', 'الطفيلة', 'البلقاء', 'مادبا', 'الزرقاء'
  ];
  List<String> foodTypes = ["متفرقات", "طرد خيري", "طبيخ", "معلبات"];

  String? selectedCity;
  String? selectedFoodType;
  TextEditingController additionalInfo = TextEditingController();
  TextEditingController pickupTime = TextEditingController();
  TextEditingController sublocation = TextEditingController();

  Future<int> _generateDonationID() async {
    DocumentReference counterRef = FirebaseFirestore.instance.collection('counters').doc('donationCounter');

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot counterSnapshot = await transaction.get(counterRef);

      if (!counterSnapshot.exists) {
        throw Exception("Counter document does not exist!");
      }

      int newID = (counterSnapshot['lastID'] ?? 0) + 1; // Get last ID and increment

      transaction.update(counterRef, {'lastID': newID}); // Update counter in Firestore

      return newID;
    });
  }

  Future<void> _submitDonation() async {
    if (selectedCity == null || selectedFoodType == null || pickupTime.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')));
      return;
    }

    try {
      int donationID = await _generateDonationID();
      String donationIDString = donationID.toString(); // Convert only after awaiting
      // Fetch food type document to get validityDays
      QuerySnapshot foodTypeSnapshot = await _firestore
          .collection('foodType')
          .where('foodType', isEqualTo: selectedFoodType)
          .limit(1)
          .get();

      if (foodTypeSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ في استرجاع بيانات الطعام')));
        return;
      }

      int validityDays = foodTypeSnapshot.docs.first['validityDays'];
      DateTime donationDate = DateTime.now();
      DateTime expiryDate = donationDate.add(Duration(days: validityDays));

      await _firestore.collection('donation').doc(donationIDString).set({
        'donorID': widget.donoremail,
        'charityID': null, // No charity assigned yet
        'city': selectedCity,
        'sublocation': sublocation.text.trim(),
        'donationdate': Timestamp.fromDate(donationDate), // Store as Firestore Timestamp
        'expirydate': Timestamp.fromDate(expiryDate),
        'status': 'sent', // Initial status
        'additionalInfo': additionalInfo.text.trim(),
        'foodtype': selectedFoodType,
        'pickupTime': pickupTime.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إرسال التبرع بنجاح'), backgroundColor:Colors.green));
      Navigator.pop(context); // Go back after submission
    } catch (e) {
      print("Error saving donation: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء حفظ التبرع')));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF1FAF2),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 60), 
                    Center(
                      child: Text('التبرع', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                    ),
                    SizedBox(height: 30),
                    _buildDropdown('المدينة', cities, selectedCity, (value) {
                      setState(() => selectedCity = value);
                    }),
                    SizedBox(height: 10),
                    _buildTextField('الموقع الفرعي', sublocation),
                    SizedBox(height: 10),
                    _buildDropdown('نوع الطعام', foodTypes, selectedFoodType, (value) {
                      setState(() => selectedFoodType = value);
                    }),
                    SizedBox(height: 10),
                    _buildTextField('تفاصيل / ملاحظات اضافية', additionalInfo, maxLines: 3),
                    SizedBox(height: 10),
                    _buildTextField('وقت الاستلام المناسب', pickupTime),
                    SizedBox(height: 30),
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
                        onPressed: _submitDonation,
                        child: Text('إرسال'),
                      ),
                    ),
                    SizedBox(height: 20), // Add extra space at the bottom
                  ],
                ),
              ),
            ),
            // Back Button
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
                  child: Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:Color(0xFF2E7D32))),
      SizedBox(height: 10),
      Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          //border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text('يرجى الاختيار'),
            isExpanded: true,
            underline: SizedBox(),
            onChanged: onChanged,
            dropdownColor: Colors.white, // Set background color of the dropdown items
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Align(alignment: Alignment.centerRight, child: Text(value)),
              );
            }).toList(),
          ),
        ),
      ),
    ],
  );
}


  Widget _buildTextField(String hint, TextEditingController controller, {int maxLines = 1}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    textAlign: TextAlign.right,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: InputBorder.none, // Remove all borders
    ),
  );
}

}
