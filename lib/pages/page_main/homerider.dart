// import 'package:flutter/material.dart';
// import 'package:flutter_application_rider/pages/page_main/order.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // To load SVG icons

// class HomeRiderPage extends StatefulWidget {
//   const HomeRiderPage({super.key});


//   @override
//   State<HomeRiderPage> createState() => _HomeRiderPageState();
// }

// class _HomeRiderPageState extends State<HomeRiderPage> {
//   int selectedIndex = 0;
//   late Widget currentPage;

//   @override
//   void initState() {
//     super.initState();
//     currentPage = const ActiveOrdersRiderPage(); // Default page
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       selectedIndex = index;
//       if (selectedIndex == 0) {
//         currentPage = const ActiveOrdersRiderPage();
//       } else if (selectedIndex == 1) {
//         currentPage = const CompletedOrdersRiderPage();
//       } else if (selectedIndex == 2) {
//         currentPage = const ProfilePage(); // Assuming ProfilePage is the same
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Center(
//           child: Text(
//             'All Orders',
//             style: GoogleFonts.leagueSpartan(
//               fontSize: 26,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         backgroundColor: const Color(0xFFF5CB58),
//       ),
//       body: currentPage,
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: const Color(0xFFE95322),
//         items: [
//           BottomNavigationBarItem(
//             icon: SvgPicture.asset(
//               'assets/svg/home.svg',
//               color: Colors.white,
//             ),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: SvgPicture.asset(
//               'assets/svg/orders.svg',
//               color: Colors.white,
//             ),
//             label: 'Orders',
//           ),
//           BottomNavigationBarItem(
//             icon: SvgPicture.asset(
//               'assets/svg/profile.svg',
//               color: Colors.white,
//             ),
//             label: 'Profile',
//           ),
//         ],
//         currentIndex: selectedIndex,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.white54,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

// // Active Orders page for Riders
// class ActiveOrdersRiderPage extends StatefulWidget {
//   const ActiveOrdersRiderPage({super.key});

//   @override
//   _ActiveOrdersRiderPageState createState() => _ActiveOrdersRiderPageState();
// }

// class _ActiveOrdersRiderPageState extends State<ActiveOrdersRiderPage> {
//   // Track if we're in "Deliver" or "Completed" mode

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               children: [
//                 buildOrderCardRider(
//                     context,
//                     'assets/images/strawberry_shake.jpg',
//                     'Strawberry Shake',
//                     'Mahasarakham University',
//                     'Sinsup City Home Mahasarakham University',
//                     true),
//                 buildOrderCardRider(
//                     context,
//                     'assets/images/hong_thong.jpg',
//                     'Hong Thong',
//                     'Mahasarakham University',
//                     'Sinsup City Home Mahasarakham University',
//                     true),
//                 buildOrderCardRider(
//                     context,
//                     'assets/images/white_whisky.jpg',
//                     'White Whisky',
//                     'Mahasarakham University',
//                     'Sinsup City Home Mahasarakham University',
//                     true),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }

// // Completed Orders page for Riders
// class CompletedOrdersRiderPage extends StatefulWidget {
//   const CompletedOrdersRiderPage({super.key});

//   @override
//   _CompletedOrdersRiderPageState createState() =>
//       _CompletedOrdersRiderPageState();
// }

// class _CompletedOrdersRiderPageState extends State<CompletedOrdersRiderPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Container(),
//     );
//   }
// }

// Widget buildOrderCardRider(BuildContext context, String imagePath, String title,
//     String start, String finish,
//     [bool? isReceived]) {
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
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.location_on, // Location icon
//                             color: Colors.grey,
//                           ),
//                           const SizedBox(
//                               width: 5), // Space between icon and text
//                           Flexible(
//                             // Allows the text to wrap if it exceeds the available space
//                             child: Text(
//                               'Start: $start',
//                               style: GoogleFonts.leagueSpartan(
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                               ),
//                               overflow: TextOverflow
//                                   .ellipsis, // Optional: adds ellipsis if text is too long
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.location_on, // Location icon
//                             color: Colors.grey,
//                           ),
//                           const SizedBox(
//                               width: 5), // Space between icon and text
//                           Flexible(
//                             // Allows the text to wrap if it exceeds the available space
//                             child: Text(
//                               'Finish: $finish',
//                               style: GoogleFonts.leagueSpartan(
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                               ),
//                               overflow: TextOverflow
//                                   .ellipsis, // Optional: adds ellipsis if text is too long
//                             ),
//                           ),
//                         ],
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
//                         child: Text(
//                           'Detail',
//                           style: TextStyle(
//                             color: isReceived == true
//                                 ? Colors.green
//                                 : const Color(0xFFE95322),
//                           ),
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
//                             'Take this Order',
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
