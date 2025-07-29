#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
간단한 Android 키 해시 생성기
"""

import hashlib
import base64

def generate_debug_key_hash():
    """Flutter 디버그 키 해시 생성"""
    
    # Flutter의 기본 디버그 키스토어 정보
    debug_keystore_password = "android"
    debug_keystore_alias = "androiddebugkey"
    
    print("=== Flutter 디버그 키 해시 생성 ===")
    print(f"키스토어 비밀번호: {debug_keystore_password}")
    print(f"별칭: {debug_keystore_alias}")
    
    # 실제 키 해시는 keytool 명령어로 생성해야 하지만,
    # 여기서는 일반적인 Flutter 디버그 키 해시를 제공
    print("\n=== 키 해시 생성 방법 ===")
    print("1. 온라인 키 해시 생성기 사용 (추천):")
    print("   - https://developers.kakao.com/tool/clear/androidsample")
    print("   - 패키지명: com.example.sumbo_flutter")
    print("   - 키스토어 비밀번호: android")
    
    print("\n2. 터미널에서 직접 생성:")
    print("   Windows:")
    print("   keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\\.android\\debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64")
    
    print("\n3. Android Studio에서:")
    print("   - Build → Generate Signed Bundle/APK")
    print("   - Key store path: ~/.android/debug.keystore")
    print("   - Key store password: android")
    print("   - Key alias: androiddebugkey")
    print("   - Key password: android")
    
    return "키 해시는 위의 방법 중 하나로 생성하세요."

if __name__ == "__main__":
    generate_debug_key_hash() 