import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiderOrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _currentOrder;
  
  Map<String, dynamic>? get currentOrder => _currentOrder;

  // ปรับปรุงรายการสถานะที่ถือว่าเป็น pending orders
  static const List<String> _pendingStatuses = [
    'Wait for take it',
    'Driving',
    'Complete'
  ];

  // ตรวจสอบว่า Rider มี Order ที่กำลังดำเนินการอยู่หรือไม่
  Future<Map<String, dynamic>?> clearCurrentOrder() async {
    _currentOrder = null;
    notifyListeners();
    return null;
  }

  Future<Map<String, dynamic>?> checkPendingOrder(String riderId) async {
    try {
      final QuerySnapshot orderSnapshot = await _firestore
          .collection('Orders')
          .where('riderId', isEqualTo: riderId)
          .where('status', whereIn: _pendingStatuses)
          .orderBy('acceptedAt', descending: true)  // เพิ่มการเรียงลำดับตามเวลาที่รับ Order
          .limit(1)
          .get();

      if (orderSnapshot.docs.isNotEmpty) {
        final orderData = {
          ...orderSnapshot.docs.first.data() as Map<String, dynamic>,
          'id': orderSnapshot.docs.first.id,
        };
        _currentOrder = orderData;
        notifyListeners();
        return orderData;
      }
      return await clearCurrentOrder();
    } catch (e) {
      print('Error checking pending order: $e');
      return await clearCurrentOrder();
    }
  }

  // เพิ่มฟังก์ชันสำหรับติดตาม Order ปัจจุบันแบบ real-time
  Stream<DocumentSnapshot>? watchCurrentOrder(String orderId) {
    if (orderId.isEmpty) return null;
    return _firestore.collection('Orders').doc(orderId).snapshots();
  }

  Future<void> takeOrder(String orderId, String riderId) async {
    try {
      await _firestore.collection('Orders').doc(orderId).update({
        'status': 'Wait for take it',
        'riderId': riderId,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      
      // อัพเดต currentOrder ทันทีหลังจากรับ Order
      final orderDoc = await _firestore.collection('Orders').doc(orderId).get();
      if (orderDoc.exists) {
        _currentOrder = {
          ...orderDoc.data()!,
          'id': orderId,
        };
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error taking order: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getAvailableOrders() {
    return _firestore
        .collection('Orders')
        .where('status', isEqualTo: 'Wait for Rider')
        .snapshots();
  }
}