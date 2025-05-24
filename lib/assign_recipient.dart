import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'charity_dashboard.dart';

class assign_recipient extends StatefulWidget {
  final String donationId;
  final String charityID;

  assign_recipient({required this.donationId, required this.charityID});

  @override
  _assign_recipient createState() => _assign_recipient();
}

class _assign_recipient extends State<assign_recipient> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, bool> selectedRecipients = {};
  Future<List<Map<String, dynamic>>>? _recipientFuture;

  @override
  void initState() {
    super.initState();
    _recipientFuture = fetchRecipients(); 
  }

  Future<List<Map<String, dynamic>>> fetchRecipients() async {
    try {
      QuerySnapshot userTypeSnapshot = await _firestore
          .collection('usertype')
          .where('type', isEqualTo: 'recipient')
          .get();

      List<String> recipientEmails = userTypeSnapshot.docs
          .map((doc) => doc['userID'] as String)
          .toList();

      if (recipientEmails.isEmpty) return [];
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('email', whereIn: recipientEmails)
          .get();

      QuerySnapshot assignedSnapshot = await _firestore
          .collection('recipients')
          .where('donationID', isEqualTo: widget.donationId)
          .where('status', isEqualTo: 'assigned')
          .get();

      List<String> assignedEmails = assignedSnapshot.docs
          .map((doc) => doc['recipientID'] as String)
          .toList();

      for (String email in assignedEmails) {
        selectedRecipients[email] = true;
      }

      return userSnapshot.docs.map((doc) {
        return {
          'email': doc['email'],
          'name': doc['name'],
          'phoneNumber': doc['phone_number'],
          'location': doc['city'],
        };
      }).toList();
    } catch (e) {
      print("Error fetching recipients: $e");
      return [];
    }
  }

  void assignRecipients() async {
    try {
      List<String> selectedEmails = selectedRecipients.keys
          .where((email) => selectedRecipients[email]!)
          .toList();

      QuerySnapshot existingAssignments = await _firestore
          .collection('recipients')
          .where('donationID', isEqualTo: widget.donationId)
          .where('status', isEqualTo: 'assigned')
          .get();

      WriteBatch batch = _firestore.batch();

      for (var doc in existingAssignments.docs) {
        batch.delete(doc.reference);
      }

      for (String email in selectedEmails) {
        DocumentReference recipientRef =
            _firestore.collection('recipients').doc();

        batch.set(recipientRef, {
          'recipientID': email,
          'donationID': widget.donationId,
          'charityID': widget.charityID,
          'assignedDate': Timestamp.now(),
          'status': 'assigned',
        });
      }

      DocumentReference donationRef =
          _firestore.collection('donation').doc(widget.donationId);
      batch.update(donationRef, {
        'status': 'assigned',
        'charityID': widget.charityID,
      });

      await batch.commit();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              charity_dashboard(charityID: widget.charityID, initialIndex: 1),
        ),
      );
    } catch (e) {
      print("Error assigning recipients: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF1FAF2),
      body: Stack(
        children: [
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
          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.10),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _recipientFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "لا يوجد مستفيدون متاحون",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                var recipients = snapshot.data!;
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: recipients.length,
                        itemBuilder: (context, index) {
                          var recipient = recipients[index];
                          return Card(
                            color: Colors.white,
                            elevation: 3,
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              title: Text(
                                recipient['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text("رقم الهاتف: ${recipient['phoneNumber']}"),
                                  Text("الموقع: ${recipient['location']}"),
                                ],
                              ),
                              trailing: Checkbox(
                                activeColor: Color(0xFF4CAF50),
                                value: selectedRecipients[
                                        recipient['email']] ??
                                    false,
                                onChanged: (bool? value) {
                                  setState(() {
                                    selectedRecipients[recipient['email']] =
                                        value ?? false;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          textStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: assignRecipients,
                        child: Text(
                          "تعيين المستفيدين",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
