import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // เพิ่ม import นี้
import 'package:flutter_application_rider/providers/order_provider.dart';
import 'package:flutter_application_rider/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddOrderPage extends StatefulWidget {
  const AddOrderPage({super.key});

  @override
  _AddOrderPageState createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _phoneReceiveController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  File? _selectedImage;
  File? _readyImage;
  bool _isLoading = false;
  bool _isAmountValid = true;
  bool _isPhoneReceiveValid = true;
  String? _phoneReceiveErrorMessage;
  List<Map<String, dynamic>> _users = [];
  String? _selectedUserPhone;

  @override
  void initState() {
    super.initState();
    _phoneReceiveController.addListener(() {
      if (_selectedUserPhone == null ||
          _phoneReceiveController.text != _selectedUserPhone) {
        _searchPhoneNumber();
      } else {
        setState(() {
          _users = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _detailController.dispose();
    _phoneReceiveController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({bool isReadyImage = false}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isReadyImage) {
          _readyImage = File(pickedFile.path);
        } else {
          _selectedImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File? image, String folderName) async {
    if (image == null) return null;

    try {
      String fileName =
          '$folderName/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = firebaseStorageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _searchPhoneNumber() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final query = _phoneReceiveController.text;
    if (query.isNotEmpty) {
      _users = await userProvider.searchUsersByPhone(query);
      setState(() {});
    } else {
      setState(() {
        _users = [];
      });
    }
  }

  Widget _buildPhoneList() {
    return _users.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: const Icon(
                    HugeIcons.strokeRoundedSmartPhone04,
                    color: Color(0xFFE95322),
                    size: 24,
                  ),
                  title: Text(
                    user['phoneNumber'],
                    style: GoogleFonts.leagueSpartan(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    user['fullName'] ?? 'Unknown Name',
                    style: GoogleFonts.leagueSpartan(fontSize: 14),
                  ),
                  trailing: const Icon(
                    HugeIcons.strokeRoundedArrowDown01,
                    color: Colors.grey,
                    size: 24,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedUserPhone = user['phoneNumber'];
                      _phoneReceiveController.text = _selectedUserPhone!;
                      _users = [];
                      _closeKeyboard();
                    });
                  },
                ),
              );
            },
          )
        : Container();
  }

  void _closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Center(
              child: Text(
                'Add Order',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          backgroundColor: const Color(0xFFF5CB58),
          elevation: 0,
        ),
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isLoading,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(isReadyImage: false),
                      child: _selectedImage == null
                          ? Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                HugeIcons.strokeRoundedImageAdd02,
                                size: 40,
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
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    _buildPhoneList(),
                    _buildMultilineTextField(_addressController, 'Address'),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _pickImage(isReadyImage: true),
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _readyImage == null
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      HugeIcons.strokeRoundedImageAdd01,
                                      size: 40,
                                      color: Color(0xFFE95322),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Upload Image (Food Ready)',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _readyImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 150,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        _closeKeyboard();

                        final amountText = _amountController.text;
                        final amount = int.tryParse(amountText);
                        final phoneReceive = _phoneReceiveController.text;
                        final currentPhone =
                            userProvider.userData['phoneNumber'];

                        if (amount == null || amount <= 0 || amount > 99999) {
                          setState(() {
                            _isAmountValid = false;
                          });
                          return;
                        }

                        setState(() {
                          _isAmountValid = true;
                          _isLoading = true;
                        });

                        String? imageUrl = await _uploadImageToFirebase(
                            _selectedImage, 'AddOrder');
                        String? readyImageUrl = await _uploadImageToFirebase(
                            _readyImage, 'ReadyImages');

                        if (imageUrl == null) {
                          setState(() {
                            _isLoading = false;
                            _isPhoneReceiveValid = false;
                            _phoneReceiveErrorMessage =
                                'Failed to upload product image';
                          });
                          return;
                        }

                        final order = Order(
                          name: _nameController.text,
                          amount: amount,
                          detail: _detailController.text,
                          recivePhone: phoneReceive,
                          address: _addressController.text,
                          senderPhone: currentPhone,
                          imageUrl: imageUrl,
                          readyImageUrl: readyImageUrl,
                          status: 'Wait for Rider',
                        );

                        try {
                          await orderProvider.addOrder(order);
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context).pop();
                        } catch (e) {
                          setState(() {
                            _isLoading = false;
                            _isPhoneReceiveValid = false;
                            _phoneReceiveErrorMessage = e.toString();
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, bool isValid = true}) {
    IconData fieldIcon;

    if (label == 'Name') {
      fieldIcon = HugeIcons.strokeRoundedUserAccount;
    } else if (label == 'Amount') {
      fieldIcon = HugeIcons.strokeRoundedAdd01;
    } else if (label == 'Phone Receive') {
      fieldIcon = HugeIcons.strokeRoundedSmartPhone01;
    } else {
      fieldIcon = HugeIcons.strokeRoundedEdit01;
    }

    // สำหรับฟิลด์ Amount
    if (label == 'Amount') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          maxLength: 5,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: label,
            counterText: '',
            labelStyle: GoogleFonts.leagueSpartan(
              fontSize: 14,
              color: const Color(0xFFE95322),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFE95322), width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: const Color(0xFFE95322).withOpacity(0.5), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFFE95322), width: 2.0),
            ),
            errorText: isValid ? null : 'Please enter a valid amount (1-99999)',
            errorStyle: GoogleFonts.leagueSpartan(
              fontSize: 12,
              color: Colors.red,
            ),
            prefixIcon: Icon(
              fieldIcon,
              color: const Color(0xFFE95322),
            ),
          ),
        ),
      );
    }

    // สำหรับฟิลด์อื่นๆ
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.leagueSpartan(
            fontSize: 14,
            color: const Color(0xFFE95322),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE95322), width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: const Color(0xFFE95322).withOpacity(0.5), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE95322), width: 2.0),
          ),
          errorText: isValid ? null : 'Invalid input',
          errorStyle: GoogleFonts.leagueSpartan(
            fontSize: 12,
            color: Colors.red,
          ),
          prefixIcon: Icon(
            fieldIcon,
            color: const Color(0xFFE95322),
          ),
        ),
      ),
    );
  }

  Widget _buildMultilineTextField(
      TextEditingController controller, String label) {
    IconData fieldIcon;

    if (label == 'Address') {
      fieldIcon = HugeIcons.strokeRoundedMapsCircle01;
    } else {
      fieldIcon = HugeIcons.strokeRoundedNote;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.leagueSpartan(
            fontSize: 14,
            color: const Color(0xFFE95322),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE95322), width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: const Color(0xFFE95322).withOpacity(0.5), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE95322), width: 2.0),
          ),
          prefixIcon: Icon(
            fieldIcon,
            color: const Color(0xFFE95322),
          ),
        ),
      ),
    );
  }
}
