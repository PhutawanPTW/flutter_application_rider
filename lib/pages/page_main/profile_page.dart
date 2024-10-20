import 'package:flutter/material.dart';
import 'package:flutter_application_rider/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.leagueSpartan(
            fontSize: 18,
            color: const Color(0xFF5C5352),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E9B5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: GoogleFonts.leagueSpartan(
              fontSize: 16,
              color: const Color(0xFF5C5352),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.userData;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF3E9B5),
                        width: 10.0,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/images/logo.png'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildInfoField(
                  'Full Name', userData['fullName'] ?? 'Not provided'),
              _buildInfoField('Email', userData['email'] ?? 'Not provided'),
              _buildInfoField(
                  'Phone Number', userData['phoneNumber'] ?? 'Not provided'),
              _buildInfoField('Address', userData['address'] ?? 'Not provided'),
            ],
          ),
        ),
      ),
    );
  }
}
