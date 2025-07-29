import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesService {
  static const String _apiKey = 'AIzaSyCmLleqfEJo6TUaER1AQcI6VMpaK66EptA';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  /// 맛집 검색
  static Future<List<Map<String, dynamic>>> searchRestaurants({
    required String query,
    required double latitude,
    required double longitude,
    int radius = 5000, // 5km 반경
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/textsearch/json?query=$query&location=$latitude,$longitude&radius=$radius&type=restaurant&key=$_apiKey',
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

  /// 좌표를 주소로 변환 (Reverse Geocoding)
  static Future<String?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        } else {
          print('Reverse Geocoding API 오류: ${data['status']}');
          return null;
        }
      } else {
        print('HTTP 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('좌표 변환 오류: $e');
      return null;
    }
  }

  /// 경로 안내 (Directions API)
  static Future<Map<String, dynamic>?> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$originLat,$originLng&destination=$destLat,$destLng&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          return data['routes'][0];
        } else {
          print('Directions API 오류: ${data['status']}');
          return null;
        }
      } else {
        print('HTTP 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('경로 안내 오류: $e');
      return null;
    }
  }
}
