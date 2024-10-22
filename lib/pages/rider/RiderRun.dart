import 'package:flutter/material.dart';
import 'package:flutter_application_rider/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class RiderRun extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const RiderRun({Key? key, required this.orderData}) : super(key: key);

  @override
  _RiderRunState createState() => _RiderRunState();
}

class _RiderRunState extends State<RiderRun> {
  Future<Map<String, dynamic>?> _fetchUserLocation(String phone) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return await userProvider.fetchUserLocation(phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rider Run',
          style: GoogleFonts.leagueSpartan(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Details',
              style: GoogleFonts.leagueSpartan(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Name: ${widget.orderData['name']}'),
            Text('Amount: ${widget.orderData['amount']}'),
            Text('Address: ${widget.orderData['address']}'),
            Text('Detail: ${widget.orderData['detail']}'),
            Text('Receiver Phone: ${widget.orderData['recivePhone']}'),
            Text('Sender Phone: ${widget.orderData['senderPhone']}'),
            const SizedBox(height: 16),

            // ดึงข้อมูลตำแหน่งของผู้รับ
            FutureBuilder(
              future: _fetchUserLocation(widget.orderData['recivePhone']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final location = snapshot.data as Map<String, dynamic>?;

                if (location != null) {
                  return Text(
                    'Receiver Location: Lat ${location['latitude']}, Long ${location['longitude']}',
                    style: TextStyle(fontSize: 16),
                  );
                } else {
                  return Text('No location found for receiver.');
                }
              },
            ),
            const SizedBox(height: 16),

            // ดึงข้อมูลตำแหน่งของผู้ส่ง
            FutureBuilder(
              future: _fetchUserLocation(widget.orderData['senderPhone']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final location = snapshot.data as Map<String, dynamic>?;

                if (location != null) {
                  return Text(
                    'Sender Location: Lat ${location['latitude']}, Long ${location['longitude']}',
                    style: TextStyle(fontSize: 16),
                  );
                } else {
                  return Text('No location found for sender.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
