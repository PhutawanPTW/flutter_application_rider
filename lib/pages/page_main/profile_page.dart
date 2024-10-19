import 'package:flutter/material.dart';
import 'package:flutter_application_rider/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: userProvider.userData.isNotEmpty
          ? Column(
              children: [
                ListTile(
                  title: Text('Email: ${userProvider.userData['email']}'),
                ),
                ListTile(
                  title: Text('Phone: ${userProvider.userData['phoneNumber']}'),
                ),
                ListTile(
                  title: Text('Name: ${userProvider.userData['fullName']}'),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
