// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// Widget buildOrderCard(
//     BuildContext context, String imagePath, String title, String status) {
//   return Card(
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(15),
//       side: const BorderSide(color: Color(0xFFD4D4D4), width: 1),
//     ),
//     color: Colors.white,
//     elevation: 0,
//     margin: const EdgeInsets.symmetric(vertical: 8),
//     child: Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: IntrinsicHeight(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: Image.asset(
//                 imagePath,
//                 width: 80,
//                 height: 120,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(width: 15),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               title,
//                               style: GoogleFonts.leagueSpartan(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             '1 item',
//                             style: TextStyle(
//                                 color: Colors.grey[600], fontSize: 14),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 5),
//                       Text(
//                         'Status: $status',
//                         style: GoogleFonts.leagueSpartan(
//                           fontSize: 14,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       TextButton(
//                         onPressed: () {},
//                         style: TextButton.styleFrom(
//                           padding: const EdgeInsets.only(right: 20),
//                           textStyle: GoogleFonts.leagueSpartan(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         child: const Text(
//                           'Detail',
//                           style: TextStyle(color: Color(0xFFE95322)),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 30,
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFE95322),
//                             textStyle: GoogleFonts.leagueSpartan(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             padding: const EdgeInsets.symmetric(horizontal: 10),
//                           ),
//                           child: const Text(
//                             'Track on Map',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }