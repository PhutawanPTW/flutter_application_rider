import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiderOrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> takeOrder(String orderId, String riderId) async {
    try {
      await _firestore.collection('Orders').doc(orderId).update({
        'status': 'Rider Accepted',
        'riderId': riderId,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
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