import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_rider/providers/order_provider.dart';
import 'package:flutter_application_rider/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/services.dart'; // ใช้สำหรับการจัดการแป้นพิมพ์

// AddOrderDialog
class AddOrderDialog extends StatefulWidget {
  const AddOrderDialog({super.key});

  @override
  _AddOrderDialogState createState() => _AddOrderDialogState();
}

class _AddOrderDialogState extends State<AddOrderDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _phoneReceiveController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isAmountValid = true;
  bool _isPhoneReceiveValid = true;
  String? _phoneReceiveErrorMessage; // เก็บข้อความข้อผิดพลาดเกี่ยวกับเบอร์โทร

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _detailController.dispose();
    _phoneReceiveController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_selectedImage == null) return null;

    try {
      String fileName = 'AddOrder/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = firebaseStorageRef.putFile(_selectedImage!);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      debugPrint('Image uploaded successfully. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // ปิดแป้นพิมพ์
  void _closeKeyboard() {
    FocusScope.of(context).unfocus(); // ปิดแป้นพิมพ์โดยการยกเลิก focus
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _isLoading, // ล็อกหน้าต่างเมื่อมีการโหลด
          child: AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.add_box_rounded, color: Color(0xFFE95322)),
                const SizedBox(width: 8),
                Text(
                  'Add New Order',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _selectedImage == null
                        ? Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey,
                            ),
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_nameController, 'Name'),
                  _buildTextField(_amountController, 'Amount',
                      keyboardType: TextInputType.number,
                      isValid: _isAmountValid),
                  if (!_isAmountValid)
                    const Padding(
                      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: Text(
                        'Please enter a valid amount greater than 0',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  _buildMultilineTextField(_detailController, 'Detail'),
                  _buildTextField(
                    _phoneReceiveController,
                    'Phone Receive',
                    keyboardType: TextInputType.phone,
                  ),
                  if (!_isPhoneReceiveValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: Text(
                        _phoneReceiveErrorMessage ?? 'Invalid phone number.',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  _buildMultilineTextField(_addressController, 'Address'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      _closeKeyboard(); // ปิดแป้นพิมพ์เมื่อกด Create Order

                      final amountText = _amountController.text;
                      final amount = int.tryParse(amountText);
                      final phoneReceive = _phoneReceiveController.text;
                      final currentPhone = userProvider.userData['phoneNumber'];

                      // Validate the amount field
                      if (amount == null || amount <= 0) {
                        setState(() {
                          _isAmountValid = false;
                        });
                        return;
                      }

                      setState(() {
                        _isAmountValid = true;
                        _isLoading = true;
                      });

                      String? imageUrl = await _uploadImageToFirebase();

                      // สร้างออเดอร์
                      final order = Order(
                        name: _nameController.text,
                        amount: amount,
                        detail: _detailController.text,
                        recivePhone: phoneReceive, // เบอร์ผู้รับ
                        address: _addressController.text,
                        senderPhone: currentPhone, // เบอร์ผู้ส่ง
                        imageUrl: imageUrl,
                        status: 'Wait for Rider',
                      );

                      try {
                        // ลองเพิ่มคำสั่งซื้อ หากไม่พบหรือไม่ใช่ User ให้มีข้อผิดพลาด
                        await orderProvider.addOrder(order);
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.of(context)
                            .pop(); // ปิด Dialog เมื่อเพิ่มสำเร็จ
                      } catch (e) {
                        setState(() {
                          _isLoading = false;
                          _isPhoneReceiveValid = false;
                          _phoneReceiveErrorMessage =
                              e.toString(); // แสดงข้อความข้อผิดพลาด
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE95322),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Create Order',
                      style: GoogleFonts.leagueSpartan(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: Colors.deepOrangeAccent,
              size: 50,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, bool isValid = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildMultilineTextField(
      TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
