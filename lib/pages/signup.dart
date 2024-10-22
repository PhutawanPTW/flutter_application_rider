import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_rider/pages/login.dart';
import 'package:flutter_application_rider/pages/map/map_dialog.dart';
import 'package:flutter_application_rider/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String selectedRole = 'User';
  String? locationMessage = '';
  LatLng? selectedPosition;
  File? _selectedImage; // For storing the selected image
  String? _downloadUrl; // To store the download URL of the uploaded image

  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController registrationController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    addressController.dispose();
    registrationController.dispose();
    super.dispose();
  }

  // Function to select an image from the gallery
  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery); // Open gallery

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // Store the selected image
      });
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_selectedImage == null) return;

    try {
      String timeStamp = DateTime.now()
          .millisecondsSinceEpoch
          .toString(); // Use current timestamp
      String fileName =
          'users profile/${timeStamp}.jpg'; // Save in 'users profile' folder with timestamp
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = firebaseStorageRef.putFile(_selectedImage!);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl =
          await taskSnapshot.ref.getDownloadURL(); // Get the image URL
      setState(() {
        _downloadUrl = downloadUrl; // Save the download URL for later use
      });

      print('Image uploaded successfully. URL: $downloadUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showMapDialog() async {
    Position position = await _determinePosition();
    LatLng initialPosition = LatLng(position.latitude, position.longitude);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MapDialog(initialPosition: initialPosition);
      },
    ).then((selectedPosition) {
      if (selectedPosition != null) {
        setState(() {
          this.selectedPosition = selectedPosition;
          locationMessage =
              "${selectedPosition.latitude.toStringAsFixed(6)}, ${selectedPosition.longitude.toStringAsFixed(6)}";
        });
      }
    });
  }

  // Reset the fields when switching between User and Rider
// Reset the form fields when switching roles
  void _resetFields() {
    emailController.clear();
    phoneNumberController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    fullNameController.clear();
    addressController.clear();
    registrationController.clear();
    setState(() {
      selectedPosition = null;
      _selectedImage = null; // Reset the selected image when switching roles
    });
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(Icons.error, color: Colors.red, size: 40),
          content: Text(
            message,
            style: GoogleFonts.jetBrainsMono(),
          ),
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

  // Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(Icons.check_circle, color: Colors.green, size: 40),
          content: Text(
            'Sign Up Successful!',
            style: GoogleFonts.jetBrainsMono(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Function to sign up the user
  void _signUp(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (passwordController.text != confirmPasswordController.text) {
        _showErrorDialog('Passwords do not match');
        return;
      }

      if (selectedRole == 'User' && selectedPosition == null) {
        _showErrorDialog('Please select a GPS location');
        return;
      }

      // Upload image if selected
      if (_selectedImage != null) {
        await _uploadImageToFirebase();
      }

      final provider = Provider.of<AuthProvider>(context, listen: false);
      provider.setUserDetails(
        email: emailController.text,
        phoneNumber: phoneNumberController.text,
        password: passwordController.text,
        fullName: fullNameController.text,
        address: selectedRole == 'User' ? addressController.text : null,
        registrationNumber:
            selectedRole == 'Rider' ? registrationController.text : null,
        selectedPosition: selectedRole == 'User' ? selectedPosition : null,
        profileImageUrl: _downloadUrl,
      );

      // Show loading animation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: Colors.deepOrangeAccent,
              size: 50,
            ),
          );
        },
      );

      try {
        await provider.signUpUser(selectedRole);
        Navigator.of(context)
            .pop(); // Close the dialog when the signup is successful
        _showSuccessDialog();
      } catch (e) {
        Navigator.of(context).pop(); // Close the dialog when there is an error
        _showErrorDialog(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5CB58), Color(0xFFF37335)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset(
                        'assets/svg/arrow back.svg',
                        width: 16,
                        height: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Sign Up',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: SizedBox(
                  height: 50,
                  child: CustomSlidingSegmentedControl<String>(
                    initialValue: selectedRole,
                    isStretch: true,
                    children: {
                      'User': Text(
                        'User',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: selectedRole == 'User'
                              ? Colors.white
                              : const Color(0xFFE95322),
                        ),
                      ),
                      'Rider': Text(
                        'Rider',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: selectedRole == 'Rider'
                              ? Colors.white
                              : const Color(0xFFE95322),
                        ),
                      ),
                    },
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    thumbDecoration: BoxDecoration(
                      color: const Color(0xFFE95322),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    onValueChanged: (String newValue) {
                      setState(() {
                        selectedRole = newValue;
                        _resetFields(); // Reset the form fields when switching roles
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Stack(
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
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _selectedImage != null
                                        ? FileImage(
                                            _selectedImage!) // Display the selected image
                                        : const AssetImage(
                                                'assets/images/logo.png')
                                            as ImageProvider,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap:
                                        _selectImage, // Call the select image function
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
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (selectedRole == 'User') ...[
                            _buildTextField(
                              'Email',
                              'Enter Your Email',
                              controller: emailController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Phone Number',
                              'Enter Your Phone Number',
                              controller: phoneNumberController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Password',
                              'Enter Your Password',
                              controller: passwordController,
                              isPassword: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Confirm Password',
                              'Confirm Your Password',
                              controller: confirmPasswordController,
                              isPassword: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Full Name',
                              'Enter Your Full Name',
                              controller: fullNameController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Address',
                              'Enter Your Address',
                              controller: addressController,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _showMapDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22B8E9),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Get My GPS Location',
                                  style: GoogleFonts.leagueSpartan(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E9B5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  locationMessage ?? '-',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.leagueSpartan(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF5C5352),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ] else if (selectedRole == 'Rider') ...[
                            _buildTextField(
                              'Phone Number',
                              'Enter Your Phone Number',
                              controller: phoneNumberController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Password',
                              'Enter Your Password',
                              controller: passwordController,
                              isPassword: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Confirm Password',
                              'Confirm Your Password',
                              controller: confirmPasswordController,
                              isPassword: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Email',
                              'Enter Your Email',
                              controller: emailController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Full Name',
                              'Enter Your Full Name',
                              controller: fullNameController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Vehicle Registration Number',
                              'Enter Your Vehicle Registration Number',
                              controller: registrationController,
                              isLicensePlate: true,
                            ),
                            const SizedBox(height: 16),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _signUp(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE95322),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Sign Up',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            if (value == null || value.trim().isEmpty) {
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

}
