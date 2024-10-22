import 'package:flutter/material.dart';
import 'package:flutter_application_rider/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocationAndMarkers();
  }

  Future<void> _initializeLocationAndMarkers() async {
    await _getCurrentLocation();
    await _loadLocationsAndCreateMarkers();
    setState(() {
      _isLoading = false;
    });
  }

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
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }
  }

  void _showLocationDetails(BuildContext context, String title, String phone, String address) {
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

  Future<void> _loadLocationsAndCreateMarkers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Marker> markers = [];

    // Add rider's current location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          child: const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    }

    // Add sender's location marker
    final senderLocation = await userProvider.fetchUserLocation(widget.orderData['senderPhone']);
    if (senderLocation != null) {
      markers.add(
        Marker(
          point: LatLng(senderLocation['latitude'], senderLocation['longitude']),
          child: GestureDetector(
            onTap: () => _showLocationDetails(
              context,
              'Sender Details',
              widget.orderData['senderPhone'] ?? '',
              widget.orderData['address'] ?? '',
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.green,
              size: 40,
            ),
          ),
        ),
      );
    }

    // Add receiver's location marker
    final receiverLocation = await userProvider.fetchUserLocation(widget.orderData['recivePhone']);
    if (receiverLocation != null) {
      markers.add(
        Marker(
          point: LatLng(receiverLocation['latitude'], receiverLocation['longitude']),
          child: GestureDetector(
            onTap: () => _showLocationDetails(
              context,
              'Receiver Details',
              widget.orderData['recivePhone'] ?? '',
              widget.orderData['address'] ?? '',
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    children: [
                      Text(
                        'Location Rider',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                          ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                          : const LatLng(13.7563, 100.5018), // Default to Bangkok
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                      onPressed: () {
                        // Handle upload photo
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
    );
  }
}