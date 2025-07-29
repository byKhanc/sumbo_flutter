// This file is only used on Android/iOS (mobile) platforms via conditional import in map_page.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPageMobile extends StatefulWidget {
  const MapPageMobile({super.key});
  @override
  State<MapPageMobile> createState() => _MapPageMobileState();
}

class _MapPageMobileState extends State<MapPageMobile> {
  static const LatLng _center = LatLng(37.5665, 126.9780); // 서울 시청
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('center'),
      position: _center,
      infoWindow: InfoWindow(title: '서울 시청'),
    ),
  };

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('보물 지도')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(target: _center, zoom: 13),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

Widget getMapPageWidget() => const MapPageMobile();
