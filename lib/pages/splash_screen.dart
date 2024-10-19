import 'package:flutter/material.dart';
import 'package:flutter_application_rider/pages/first.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay 3 seconds and navigate to FirstPage
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FirstPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFE95322), // สีของหน้าจอ Splash
        child: Center(
          child: Image.asset(
            'assets/images/logo.png', // โลโก้ในหน้า Splash
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
