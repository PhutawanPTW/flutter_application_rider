import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _profileImageUrl;
  String? get profileImageUrl => _profileImageUrl;

  Map<String, dynamic> _userData = {};
  Map<String, dynamic> get userData => _userData;

  // Fetch user data after login
  Future<Map<String, dynamic>?> fetchUserData(String phoneNumber) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(phoneNumber) // หรือ query by phoneNumber
          .get();

      if (snapshot.exists) {
        return snapshot.data(); // คืนค่าข้อมูลของผู้ใช้
      } else {
        return null; // ถ้าไม่เจอข้อมูล คืนค่า null
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllUsersExcludingCurrent(
      String currentPhone) async {
    try {
      final querySnapshot = await _firestore
          .collection('Users')
          .where('userType', isEqualTo: 'User')
          .where('phoneNumber', isNotEqualTo: currentPhone)
          .get();

      List<Map<String, dynamic>> users = [];
      for (var doc in querySnapshot.docs) {
        users.add(doc.data());
      }
      return users;
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchUserLocation(String phone) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(phone).get();
      if (userDoc.exists) {
        return userDoc.data()?['location'] as Map<String, dynamic>?;
      } else {
        debugPrint('No user found for phone: $phone');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user location: $e');
      return null;
    }
  }

  // ฟังก์ชันการค้นหาผู้ใช้งานตามหมายเลขโทรศัพท์
  Future<List<Map<String, dynamic>>> searchUsersByPhone(String query) async {
    try {
      // ดึงข้อมูลที่เป็น userType = 'User' และหมายเลขโทรศัพท์ที่ตรงกับ query และไม่ใช่หมายเลขของผู้ใช้งานปัจจุบัน
      final querySnapshot = await _firestore
          .collection('Users')
          .where('userType', isEqualTo: 'User')
          .where('phoneNumber', isGreaterThanOrEqualTo: query)
          .where('phoneNumber', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      List<Map<String, dynamic>> users = [];
      for (var doc in querySnapshot.docs) {
        users.add(doc.data());
      }
      return users;
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  Future<void> logout() async {
    _userData = {};
    _profileImageUrl = null;
    notifyListeners();
  }

  void clearUserData() {
    _userData = {};
    notifyListeners();
  }
}
