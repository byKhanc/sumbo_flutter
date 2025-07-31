import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformHelper {
  static bool get isWeb => kIsWeb;
  
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  
  static bool get isMobile => isAndroid || isIOS;
  
  static bool get isEmulator {
    if (!isMobile) return false;
    
    // 에뮬레이터 감지 로직
    // 실제 구현에서는 더 정확한 방법을 사용할 수 있습니다
    return true; // 임시로 true 반환
  }
  
  static bool get isRealDevice => isMobile && !isEmulator;
  
  /// 플랫폼별 맵 타입 결정
  static MapType getMapType() {
    if (isWeb) {
      return MapType.kakao; // 웹에서는 카카오맵
    } else if (isEmulator) {
      return MapType.google; // 에뮬레이터에서는 구글맵
    } else {
      return MapType.kakao; // 실제 기기에서는 카카오맵
    }
  }
}

enum MapType {
  google,
  kakao,
} 