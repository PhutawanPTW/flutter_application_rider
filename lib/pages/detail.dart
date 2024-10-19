// import 'package:flutter/material.dart';
// import 'package:easy_stepper/easy_stepper.dart'; // Import easy_stepper

// class DetailPage extends StatelessWidget {
//   final Map<String, dynamic> order;

//   const DetailPage({required this.order, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // ตรวจสอบค่า currentStep ถ้า null ให้ตั้งเป็น 0
//     int currentStep = order['currentStep'] ?? 0;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${order['name']} Details'),
//         backgroundColor: Colors.orange,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Product: ${order['name']}',
//                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Text('Status: ${order['status']}', style: const TextStyle(fontSize: 18)),
//               const SizedBox(height: 8),
//               Text('Price: ${order['price']}', style: const TextStyle(fontSize: 18)),
//               const SizedBox(height: 8),
//               Text('Items: ${order['items']}', style: const TextStyle(fontSize: 18)),
//               const SizedBox(height: 8),
//               Text('Sender: ${order['sender']}', style: const TextStyle(fontSize: 18)),
//               const SizedBox(height: 8),
//               Text('Receiver: ${order['receiver']}', style: const TextStyle(fontSize: 18)),
//               const SizedBox(height: 16),
//               Text(
//                 'Description:',
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Text(order['description'], style: const TextStyle(fontSize: 16)),
//               const SizedBox(height: 20),
//               Image.network(order['image'], height: 200, fit: BoxFit.cover),
//               const SizedBox(height: 30),
//               // ใช้ EasyStepper เพื่อแสดงสถานะการส่งสินค้า
//               Text(
//                 'Delivery Progress',
//                 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               EasyStepper(
//                 activeStep: currentStep, // ขั้นตอนปัจจุบัน
//                 stepShape: StepShape.rRectangle,
//                 stepBorderRadius: 15,
//                 borderThickness: 2,
//                 padding: const EdgeInsets.symmetric(horizontal: 10), // แก้ให้ใช้ EdgeInsets
//                 steps: const [
//                   EasyStep(
//                     icon: Icon(Icons.local_laundry_service),
//                     title: 'Ordered',
//                   ),
//                   EasyStep(
//                     icon: Icon(Icons.kitchen),
//                     title: 'Preparing',
//                   ),
//                   EasyStep(
//                     icon: Icon(Icons.motorcycle),
//                     title: 'Out for Delivery',
//                   ),
//                   EasyStep(
//                     icon: Icon(Icons.home),
//                     title: 'Delivered',
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
