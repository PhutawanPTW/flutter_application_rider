import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _profileImageUrl;
  String? get profileImageUrl => _profileImageUrl;

  Map<String, dynamic> _userData = {};
  Map<String, dynamic> get userData => _userData;

  Map<String, dynamic> _currentUserData = {};
  Map<String, dynamic> get currentUserData => _currentUserData;

  // ดึงข้อมูล user อื่นๆ (สำหรับหน้า Detail)
  Future<Map<String, dynamic>?> fetchUserData(String phone) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(phone).get();
      if (userDoc.exists) {
        return userDoc.data();
      } else {
        log('No user found for phone: $phone');
        return null;
      }
    } catch (e) {
      log('Error fetching user data: $e');
      return null;
    }
  }

  // ดึงข้อมูล user ปัจจุบัน (สำหรับหน้า Profile)
  Future<Map<String, dynamic>?> fetchCurrentUserData(String phone) async {
    log('Fetching current user data for phone: $phone');
    try {
      final userDoc = await _firestore.collection('Users').doc(phone).get();
      log('Firestore query completed');
      if (userDoc.exists) {
        log('Document exists');
        _currentUserData = userDoc.data() ?? {};
        log('Current User Data: $_currentUserData');
        notifyListeners();
        return _currentUserData;
      } else {
        log('No user document found for phone: $phone');
        return null;
      }
    } catch (e) {
      log('Error fetching current user data: $e');
      log('Error stack trace: ${StackTrace.current}');
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
      log('Error fetching users: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchUserLocation(String phone) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(phone).get();
      if (userDoc.exists) {
        return userDoc.data()?['location'] as Map<String, dynamic>?;
      } else {
        log('No user found for phone: $phone');
        return null;
      }
    } catch (e) {
      log('Error fetching user location: $e');
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
      log('Error searching users: $e');
      return [];
    }
  }

  Future<void> logout() async {
    _currentUserData = {}; // เคลียร์ข้อมูล current user
    _profileImageUrl = null;
    notifyListeners();
  }

  void clearUserData() {
    _currentUserData = {}; // เคลียร์ข้อมูล current user
    notifyListeners();
  }
}
