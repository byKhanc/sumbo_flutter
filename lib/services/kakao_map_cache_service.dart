import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class KakaoMapCacheService {
  static final KakaoMapCacheService _instance =
      KakaoMapCacheService._internal();
  factory KakaoMapCacheService() => _instance;
  KakaoMapCacheService._internal();

  static const String _cacheFileName = 'kakao_map_restaurants.json';
  static const String _lastUpdateFileName = 'kakao_map_last_update.txt';

  /// 카카오맵 API 데이터를 로컬에 저장
  Future<void> saveKakaoMapData(List<Map<String, dynamic>> restaurants) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_cacheFileName');

      final jsonData = json.encode(restaurants);
      await file.writeAsString(jsonData);

      // 마지막 업데이트 시간 저장
      final lastUpdateFile = File('${directory.path}/$_lastUpdateFileName');
      await lastUpdateFile.writeAsString(DateTime.now().toIso8601String());

      print('카카오맵 데이터 로컬 저장 완료: ${restaurants.length}개 맛집');
    } catch (e) {
      print('카카오맵 데이터 저장 실패: $e');
    }
  }

  /// 로컬에 저장된 카카오맵 데이터 불러오기
  Future<List<Map<String, dynamic>>?> loadKakaoMapData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_cacheFileName');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        final restaurants = jsonList.cast<Map<String, dynamic>>();

        print('카카오맵 데이터 로컬 로드 완료: ${restaurants.length}개 맛집');
        return restaurants;
      }
    } catch (e) {
      print('카카오맵 데이터 로드 실패: $e');
    }
    return null;
  }

  /// 마지막 업데이트 시간 확인
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_lastUpdateFileName');

      if (await file.exists()) {
        final timeString = await file.readAsString();
        return DateTime.parse(timeString);
      }
    } catch (e) {
      print('마지막 업데이트 시간 확인 실패: $e');
    }
    return null;
  }

  /// 캐시 데이터 삭제
  Future<void> clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheFile = File('${directory.path}/$_cacheFileName');
      final lastUpdateFile = File('${directory.path}/$_lastUpdateFileName');

      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
      if (await lastUpdateFile.exists()) {
        await lastUpdateFile.delete();
      }

      print('카카오맵 캐시 데이터 삭제 완료');
    } catch (e) {
      print('카카오맵 캐시 삭제 실패: $e');
    }
  }

  /// 캐시 데이터 존재 여부 확인
  Future<bool> hasCachedData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_cacheFileName');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
