import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/treasure_service.dart';
import '../models/treasure.dart';

class MapPage extends StatefulWidget {
  final bool fromHome;
  const MapPage({super.key, this.fromHome = false});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TreasureService _treasureService = TreasureService();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  List<Treasure> _treasures = [];
  bool _isLoading = true;
  bool _showNotificationPopup = false;
  bool _showSnackBar = false;
  int _discoveredTreasures = 0;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _currentPosition = await Geolocator.getCurrentPosition();
      }

      // 보물 데이터 로드
      _treasures = _treasureService.getAllTreasures();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('지도 초기화 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentPosition != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  void _showTreasureNotifications() {
    setState(() {
      _showNotificationPopup = true;
      _discoveredTreasures = _treasures.length;
    });

    // 3초 후 팝업 닫기
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showNotificationPopup = false;
          _showSnackBar = true;
        });

        // 스낵바 5초 후 자동 닫기
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showSnackBar = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('보물지도'),
        backgroundColor: const Color(0xFF2563eb),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    )
                  : const LatLng(37.5665, 126.9780),
              zoom: 15.0,
            ),
            markers: _treasures.map((treasure) {
              return Marker(
                markerId: MarkerId(treasure.id),
                position: LatLng(treasure.latitude, treasure.longitude),
                infoWindow: InfoWindow(
                  title: treasure.name,
                  snippet: treasure.description,
                ),
              );
            }).toSet(),
          ),
          // 우측 하단 버튼들
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _goToCurrentLocation,
                  backgroundColor: const Color(0xFF2563eb),
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: _showTreasureNotifications,
                  backgroundColor: const Color(0xFF2563eb),
                  child: const Icon(Icons.notifications, color: Colors.white),
                ),
              ],
            ),
          ),
          // 보물 알림 팝업창!
          if (_showNotificationPopup)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 48, color: Colors.amber),
                        const SizedBox(height: 16),
                        const Text(
                          '보물 알림',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '주변에 $_discoveredTreasures개의 보물이 있습니다!',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '지도를 탐색하여 보물을 찾아보세요!',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // 스낵바
          if (_showSnackBar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFF2563eb),
                padding: const EdgeInsets.all(16),
                child: Text(
                  '$_discoveredTreasures개의 보물들이 발견되었습니다.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
