import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'active_order_page.dart';
import 'completed_order_page.dart';
import 'profile_page.dart';

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({super.key});

  @override
  State<MyOrderPage> createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ActiveOrderPage(),
      const CompletedOrderPage(),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _login(BuildContext context, String phoneNumber, String password) async {
    try {
      // Query Firestore to get the user data by phoneNumber
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(phoneNumber)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;

        // Check if the password matches
        if (userData['password'] == password) {
          // Check the user type and navigate accordingly
          if (userData['userType'] == 'User') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MyOrderPage(), // User goes to MyOrderPage
              ),
            );
          } else if (userData['userType'] == 'Rider') {
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const HomeRiderPage(), // Rider goes to HomeRiderPage
            //   ),
            // );
          }
        } else {
          _showErrorDialog(context, 'Incorrect password');
        }
      } else {
        _showErrorDialog(context, 'User not found');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error: $e');
    }
  }

  // Function to show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'My Order',
            style: GoogleFonts.leagueSpartan(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF5CB58),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/home.svg',
              color: _selectedIndex == 0 ? const Color(0xFFE95322) : Colors.grey,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/orders.svg',
              color: _selectedIndex == 1 ? const Color(0xFFE95322) : Colors.grey,
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/profile.svg',
              color: _selectedIndex == 2 ? const Color(0xFFE95322) : Colors.grey,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFE95322),
        onTap: _onItemTapped,
      ),
    );
  }
}