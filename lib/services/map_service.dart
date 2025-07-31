import 'package:flutter/material.dart';
import '../utils/platform_helper.dart';
import '../widgets/kakao_map_widget.dart';
import '../models/restaurant.dart';

class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  /// 플랫폼에 따른 맵 위젯 생성
  Widget createMapWidget({
    required List<Restaurant> restaurants,
    double initialLatitude = 37.5665,
    double initialLongitude = 126.9780,
    double zoom = 12.0,
  }) {
    final mapType = PlatformHelper.getMapType();
    
    switch (mapType) {
      case MapType.kakao:
        return KakaoMapWidget(
          restaurants: restaurants,
          initialLatitude: initialLatitude,
          initialLongitude: initialLongitude,
          zoom: zoom,
        );
      case MapType.google:
        return _createGoogleMapWidget(
          restaurants: restaurants,
          initialLatitude: initialLatitude,
          initialLongitude: initialLongitude,
          zoom: zoom,
        );
    }
  }

  /// 구글맵 위젯 생성 (에뮬레이터용)
  Widget _createGoogleMapWidget({
    required List<Restaurant> restaurants,
    required double initialLatitude,
    required double initialLongitude,
    required double zoom,
  }) {
    // 구글맵 위젯 구현
    // 실제 구현에서는 google_maps_flutter 패키지 사용
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.grey.shade200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  '구글맵 (에뮬레이터)',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '${restaurants.length}개의 음식점',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 8),
                Text(
                  '위도: $initialLatitude, 경도: $initialLongitude',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 현재 플랫폼 정보 반환
  String getPlatformInfo() {
    final mapType = PlatformHelper.getMapType();
    String platform = '';
    
    if (PlatformHelper.isWeb) {
      platform = '웹';
    } else if (PlatformHelper.isEmulator) {
      platform = '안드로이드 에뮬레이터';
    } else if (PlatformHelper.isRealDevice) {
      platform = '실제 모바일 기기';
    }
    
    String mapName = mapType == MapType.kakao ? '카카오맵' : '구글맵';
    
    return '$platform - $mapName 사용';
  }
} 