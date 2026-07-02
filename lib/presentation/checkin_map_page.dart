import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckinMapPage extends StatefulWidget {
  final String userName;
  final bool isCheckIn;

  const CheckinMapPage({
    super.key,
    required this.userName,
    required this.isCheckIn,
  });

  @override
  State<CheckinMapPage> createState() => _CheckinMapPageState();
}

class _CheckinMapPageState extends State<CheckinMapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  Position? _currentPosition;
  String _currentAddress = 'Mencari lokasi...';
  bool _isLoading = true;

  final Set<Marker> _markers = {};
  final LatLng _defaultLocation = const LatLng(
    -6.210656794550148,
    106.81289946074679,
  );

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: const MarkerId('defaultLocation'),
        position: _defaultLocation,
        infoWindow: const InfoWindow(title: 'Lokasi Absensi'),
      ),
    );
    _checkLocationPermission();
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentAddress = 'Layanan lokasi tidak aktif.';
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = 'Izin lokasi ditolak.';
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress = 'Izin lokasi ditolak secara permanen.';
        _isLoading = false;
      });
      return;
    }
    Future<void> getCurrentLocation() async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        String address = "";
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}';
        }

        setState(() {
          _currentPosition = position;
          _currentAddress = address;
          _isLoading = false;
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: const InfoWindow(title: 'Lokasi Anda'),
            ),
          );
        });

        final GoogleMapController mapController = await _controller.future;
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17.0,
            ),
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }

    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _defaultLocation,
              zoom: 17.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),

          // Map Controls (Zoom in/out, My Location)
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () async {
                      final controller = await _controller.future;
                      controller.animateCamera(CameraUpdate.zoomIn());
                    },
                  ),
                  Container(height: 1, width: 45, color: Colors.grey.shade200),
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () async {
                      final controller = await _controller.future;
                      controller.animateCamera(CameraUpdate.zoomOut());
                    },
                  ),
                  Container(height: 1, width: 45, color: Colors.grey.shade200),
                  IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.white),
                    onPressed: () async {
                      if (_currentPosition != null) {
                        final controller = await _controller.future;
                        controller.animateCamera(
                          CameraUpdate.newLatLng(
                            LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Floating Information Card
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E), // cardSurface
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF2A2A4A),
                ), // borderColor
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Lokasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Latitude',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8888AA), // textMuted
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentPosition?.latitude.toString() ?? '-',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Longitude',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8888AA), // textMuted
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentPosition?.longitude.toString() ?? '-',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Alamat',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8888AA), // textMuted
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentAddress,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Jarak ke PPKD Jakarta Pusat: ~ 500m', // Hardcoded mock for now
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8888AA), // textMuted
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52, // Button Height 52
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context, {
                                'address': _currentAddress,
                                'time': DateTime.now(),
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF4CAF50,
                        ), // primaryColor
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.isCheckIn
                            ? 'Check In Sekarang'
                            : 'Check Out Sekarang',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
