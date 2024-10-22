import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _userData = {};
  Map<String, dynamic> get userData => _userData;

  // Fetch user data after login
  Future<void> fetchUserData(String phone) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(phone).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() ?? {};
        _userData = userData;
        notifyListeners();

        debugPrint('User full name: ${userData['fullName']}');
        debugPrint('User email: ${userData['email']}');
        debugPrint('User phone: ${userData['phoneNumber']}');
        debugPrint(
            'User location: Lat ${userData['location']['latitude']}, Long ${userData['location']['longitude']}');
      } else {
        debugPrint('No user found for phone: $phone');
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
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

  void clearUserData() {
    _userData = {};
    notifyListeners();
  }
}
