import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class recipient_donation_details extends StatefulWidget {
  final String email;

  const recipient_donation_details({Key? key, required this.email}) : super(key: key);

  @override
  State<recipient_donation_details> createState() => _recipient_donation_details();
}

class _recipient_donation_details extends State<recipient_donation_details> {
  List<Map<String, dynamic>> donationDetails = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDonationDetails();
  }

  Future<void> fetchDonationDetails() async {
    setState(() {
      isLoading = true;
    });

    final recipientSnapshot = await FirebaseFirestore.instance
        .collection('recipients')
        .where('recipientID', isEqualTo: widget.email)
        .get();

    List<Map<String, dynamic>> details = [];

    for (var doc in recipientSnapshot.docs) {
      final data = doc.data();
      final donationID = data['donationID'];
      final charityID = data['charityID'];

      final charitySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: charityID)
          .limit(1)
          .get();

      String charityName = charitySnapshot.docs.isNotEmpty
          ? charitySnapshot.docs.first['name'] ?? 'غير معروف'
          : 'غير معروف';

      final donationDoc = await FirebaseFirestore.instance
          .collection('donation')
          .doc(donationID)
          .get();

      if (donationDoc.exists) {
        final donationData = donationDoc.data()!;

        String foodType = 'غير محدد';
        String donationDate = 'غير محدد';
        DateTime? donationDateTime;

        try {
          Timestamp timestamp = donationData['donationdate'];
          donationDateTime = timestamp.toDate();
          donationDate = '${donationDateTime.year}-${donationDateTime.month.toString().padLeft(2, '0')}-${donationDateTime.day.toString().padLeft(2, '0')}';
        } catch (e) {}

        try {
          foodType = donationData['foodtype'] ?? 'غير محدد';
        } catch (e) {}

        details.add({
          'charityName': charityName,
          'foodType': foodType,
          'donationDate': donationDate,
          'donationDateTime': donationDateTime,
        });
      }
    }

    details.sort((a, b) {
      DateTime? dateA = a['donationDateTime'];
      DateTime? dateB = b['donationDateTime'];
      if (dateA == null || dateB == null) return 0;
      return dateB.compareTo(dateA);
    });

    for (var item in details) {
      item.remove('donationDateTime');
    }

    setState(() {
      donationDetails = details;
      isLoading = false;
    });
  }

  @override
Widget build(BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;

  return Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: Color(0xFFF1FAF2),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 100),
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'تفاصيل التبرعات التي تلقيتها',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                      fontFamily: 'Tajawal',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                if (isLoading)
                  Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
                else if (donationDetails.isEmpty)
                  Center(
                    child: Text(
                      'لا توجد تبرعات حتى الآن.',
                      style: TextStyle(fontSize: 18, fontFamily: 'Tajawal'),
                    ),
                  )
                else
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: donationDetails.length,
                    itemBuilder: (context, index) {
                      final item = donationDetails[index];
                      return Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اسم الجمعية: ${item['charityName']}',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D32),
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'تاريخ التبرع: ${item['donationDate']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'نوع الطعام: ${item['foodType']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
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
                child: Icon(Icons.arrow_forward, color: Color(0xFF2E7D32)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
