import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GooglePlacesService {
  static const String _apiKey = 'AIzaSyCmLleqfEJo6TUaER1AQcI6VMpaK66EptA';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  /// 설정에서 반경거리 가져오기
  static Future<int> _getRadiusFromSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final moveMode = prefs.getString('moveMode') ?? 'walk';

      if (moveMode == 'walk') {
        final walkDistance = prefs.getDouble('walkDistance') ?? 1.0;
        return (walkDistance * 1000).round(); // km를 m로 변환
      } else {
        final driveDistance = prefs.getDouble('driveDistance') ?? 10.0;
        return (driveDistance * 1000).round(); // km를 m로 변환
      }
    } catch (e) {
      print('설정에서 반경거리 읽기 실패: $e');
      return 5000; // 기본값 5km
    }
  }

  /// 맛집 검색
  static Future<List<Map<String, dynamic>>> searchRestaurants({
    required String query,
    required double latitude,
    required double longitude,
    int? radius, // radius 파라미터를 선택적으로 변경
  }) async {
    try {
      // 설정에서 반경거리 가져오기
      final actualRadius = radius ?? await _getRadiusFromSettings();

      final url = Uri.parse(
        '$_baseUrl/textsearch/json?query=$query&location=$latitude,$longitude&radius=$actualRadius&type=restaurant&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['results']);
        } else {
          print('Google Places API 오류: ${data['status']}');
          return [];
        }
      } else {
        print('HTTP 오류: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('맛집 검색 오류: $e');
      return [];
    }
  }

  /// 장소 상세 정보 가져오기
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/details/json?place_id=$placeId&fields=name,formatted_address,formatted_phone_number,rating,user_ratings_total,opening_hours,website,photos,geometry&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return data['result'];
        } else {
          print('Google Places Details API 오류: ${data['status']}');
          return null;
        }
      } else {
        print('HTTP 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('장소 상세 정보 오류: $e');
      return null;
    }
  }

  /// 주소를 좌표로 변환 (Geocoding)
  static Future<Map<String, double>?> geocodeAddress(String address) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'latitude': location['lat'].toDouble(),
            'longitude': location['lng'].toDouble(),
          };
        } else {
          print('Geocoding API 오류: ${data['status']}');
          return null;
        }
      } else {
        print('HTTP 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('주소 변환 오류: $e');
      return null;
    }
  }

  /// 주변 장소 검색 (반경 기반)
  static Future<List<Map<String, dynamic>>> searchNearbyPlaces({
    required double latitude,
    required double longitude,
    required String type,
    int? radius,
  }) async {
    try {
      // 설정에서 반경거리 가져오기
      final actualRadius = radius ?? await _getRadiusFromSettings();

      final url = Uri.parse(
        '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$actualRadius&type=$type&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['results']);
        } else {
          print('Google Places Nearby API 오류: ${data['status']}');
          return [];
        }
      } else {
        print('HTTP 오류: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('주변 장소 검색 오류: $e');
      return [];
    }
  }

  /// 현재 설정된 반경거리 정보 가져오기
  static Future<Map<String, dynamic>> getCurrentRadiusInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final moveMode = prefs.getString('moveMode') ?? 'walk';

      if (moveMode == 'walk') {
        final walkDistance = prefs.getDouble('walkDistance') ?? 1.0;
        return {
          'mode': 'walk',
          'distance': walkDistance,
          'unit': 'km',
          'radius_meters': (walkDistance * 1000).round(),
        };
      } else {
        final driveDistance = prefs.getDouble('driveDistance') ?? 10.0;
        return {
          'mode': 'drive',
          'distance': driveDistance,
          'unit': 'km',
          'radius_meters': (driveDistance * 1000).round(),
        };
      }
    } catch (e) {
      print('반경거리 정보 읽기 실패: $e');
      return {
        'mode': 'default',
        'distance': 5.0,
        'unit': 'km',
        'radius_meters': 5000,
      };
    }
  }
}
