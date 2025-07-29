import 'package:flutter/foundation.dart';

class Logger {
  static bool _isDebugMode = kDebugMode;
  
  static void setDebugMode(bool enabled) {
    _isDebugMode = enabled;
  }
  
  static void debug(String message) {
    if (_isDebugMode) {
      print('[DEBUG] $message');
    }
  }
  
  static void info(String message) {
    if (_isDebugMode) {
      print('[INFO] $message');
    }
  }
  
  static void warning(String message) {
    if (_isDebugMode) {
      print('[WARNING] $message');
    }
  }
  
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_isDebugMode) {
      print('[ERROR] $message');
      if (error != null) {
        print('[ERROR] Error: $error');
      }
      if (stackTrace != null) {
        print('[ERROR] Stack trace: $stackTrace');
      }
    }
  }
  
  static void performance(String operation, Duration duration) {
    if (_isDebugMode) {
      print('[PERFORMANCE] $operation took ${duration.inMilliseconds}ms');
    }
  }
} 