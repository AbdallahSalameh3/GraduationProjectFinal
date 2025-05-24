import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseDBHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> checkIfEmailExists(String email) async {
    var querySnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty;
  }


  static Future<void> createUser(String userID, String email, String password, String name, String phoneNumber, String city, String sublocation) async {
    await _firestore.collection('users').doc(userID).set({
      'email': email,
      'password': password,
      'name': name,
      'phone_number': phoneNumber,
      'city': city,
      'sublocation': sublocation,
    });
  }

  static Future<void> createUserType(String userID, String type) async {
    await _firestore.collection('usertype').doc(userID).set({
      'userID': userID,
      'type': type,
    });
  }

  static Future<void> createAdmin(String adminID, String email, String password) async {
    await _firestore.collection('admin').doc(adminID).set({
      'email': email,
      'password': password,
    });
  }


  static Future<void> createCharity(String charityID, String license, bool validStatus) async {
    await _firestore.collection('charity').doc(charityID).set({
      'license': license,
      'validstatus': validStatus,
      'rejected': false,
    });
  }


  static Future<void> createFoodType(String typeID, String name, int validityDays) async {
    await _firestore.collection('foodtype').doc(typeID).set({
      'name': name,
      'validitydays': validityDays,
    });
  }

  static Future<void> createDonation(
      String donationID,
      String donorID,
      String charityID,
      String city,
      String sublocation,
      String location,
      DateTime donationDate,
      DateTime expiryDate,
      String status,
      String? additionalInfo,
      String? pickupTime,
      String? foodType) async {

    await _firestore.collection('donation').doc(donationID).set({
      'donorID': donorID,
      'charityID': charityID,
      'city': city,
      'sublocation': sublocation,
      'donationdate': Timestamp.fromDate(donationDate),
      'expirydate': Timestamp.fromDate(expiryDate),   
      'status': status,
      'additionalInfo': additionalInfo,
      'pickupTime': pickupTime,
      'foodtype': foodType,
    });
  }


  static Future<void> createRecipient(String email, String donationID, DateTime receivedDate, String status) async {
    try {
      await _firestore.collection('recipients').doc(email).set({
        'donationID': donationID,
        'receivedDate': receivedDate.toIso8601String(),
        'status': status,
      });
    } catch (e) {
      print("Error creating recipient: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getUsersByType(String type) async {
    QuerySnapshot snapshot = await _firestore.collection('users')
        .where('type', isEqualTo: type)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
