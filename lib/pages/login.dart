import 'package:flutter/material.dart';
import 'package:flutter_application_rider/pages/map/RiderRun.dart';
import 'package:flutter_application_rider/pages/order/order.dart';
import 'package:flutter_application_rider/pages/rider/order_rider.dart';
import 'package:flutter_application_rider/pages/signup.dart';
import 'package:flutter_application_rider/providers/rider_provider.dart';
import 'package:flutter_application_rider/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:flutter_application_rider/providers/auth_provider.dart'; // Import AuthProvider

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Function to log in and check user type
  Future<void> _login(BuildContext context, String phoneNumber, String password) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final riderOrderProvider = Provider.of<RiderOrderProvider>(context, listen: false);

  try {
    await authProvider.loginUser(phoneNumber, password);
    await userProvider.fetchCurrentUserData(phoneNumber);

    if (authProvider.currentUserType == 'Rider') {
      // ตรวจสอบ Order ที่ค้างอยู่
      final pendingOrder = await riderOrderProvider.checkPendingOrder(phoneNumber);
      
      if (pendingOrder != null) {
        _showSuccessDialog(context);
        // นำทางไปยังหน้า RiderRun ทันทีถ้ามี Order ค้างอยู่
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RiderRun(orderData: pendingOrder),
          ),
        );
      } else {
        _showSuccessDialog(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyOrderRiderPage(),
          ),
        );
      }
    } else {
      _showSuccessDialog(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyOrderPage(),
        ),
      );
    }
  } catch (e) {
    _showErrorDialog(context, e.toString());
  }
}

  // Success Dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.greenAccent,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  'Success!',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'You have successfully logged in.',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Error Dialog
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 80,
                ),
                const SizedBox(height: 20),
                Text(
                  'Error',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  errorMessage,
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign In',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.90,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome To FoodDanpu!',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5C5352),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to explore delicious meals and join us in delivering joy to customers!',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF252525),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Phone Number',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5C5352),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneNumberController, // Bind controller
                        textAlign: TextAlign.justify,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF3E9B5),
                          hintText: 'Enter your phone number',
                          hintStyle: GoogleFonts.leagueSpartan(
                            color: const Color(0xFF5C5352).withOpacity(0.6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Password',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5C5352),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController, // Bind controller
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: GoogleFonts.leagueSpartan(
                            color: const Color(0xFF5C5352).withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3E9B5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.65,
                          child: ElevatedButton(
                            onPressed: () {
                              // Call the login function with the input values
                              _login(context, phoneNumberController.text,
                                  passwordController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFFE95322),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              'Log In',
                              style: GoogleFonts.leagueSpartan(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: GoogleFonts.leagueSpartan(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFF5C5352),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to Sign Up page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.leagueSpartan(
                                fontSize: 16,
                                color: const Color(0xFFE95322),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
