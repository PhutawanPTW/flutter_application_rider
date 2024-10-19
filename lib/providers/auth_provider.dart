import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoggedIn = false;
  String? currentUserType;
   String? currentUserPhoneNumber; 

  String? email;
  String? phoneNumber;
  String? password;
  String? fullName;
  String? address;
  String? registrationNumber;
  LatLng? selectedPosition;

  void setUserDetails({
    required String email,
    required String phoneNumber,
    required String password,
    required String fullName,
    String? address,
    String? registrationNumber,
    LatLng? selectedPosition,
  }) {
    this.email = email;
    this.phoneNumber = phoneNumber;
    this.password = password;
    this.fullName = fullName;
    this.address = address;
    this.registrationNumber = registrationNumber;
    this.selectedPosition = selectedPosition;
    notifyListeners();
  }

  // Check if phone number is unique between users and riders
  Future<bool> isPhoneNumberUnique(String phoneNumber) async {
    final userQuery = await _firestore
        .collection('Users')
        .doc(phoneNumber)
        .get(); // Check if user exists with this phone number

    return !userQuery.exists;
  }

Future<void> loginUser(String phoneNumber, String password) async {
    try {
      // Query Firestore to get the user document by phoneNumber
      DocumentSnapshot userDoc = await _firestore
          .collection('Users')
          .doc(phoneNumber)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;

        // Check if the password matches
        if (userData['password'] == password) {
          isLoggedIn = true;
          currentUserPhoneNumber = phoneNumber; // เก็บเบอร์โทรของผู้ใช้
          notifyListeners(); // Notify the listeners about the change
        } else {
          throw Exception('Incorrect password');
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> signUpUser(String userType) async {
    try {
      bool isUnique = await isPhoneNumberUnique(phoneNumber!);
      if (!isUnique) {
        throw Exception("Phone number already exists for another user.");
      }

      Map<String, dynamic> userData = {
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password, // Please encrypt this in production
        'fullName': fullName,
        'userType': userType,
        'createdAt': Timestamp.now(),
      };

      if (userType == "User") {
        userData['location'] = selectedPosition != null
            ? {
                'latitude': selectedPosition!.latitude,
                'longitude': selectedPosition!.longitude,
              }
            : null;
      } else if (userType == "Rider" && registrationNumber != null) {
        userData['registrationNumber'] = registrationNumber;
      }

      await _firestore.collection('Users').doc(phoneNumber).set(userData);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Method to log out user
  void logoutUser() {
    isLoggedIn = false;
    currentUserPhoneNumber = null;
    notifyListeners();
  }
}
