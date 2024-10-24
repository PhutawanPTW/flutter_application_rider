import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_rider/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../rider/upload.dart';

class RiderRun extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const RiderRun({Key? key, required this.orderData}) : super(key: key);

  @override
  _RiderRunState createState() => _RiderRunState();
}

class _RiderRunState extends State<RiderRun> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isLoading = true;
  Marker? _senderMarker;
  Marker? _receiverMarker;

  @override
  void initState() {
    super.initState();
    _initializeLocationAndMarkers();
  }

  @override
  void dispose() {
    // ยกเลิกการสมัครเมื่อหน้า Widget ถูกทำลาย
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocationAndMarkers() async {
    await _getCurrentLocation();
    await _loadLocationsAndCreateMarkers();
    setState(() {
      _isLoading = false;
    });
  }

  // ฟังก์ชันสำหรับดึงตำแหน่งปัจจุบันครั้งแรก
  // อัปเดตฟังก์ชัน _getCurrentLocation
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition();

      // เริ่มติดตามตำแหน่งแบบเรียลไทม์
      _positionStreamSubscription =
          Geolocator.getPositionStream().listen((Position position) {
        setState(() {
          _currentPosition = position;

          // อัปเดตตำแหน่งในแผนที่
          _updateRiderMarker(position);
        });

        // ย้ายแผนที่ไปยังตำแหน่งใหม่
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15.0, // กำหนดซูมที่ต้องการ
        );
      });
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }
  }

  // ฟังก์ชันสำหรับสร้าง Marker สำหรับ Rider
  void _updateRiderMarker(Position position) {
    setState(() {
      // ลบหมุดทั้งหมด
      _markers.clear();

      // สร้างหมุดใหม่สำหรับ Rider
      final riderMarker = Marker(
        point: LatLng(position.latitude, position.longitude),
        child: Image.asset(
          'assets/images/placeholder.png', // กำหนด path รูปภาพ
          width: 40,
          height: 40,
        ),
      );

      // เพิ่มหมุด Rider
      _markers.add(riderMarker);

      // เพิ่มหมุดของ Sender และ Receiver จากตำแหน่งเดิม
      if (_senderMarker != null) {
        _markers.add(_senderMarker!);
      }

      if (_receiverMarker != null) {
        _markers.add(_receiverMarker!);
      }

      // เพิ่มหมุด Receiver ถ้ามี
    });
  }

  Future<void> _loadLocationsAndCreateMarkers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Fetch sender's data
    final senderData =
        await userProvider.fetchUserData(widget.orderData['senderPhone']);
    if (senderData != null) {
      final senderLocation = senderData['location'];
      if (senderLocation != null) {
        _senderMarker = Marker(
          point:
              LatLng(senderLocation['latitude'], senderLocation['longitude']),
          child: GestureDetector(
            onTap: () => _showLocationDetails(
              context,
              'Sender Details',
              senderData['phoneNumber'] ?? '',
              senderData['address'] ?? 'No address',
            ),
            child: Image.asset(
              'assets/images/restaurant.png',
              width: 40,
              height: 40,
            ),
          ),
        );
      }
    }

    // Fetch receiver's data and create marker
    final receiverData =
        await userProvider.fetchUserData(widget.orderData['recivePhone']);
    if (receiverData != null) {
      final receiverLocation = receiverData['location'];
      if (receiverLocation != null) {
        _receiverMarker = Marker(
          point: LatLng(
              receiverLocation['latitude'], receiverLocation['longitude']),
          child: GestureDetector(
            onTap: () => _showLocationDetails(
              context,
              'Receiver Details',
              receiverData['phoneNumber'] ?? '',
              receiverData['address'] ?? 'No address',
            ),
            child: Image.asset(
              'assets/images/pin-map.png',
              width: 40,
              height: 40,
            ),
          ),
        );
      }
    }
  }

  // ฟังก์ชันสำหรับแสดงรายละเอียดตำแหน่งใน Dialog
  void _showLocationDetails(
      BuildContext context, String title, String phone, String address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: GoogleFonts.leagueSpartan(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phone: $phone',
                style: GoogleFonts.leagueSpartan(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Address: $address',
                style: GoogleFonts.leagueSpartan(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.leagueSpartan(
                  color: const Color(0xFFE95322),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  // ฟังก์ชันสำหรับรีเฟรชแผนที่และลบหมุดของ Sender
  void refreshMap(int receivedValue) {
  if (receivedValue == 909 && _senderMarker != null) {
    // เช็คระยะห่างจากตำแหน่ง Rider ถึง _senderMarker
    if (_currentPosition != null) {
      final riderLat = _currentPosition!.latitude;
      final riderLng = _currentPosition!.longitude;

      final senderLat = _senderMarker!.point.latitude;
      final senderLng = _senderMarker!.point.longitude;

      // คำนวณระยะห่าง
      final distance = Geolocator.distanceBetween(
        riderLat,
        riderLng,
        senderLat,
        senderLng,
      );

      // เช็คว่าระยะห่างน้อยกว่าหรือเท่ากับ 20 เมตร
      if (distance <= 20) {
        setState(() {
          _markers.remove(_senderMarker); // ลบหมุดของ Sender
          _senderMarker = null; // ล้างตัวแปรหมุด
        });
      } else {
        // แสดง AlertDialog ถ้าระยะห่างมากกว่า 20 เมตร
        _showDistanceAlert(context, distance);
      }
    }
  }
}
void _showDistanceAlert(BuildContext context, double distance) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Cannot Remove Sender Marker'),
        content: Text(
          'The distance between the rider and the sender is ${distance.toStringAsFixed(2)} meters, which is greater than 20 meters. Please get closer to remove the marker.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
      // Return false to prevent the back button from closing the page
      return false;
    },
      child: Scaffold(
        body: Stack(
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  // Yellow header
                  Container(
                    color: const Color(0xFFFFD700),
                    padding: const EdgeInsets.only(
                      top: 40,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // ทำให้ข้อความอยู่ตรงกลาง
                      children: [
                        Text(
                          'Location Rider',
                          style: GoogleFonts.leagueSpartan(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
      
                  // Map
                  Expanded(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPosition != null
                            ? LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude)
                            : const LatLng(
                                13.7563, 100.5018), // Default to Bangkok
                        initialZoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: _markers,
                        ),
                      ],
                    ),
                  ),
                  // Upload Photo Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE95322),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Upload()),
                          );
      
                          if (result != null) {
                            int receivedValue = result as int;
                            debugPrint('Received value: $receivedValue');
                            refreshMap(
                                receivedValue); // รีเฟรชแผนที่เมื่อได้รับค่า 909
                          }
                        },
                        child: Text(
                          'Upload Photo',
                          style: GoogleFonts.leagueSpartan(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
