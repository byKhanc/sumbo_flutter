import 'package:flutter/material.dart';
import '../services/map_service.dart';
import '../services/restaurant_service.dart';
import '../models/restaurant.dart';
import '../utils/platform_helper.dart';

class PlatformMapPage extends StatefulWidget {
  final bool fromHome;
  const PlatformMapPage({super.key, this.fromHome = false});

  @override
  State<PlatformMapPage> createState() => _PlatformMapPageState();
}

class _PlatformMapPageState extends State<PlatformMapPage> {
  final MapService _mapService = MapService();
  final RestaurantService _restaurantService = RestaurantService();
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    try {
      _restaurants = await _restaurantService.getAllRestaurants();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('맛집 데이터 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('맛집 지도'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          // 플랫폼 정보 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getPlatformInfo(),
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 플랫폼별 맵 위젯
                Expanded(
                  child: _mapService.createMapWidget(
                    restaurants: _restaurants,
                    initialLatitude: 37.5665,
                    initialLongitude: 126.9780,
                    zoom: 12.0,
                  ),
                ),
                // 맛집 목록 (선택사항)
                if (_restaurants.isNotEmpty)
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '주변 맛집 (${_restaurants.length}개)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _restaurants.length > 10 ? 10 : _restaurants.length,
                            itemBuilder: (context, index) {
                              final restaurant = _restaurants[index];
                              return Container(
                                width: 200,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurant.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      restaurant.category,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.orange.shade400,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${restaurant.rating}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  String _getPlatformInfo() {
    final mapType = PlatformHelper.getMapType();
    String platform = '';
    
    if (PlatformHelper.isWeb) {
      platform = '웹';
    } else if (PlatformHelper.isEmulator) {
      platform = '에뮬레이터';
    } else if (PlatformHelper.isRealDevice) {
      platform = '실제 기기';
    }
    
    String mapName = mapType == MapType.kakao ? '카카오맵' : '구글맵';
    
    return '$platform - $mapName';
  }
} 