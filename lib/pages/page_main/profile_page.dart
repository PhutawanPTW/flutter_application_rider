import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // เพิ่ม Google Fonts

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  // ฟังก์ชันสร้าง TextFormField ที่กำหนดรูปแบบไว้แล้ว
  Widget _buildTextField(String label, String hint,
      {bool isPassword = false,
      TextEditingController? controller,
      bool isLicensePlate = false}) {
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
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3E9B5),
            hintText: hint,
            hintStyle: GoogleFonts.leagueSpartan(
              color: const Color(0xFF5C5352).withOpacity(0.6),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorStyle: GoogleFonts.leagueSpartan(
              color: Colors.red,
            ),
          ),
          keyboardType:
              isLicensePlate ? TextInputType.text : TextInputType.emailAddress,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // รูปโปรไฟล์และปุ่มแก้ไข
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
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD61355),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ช่องกรอกข้อมูลแบบกำหนดเอง
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField('Full Name', 'Enter your full name'),
                  const SizedBox(height: 10),
                  _buildTextField('Email', 'Enter your email'),
                  const SizedBox(height: 10),
                  _buildTextField('Phone Number', 'Enter your phone number'),
                  const SizedBox(height: 10),
                  _buildTextField('Address', 'Enter your address'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
