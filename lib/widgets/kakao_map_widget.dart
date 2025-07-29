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

    // 카카오맵 JavaScript API를 사용하여 웹뷰로 표시
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
    // 카카오맵 JavaScript API를 사용한 HTML
    final htmlContent =
        '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>카카오맵</title>
        <style>
          #map { width: 100%; height: 100%; }
        </style>
      </head>
      <body>
        <div id="map"></div>
        <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=4de2f985cfcf673dc650623230990ccc&libraries=services"></script>
        <script>
          var mapContainer = document.getElementById('map');
          var mapOption = {
            center: new kakao.maps.LatLng($_latitude, $_longitude),
            level: $_zoom
          };
          
          var map = new kakao.maps.Map(mapContainer, mapOption);
          
          // 음식점 마커 추가
          var restaurants = $_restaurants;
          restaurants.forEach(function(restaurant) {
            var marker = new kakao.maps.Marker({
              position: new kakao.maps.LatLng(restaurant.latitude, restaurant.longitude)
            });
            
            marker.setMap(map);
            
            // 인포윈도우 추가
            var infowindow = new kakao.maps.InfoWindow({
              content: '<div style="padding:5px;font-size:12px;">' + restaurant.name + '</div>'
            });
            
            kakao.maps.event.addListener(marker, 'click', function() {
              infowindow.open(map, marker);
            });
          });
        </script>
      </body>
      </html>
    ''';

    // 웹뷰로 카카오맵 표시
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '카카오맵 로드 중...',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              '${_restaurants.length}개의 음식점',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
