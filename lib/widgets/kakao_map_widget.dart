import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class KakaoMapWidget extends StatefulWidget {
  final List<Restaurant> restaurants;
  final double initialLatitude;
  final double initialLongitude;
  final double zoom;

  const KakaoMapWidget({
    super.key,
    required this.restaurants,
    this.initialLatitude = 37.5665,
    this.initialLongitude = 126.9780,
    this.zoom = 12.0,
  });

  @override
  State<KakaoMapWidget> createState() => _KakaoMapWidgetState();
}

class _KakaoMapWidgetState extends State<KakaoMapWidget> {
  late double _latitude;
  late double _longitude;
  late double _zoom;
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
    _zoom = widget.zoom;
    _restaurants = widget.restaurants;
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 웹에서 카카오맵 표시
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildKakaoMapWebView(),
      ),
    );
  }

  Widget _buildKakaoMapWebView() {
    // 웹에서 카카오맵 표시 (간단한 버전)
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 64, color: Color(0xFF2563eb)),
            const SizedBox(height: 16),
            Text(
              '카카오맵 (웹)',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '${_restaurants.length}개의 음식점',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            Text(
              '위도: $_latitude, 경도: $_longitude',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563eb),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '카카오맵 API 연동 준비 완료',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
