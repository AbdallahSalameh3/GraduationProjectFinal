import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseDBHelper {
  // Reference to Firestore collections
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> checkIfEmailExists(String email) async {
    var querySnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty;
  }


  // Create a new user in the 'users' collection
  static Future<void> createUser(String userID, String email, String password, String name, String phoneNumber, String city, String sublocation) async {
    await _firestore.collection('users').doc(userID).set({
      'email': email,
      'password': password, // In a real app, hash the password
      'name': name,
      'phone_number': phoneNumber,
      'city': city,
      'sublocation': sublocation,
    });
  }

  // Create a new usertype (linking user to a type)
  static Future<void> createUserType(String userID, String type) async {
    await _firestore.collection('usertype').doc(userID).set({
      'userID': userID,
      'type': type,
    });
  }

  // Create an admin
  static Future<void> createAdmin(String adminID, String email, String password) async {
    await _firestore.collection('admin').doc(adminID).set({
      'email': email,
      'password': password, // In a real app, hash the password
    });
  }

  // Create a charity
  static Future<void> createCharity(String charityID, String license, bool validStatus) async {
    await _firestore.collection('charity').doc(charityID).set({
      'license': license,
      'validstatus': validStatus,
      'rejected': false,
    });
  }

  // Create a foodtype
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
      'donationdate': Timestamp.fromDate(donationDate), // Store as Firestore Timestamp
      'expirydate': Timestamp.fromDate(expiryDate),     // Store as Firestore Timestamp
      'status': status,
      'additionalInfo': additionalInfo,
      'pickupTime': pickupTime,
      'foodtype': foodType,
    });
  }


  // Create a recipient
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


  // Fetch users with a specific type (e.g., donor)
  static Future<List<Map<String, dynamic>>> getUsersByType(String type) async {
    QuerySnapshot snapshot = await _firestore.collection('users')
        .where('type', isEqualTo: type)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
