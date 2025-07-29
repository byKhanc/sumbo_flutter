import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/restaurant_service_google.dart';

class GoogleMapWidget extends StatefulWidget {
  final List<Restaurant> restaurants;
  final Function(Restaurant)? onRestaurantTap;

  const GoogleMapWidget({
    super.key,
    required this.restaurants,
    this.onRestaurantTap,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await GoogleRestaurantService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('위치 가져오기 오류: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentPosition == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '위치 정보를 가져올 수 없습니다.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '위치 권한을 확인해주세요.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // 구글맵 플레이스홀더 (실제 구글맵 SDK 연동 필요)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 64, color: Colors.green[300]),
                  const SizedBox(height: 16),
                  Text(
                    '구글맵',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '현재 위치: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 14, color: Colors.green[600]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '음식점 ${widget.restaurants.length}개',
                    style: TextStyle(fontSize: 16, color: Colors.green[600]),
                  ),
                ],
              ),
            ),
          ),

          // 음식점 마커들
          ...widget.restaurants.map((restaurant) {
            return Positioned(
              left: _getMarkerPosition(restaurant.longitude),
              top: _getMarkerPosition(restaurant.latitude),
              child: GestureDetector(
                onTap: () => widget.onRestaurantTap?.call(restaurant),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 간단한 마커 위치 계산 (실제로는 지도 좌표 변환 필요)
  double _getMarkerPosition(double coordinate) {
    // 임시 위치 계산 (실제로는 지도 좌표계로 변환 필요)
    return (coordinate % 1) * 200 + 50;
  }
}
