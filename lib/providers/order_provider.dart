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
  final String? readyImageUrl; // เพิ่ม field นี้
  final String status;

  Order({
    required this.name,
    required this.amount,
    required this.detail,
    required this.recivePhone,
    required this.address,
    required this.senderPhone,
    this.imageUrl,
    this.readyImageUrl,
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
      'readyImageUrl': readyImageUrl,
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
      readyImageUrl: map['readyImageUrl'],
      status: map['status'],
    );
  }
}

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Order> _orders = [];
  final List<Order> _receivedOrders = [];

  List<Order> get orders => _orders;
  List<Order> get receivedOrders => _receivedOrders;

  Stream<List<Order>> getOrdersStream(String senderPhone) {
    return _firestore
        .collection('Orders')
        .where('senderPhone', isEqualTo: senderPhone)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Order.fromMap(doc.data())).toList();
    });
  }

  // เช็คเบอร์โทรผู้รับ
  Future<bool> _isValidRecivePhone(String recivePhone) async {
    try {
      final querySnapshot = await _firestore
          .collection('Users')
          .where('phoneNumber', isEqualTo: recivePhone)
          .where('userType', isEqualTo: 'User')
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking recivePhone: $e');
      return false;
    }
  }

  Future<void> addOrder(Order order) async {
    if (order.senderPhone == order.recivePhone) {
      throw Exception('Invalid order: You cannot send an order to yourself.');
    }

    final isValidRecivePhone = await _isValidRecivePhone(order.recivePhone);
    if (!isValidRecivePhone) {
      throw Exception('Invalid recivePhone: The phone number is not a User.');
    }

    try {
      final querySnapshot = await _firestore
          .collection('Orders')
          .where('senderPhone', isEqualTo: order.senderPhone)
          .get();

      final orderCount = querySnapshot.docs.length + 1;
      final documentId = 'ORD_${order.senderPhone}_$orderCount';

      await _firestore.collection('Orders').doc(documentId).set(order.toMap());
    } catch (e) {
      print('Error adding order: $e');
      throw e;
    }
  }

  // อัพเดทสถานะ Order
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection('Orders')
          .doc(orderId)
          .update({'status': newStatus});
    } catch (e) {
      print('Error updating order status: $e');
      throw e;
    }
  }

  Future<void> fetchReceivedOrders(String receiverPhone) async {
    try {
      final snapshot = await _firestore
          .collection('Orders')
          .where('recivePhone', isEqualTo: receiverPhone)
          .get();

      _receivedOrders.clear();
      for (final doc in snapshot.docs) {
        final order = Order.fromMap(doc.data());
        _receivedOrders.add(order);
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching received orders: $e');
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
