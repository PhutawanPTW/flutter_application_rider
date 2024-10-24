import 'package:flutter/material.dart';
import 'package:flutter_application_rider/pages/map/RiderRun.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllOrdersPage extends StatefulWidget {
  const AllOrdersPage({Key? key}) : super(key: key);

  @override
  _AllOrdersPageState createState() => _AllOrdersPageState();
}

// ฟังก์ชันสำหรับดึงข้อมูลที่อยู่ของผู้ส่ง
Future<String?> _getSenderAddress(String senderPhone) async {
  try {
    final senderDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(senderPhone)
        .get();

    if (senderDoc.exists) {
      return senderDoc.data()?['address'] as String?;
    }
    return null;
  } catch (e) {
    print('Error fetching sender address: $e');
    return null;
  }
}

class _AllOrdersPageState extends State<AllOrdersPage> {
  // ฟังก์ชันสร้างการ์ดสำหรับแต่ละออร์เดอร์
  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> orderData) {
    // ดึงข้อมูลจาก orderData
    final String imageUrl = orderData['imageUrl'];
    final String name = orderData['name'];
    final int amount = orderData['amount'];
    final String senderPhone = orderData['senderPhone'];
    final String address = orderData['address'];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFD4D4D4), width: 1),
      ),
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$amount item${amount != 1 ? 's' : ''}',
                              style: const TextStyle(
                                color: Color(0xFF5C5352),
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<String?>(
                          future: _getSenderAddress(senderPhone),
                          builder: (context, snapshot) {
                            return Row(
                              children: [
                                Image.asset(
                                  'assets/images/restaurant.png',
                                  width: 21,
                                  height: 21,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    snapshot.data ?? 'Loading...',
                                    style: GoogleFonts.leagueSpartan(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: const Color(0xFF5C5352),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/home.png',
                              width: 22,
                              height: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                address,
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  color: const Color(0xFF5C5352),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            _showOrderDetails(context, orderData);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(20, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Detail',
                            style: TextStyle(color: Color(0xFFE95322)),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              _showTakeOrderConfirmation(context, orderData);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE95322),
                              textStyle: GoogleFonts.leagueSpartan(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            child: const Text(
                              'Take this Order',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันแสดงรายละเอียดออร์เดอร์
  void _showOrderDetails(BuildContext context, Map<String, dynamic> orderData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Order Details',
          style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${orderData['name']}'),
            Text('Amount: ${orderData['amount']}'),
            Text('Sender Address: ${orderData['senderAddress']}'),
            Text('Receiver Address: ${orderData['receiverAddress']}'),
            Text('Detail: ${orderData['detail']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันแสดงการยืนยันการรับออร์เดอร์
 void _showTakeOrderConfirmation(BuildContext context, Map<String, dynamic> orderData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Order',
          style: GoogleFonts.leagueSpartan(fontWeight: FontWeight.bold),
        ),
        content: Text('Do you want to take this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // อ่านข้อมูลล่าสุดของออเดอร์ก่อนอัพเดท
                final orderRef = FirebaseFirestore.instance
                    .collection('Orders')
                    .doc(orderData['id']);
                
                final orderSnapshot = await orderRef.get();
                
                // ตรวจสอบว่าสถานะยังคงเป็น "Wait for Rider" อยู่หรือไม่
                if (!orderSnapshot.exists || orderSnapshot.data()?['status'] != 'Wait for Rider') {
                  Navigator.pop(context);
                  // แสดง dialog แจ้งเตือนว่าออเดอร์ถูกรับไปแล้ว
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Order Unavailable'),
                      content: Text('This order has already been taken by another rider.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return;
                }

                // ใช้ Transaction เพื่อทำการอัพเดทแบบ atomic
                await FirebaseFirestore.instance.runTransaction((transaction) async {
                  // อ่านข้อมูลล่าสุดอีกครั้งใน transaction
                  final freshOrderSnapshot = await transaction.get(orderRef);
                  
                  if (!freshOrderSnapshot.exists || 
                      freshOrderSnapshot.data()?['status'] != 'Wait for Rider') {
                    throw Exception('Order already taken');
                  }

                  // อัพเดทสถานะและข้อมูล Rider
                  transaction.update(orderRef, {
                    'status': 'Wait for take it',
                    'riderId': 'CURRENT_RIDER_ID', // ต้องแทนที่ด้วย ID ของ Rider ปัจจุบัน
                    'acceptedAt': FieldValue.serverTimestamp(),
                  });
                });

                Navigator.pop(context); // ปิด Dialog

                // ไปยังหน้า RiderRun
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RiderRun(orderData: orderData),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                // แสดง error dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text(
                      e.toString() == 'Exception: Order already taken'
                          ? 'This order has already been taken by another rider.'
                          : 'Failed to update order status. Please try again.'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE95322),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .where('status', isEqualTo: 'Wait for Rider') // เพิ่มบรรทัดนี้
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No orders available',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // รวม document ID เข้าไปใน orderData
              final orderData = {
                ...snapshot.data!.docs[index].data() as Map<String, dynamic>,
                'id': snapshot.data!.docs[index].id,
              };
              return _buildOrderCard(context, orderData);
            },
          );
        },
      ),
    );
  }
}