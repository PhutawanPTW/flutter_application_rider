import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_rider/providers/order_provider.dart';
import 'package:flutter_application_rider/providers/rider_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Upload extends StatefulWidget {
  const Upload({Key? key}) : super(key: key);

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool isReceived = true; // Default is Received mode

  Future<void> _uploadPhoto() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera); // เปิดกล้อง
    if (image != null) {
      setState(() {
        _imageFile = File(image.path); // เก็บไฟล์รูปถ่าย
      });
      debugPrint('Photo taken: ${image.path}');

      // เรียกเมธอดตามสถานะ isReceived
      if (isReceived) {
        _handleReceivedPhoto(_imageFile!);
      } else {
        _handleSenderPhoto(_imageFile!);
      }
    }
  }

  Future<void> _handleReceivedPhoto(File imageFile) async {
    // ฟังก์ชันสำหรับจัดการรูปภาพในโหมด Received
    print('Handling received photo: ${imageFile.path}');
    
      try {
        // Get the order provider from context
        final orderProvider =
            Provider.of<OrderProvider>(context, listen: false);
        final riderOrderProvider =
            Provider.of<RiderOrderProvider>(context, listen: false);

        // Get current order ID
        final currentOrderId = riderOrderProvider.currentOrder?['id'];
        if (currentOrderId == null) {
          throw Exception('No current order found');
        }

        // Upload image to Firebase Storage and get URL
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('order_images')
            .child('$currentOrderId-received.jpg');

        await storageRef.putFile(imageFile);
        final imageUrl = await storageRef.getDownloadURL();

        // Update order status and image URL
        await orderProvider.updateOrder(
          currentOrderId,
          status: 'Driving',
          readyImageUrl: imageUrl,
        );

        print('Photo uploaded and order status updated: ${imageFile.path}');

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo uploaded successfully')),
          );
        }
      } catch (e) {
        print('Error handling received photo: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading photo: $e')),
          );
        }
      
    }
    // คุณสามารถทำการประมวลผลหรืออัพโหลดที่นี่
  }

  void _handleSenderPhoto(File imageFile) {
    // ฟังก์ชันสำหรับจัดการรูปภาพในโหมด Sender
    print('Handling sender photo: ${imageFile.path}');
    final riderOrderProvider = context.read<RiderOrderProvider>();
    riderOrderProvider.clearCurrentOrder();
    // คุณสามารถทำการประมวลผลหรืออัพโหลดที่นี่
  }

  void _confirmPhoto() {
    if (_imageFile != null) {
      // แสดงข้อความยืนยันการเลือกรูปภาพ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo selected: ${_imageFile!.path}')),
      );

      // ส่งเลข 909 ไปยังหน้า RiderRun
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context, 909); // ส่งเลข 909 กลับ
      });
    } else {
      // แสดงข้อความเตือนถ้าไม่มีภาพ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture an image first!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Upload Image",
          style: TextStyle(
            color: Colors.white, // ปรับสีตัวหนังสือถ้าต้องการ
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color(0xFFFFD700), // เปลี่ยนสีพื้นหลังเป็นสีเหลือง
      ),
      body: Container(
        color: const Color(0xFFFFDECF), // เปลี่ยนสีพื้นหลังทั้งหน้าเป็น FFDECF
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Switch for Received and Sender modes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isReceived ? const Color(0xFFE95322) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        border: Border.all(color: const Color(0xFFE95322)),
                      ),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            isReceived = true;
                          });
                        },
                        child: Text(
                          'Received',
                          style: TextStyle(
                            color: isReceived ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: !isReceived
                            ? const Color(0xFFE95322)
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        border: Border.all(color: const Color(0xFFE95322)),
                      ),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            isReceived = false;
                          });
                        },
                        child: Text(
                          'Sender',
                          style: TextStyle(
                            color: !isReceived ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20), // Spacing below the switch

            // Upload Photo Button
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE95322),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: _uploadPhoto, // เรียกฟังก์ชันเมื่อกดปุ่ม
                    child: Text(
                      'Camera',
                      style: GoogleFonts.leagueSpartan(
                        color: Colors.white,
                        fontSize: 16, // Adjust font size for better visibility
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20), // Spacing below the button

            // Image Preview Area
            Container(
              width: 200, // Adjust width as needed
              height: 200, // Adjust height as needed
              decoration: BoxDecoration(
                color: Colors.grey[200], // Light grey background for the area
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE95322), // Border color
                  width: 2, // Border width
                ),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: const Color(0xFFE95322),
                            size: 40, // Size of the icon
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Take a photo',
                            style: GoogleFonts.leagueSpartan(
                              color: const Color(0xFFE95322),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // Done Button
            SizedBox(
              width: 120, // Set a width for the button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE95322),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: _confirmPhoto, // ยืนยันการเลือกรูปภาพ
                child: Text(
                  'Done',
                  style: GoogleFonts.leagueSpartan(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
