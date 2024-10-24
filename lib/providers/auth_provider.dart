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
  String? profileImageUrl; // เพิ่มตัวแปรสำหรับเก็บ URL ของรูปโปรไฟล์

  // ฟังก์ชันเพื่อเก็บรายละเอียดผู้ใช้
  void setUserDetails({
    required String email,
    required String phoneNumber,
    required String password,
    required String fullName,
    String? address,
    String? registrationNumber,
    LatLng? selectedPosition,
    String? profileImageUrl, // เพิ่ม profileImageUrl ในการรับ URL รูปโปรไฟล์
  }) {
    this.email = email;
    this.phoneNumber = phoneNumber;
    this.password = password;
    this.fullName = fullName;
    this.address = address;
    this.registrationNumber = registrationNumber;
    this.selectedPosition = selectedPosition;
    this.profileImageUrl = profileImageUrl; // เก็บ URL ของรูปโปรไฟล์
    notifyListeners();
  }

  // ตรวจสอบว่าหมายเลขโทรศัพท์นี้เป็นเอกลักษณ์หรือไม่
  Future<bool> isPhoneNumberUnique(String phoneNumber) async {
    final userQuery = await _firestore
        .collection('Users')
        .doc(phoneNumber)
        .get(); // ตรวจสอบว่ามีผู้ใช้ที่มีหมายเลขโทรศัพท์นี้หรือไม่

    return !userQuery.exists;
  }

  // ฟังก์ชันการล็อกอิน
  Future<void> loginUser(String phoneNumber, String password) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(phoneNumber).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;

        if (userData['password'] == password) {
          isLoggedIn = true;
          currentUserPhoneNumber = phoneNumber;
          currentUserType = userData['userType']; // เก็บข้อมูลประเภทผู้ใช้
          notifyListeners();
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
  

  // ฟังก์ชันการสมัครสมาชิกผู้ใช้
  Future<void> signUpUser(String userType) async {
    try {
      bool isUnique = await isPhoneNumberUnique(phoneNumber!);
      if (!isUnique) {
        throw Exception("Phone number already exists for another user.");
      }

      Map<String, dynamic> userData = {
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password, // ควรเข้ารหัสก่อนบันทึกในโปรดักชัน
        'fullName': fullName,
        'userType': userType,
        'createdAt': Timestamp.now(),
        'profileImageUrl': profileImageUrl, // บันทึก URL ของรูปโปรไฟล์
      };

      // ตรวจสอบถ้าเป็น User และมีที่อยู่
      if (userType == "User") {
        userData['address'] = address; // บันทึกที่อยู่
        userData['location'] = selectedPosition != null
            ? {
                'latitude': selectedPosition!.latitude,
                'longitude': selectedPosition!.longitude,
              }
            : null;
      } else if (userType == "Rider" && registrationNumber != null) {
        userData['registrationNumber'] = registrationNumber;
      } else if (userType == "Rider" && registrationNumber != null) {
        userData['registrationNumber'] = registrationNumber;
      }

      await _firestore.collection('Users').doc(phoneNumber).set(userData);
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // ฟังก์ชันล็อกเอาท์
  void logoutUser() {
    isLoggedIn = false;
    currentUserPhoneNumber = null;
    notifyListeners();
  }
}
