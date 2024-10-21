import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Order {
  final String name;
  final int amount;
  final String detail;
  final String recivePhone;
  final String address;
  final String senderPhone;
  final String? imageUrl;
  final String status;
  Order({
    required this.name,
    required this.amount,
    required this.detail,
    required this.recivePhone,
    required this.address,
    required this.senderPhone,
    this.imageUrl,
    this.status = 'Wait for Rider',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'detail': detail,
      'recivePhone': recivePhone,
      'address': address,
      'senderPhone': senderPhone,
      'imageUrl': imageUrl,
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      name: map['name'],
      amount: map['amount'],
      detail: map['detail'],
      recivePhone: map['recivePhone'],
      address: map['address'],
      senderPhone: map['senderPhone'],
      imageUrl: map['imageUrl'],
      status: map['status'],
    );
  }
}

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  // เพิ่มฟังก์ชันเพื่อเช็คว่าเบอร์โทรผู้รับมีใน Firestore และเป็น User หรือไม่
  Future<bool> _isValidRecivePhone(String recivePhone) async {
    try {
      final querySnapshot = await _firestore
          .collection('Users')
          .where('phoneNumber', isEqualTo: recivePhone)
          .where('userType', isEqualTo: 'User')
          .get();

      // ถ้าพบเบอร์โทรและเป็นประเภท User จะคืนค่า true
      if (querySnapshot.docs.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking recivePhone: $e');
      return false;
    }
  }

  Future<void> addOrder(Order order) async {
    // ตรวจสอบว่าเบอร์โทรผู้รับไม่ใช่เบอร์เดียวกันกับผู้ส่ง
    if (order.senderPhone == order.recivePhone) {
      // ถ้าเบอร์ผู้ส่งและผู้รับเป็นเบอร์เดียวกัน ให้แสดงข้อผิดพลาด
      throw Exception('Invalid order: You cannot send an order to yourself.');
    }

    // เช็คว่าเบอร์โทรผู้รับมีอยู่ในฐานข้อมูลและเป็นประเภท User หรือไม่
    final isValidRecivePhone = await _isValidRecivePhone(order.recivePhone);

    if (!isValidRecivePhone) {
      // ถ้าไม่พบเบอร์หรือเบอร์ไม่ใช่ User ให้แสดงข้อผิดพลาด
      throw Exception('Invalid recivePhone: The phone number is not a User.');
    }

    try {
      // ดึงข้อมูลผู้ส่งมาเพื่อสร้าง documentId สำหรับคำสั่งซื้อ
      final querySnapshot = await _firestore
          .collection('Orders')
          .where('senderPhone', isEqualTo: order.senderPhone)
          .get();

      final orderCount = querySnapshot.docs.length + 1;
      final documentId =
          'ORD_${order.senderPhone}_$orderCount'; // ใช้ senderPhone แทน

      await _firestore.collection('Orders').doc(documentId).set(order.toMap());

      _orders.add(order);
      notifyListeners();
    } catch (e) {
      print('Error adding order: $e');
    }
  }

  Future<void> fetchOrdersByCreator(String senderPhone) async {
    try {
      final snapshot = await _firestore
          .collection('Orders')
          .where('senderPhone', isEqualTo: senderPhone) // ใช้ senderPhone แทน
          .get();

      _orders.clear();
      for (final doc in snapshot.docs) {
        final order = Order.fromMap(doc.data());
        _orders.add(order);
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }
}
