import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  static const String _backupKey = 'app_backup_data';
  static const String _backupTimestampKey = 'backup_timestamp';

  /// 데이터 백업 생성
  static Future<bool> createBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 현재 앱 데이터 수집
      final backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'data': {
          'user_preferences': await _getUserPreferences(),
          'completed_missions': await _getCompletedMissions(),
          'collected_treasures': await _getCollectedTreasures(),
          'favorite_places': await _getFavoritePlaces(),
        }
      };

      // JSON으로 변환하여 저장
      final jsonData = jsonEncode(backupData);
      await prefs.setString(_backupKey, jsonData);
      await prefs.setString(
          _backupTimestampKey, backupData['timestamp'] as String);

      print('백업 생성 완료: ${backupData['timestamp']}');
      return true;
    } catch (e) {
      print('백업 생성 실패: $e');
      return false;
    }
  }

  /// 백업 데이터 복구
  static Future<bool> restoreBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupJson = prefs.getString(_backupKey);

      if (backupJson == null) {
        print('복구할 백업 데이터가 없습니다.');
        return false;
      }

      final backupData = jsonDecode(backupJson);
      final data = backupData['data'] as Map<String, dynamic>;

      // 데이터 복구
      await _restoreUserPreferences(data['user_preferences']);
      await _restoreCompletedMissions(data['completed_missions']);
      await _restoreCollectedTreasures(data['collected_treasures']);
      await _restoreFavoritePlaces(data['favorite_places']);

      print('백업 복구 완료: ${backupData['timestamp']}');
      return true;
    } catch (e) {
      print('백업 복구 실패: $e');
      return false;
    }
  }

  /// 백업 데이터 확인
  static Future<Map<String, dynamic>?> getBackupInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupJson = prefs.getString(_backupKey);
      final timestamp = prefs.getString(_backupTimestampKey);

      if (backupJson == null) return null;

      final backupData = jsonDecode(backupJson);
      return {
        'timestamp': timestamp,
        'version': backupData['version'],
        'data_size': backupJson.length,
      };
    } catch (e) {
      print('백업 정보 조회 실패: $e');
      return null;
    }
  }

  /// 자동 백업 설정
  static Future<void> setupAutoBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_backup_enabled', true);
      await prefs.setInt('auto_backup_interval_hours', 24); // 24시간마다

      print('자동 백업 설정 완료');
    } catch (e) {
      print('자동 백업 설정 실패: $e');
    }
  }

  // Private helper methods
  static Future<Map<String, dynamic>> _getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'theme': prefs.getString('theme') ?? 'light',
      'language': prefs.getString('language') ?? 'ko',
      'notifications_enabled': prefs.getBool('notifications_enabled') ?? true,
      'scroll_buttons_enabled': prefs.getBool('scrollButtonsEnabled') ?? true,
    };
  }

  static Future<List<String>> _getCompletedMissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('completed_missions') ?? [];
  }

  static Future<List<String>> _getCollectedTreasures() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('collected_treasures') ?? [];
  }

  static Future<List<String>> _getFavoritePlaces() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorite_places') ?? [];
  }

  static Future<void> _restoreUserPreferences(
      Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in preferences.entries) {
      if (entry.value is String) {
        await prefs.setString(entry.key, entry.value);
      } else if (entry.value is bool) {
        await prefs.setBool(entry.key, entry.value);
      } else if (entry.value is int) {
        await prefs.setInt(entry.key, entry.value);
      }
    }
  }

  static Future<void> _restoreCompletedMissions(List<dynamic> missions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completed_missions', missions.cast<String>());
  }

  static Future<void> _restoreCollectedTreasures(
      List<dynamic> treasures) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('collected_treasures', treasures.cast<String>());
  }

  static Future<void> _restoreFavoritePlaces(List<dynamic> places) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_places', places.cast<String>());
  }
}
