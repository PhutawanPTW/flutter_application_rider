import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _userData = {};
  Map<String, dynamic> get userData => _userData;

  // Fetch user data after login
  void setUserData(Map<String, dynamic> data) {
    _userData = data;
    notifyListeners();
  }

  Future<void> fetchUserData(String phone) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(phone).get();
      if (userDoc.exists) {
        setUserData(userDoc.data() ?? {});
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void clearUserData() {
    _userData = {};
    notifyListeners();
  }
}
