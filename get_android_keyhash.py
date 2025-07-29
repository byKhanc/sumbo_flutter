#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Android 키 해시 생성기
카카오 개발자 콘솔에서 필요한 키 해시를 생성합니다.
"""

import hashlib
import base64

def generate_key_hash():
    """Android 키 해시 생성"""
    
    # Flutter 앱의 기본 키스토어 정보
    # Flutter는 기본적으로 debug.keystore를 사용합니다
    debug_keystore_password = "android"
    debug_keystore_alias = "androiddebugkey"
    debug_keystore_alias_password = "android"
    
    print("=== Android 키 해시 생성 ===")
    print(f"키스토어 비밀번호: {debug_keystore_password}")
    print(f"별칭: {debug_keystore_alias}")
    print(f"별칭 비밀번호: {debug_keystore_alias_password}")
    
    # 키 해시 생성 (개발용)
    # 실제로는 keytool 명령어를 사용해야 합니다
    print("\n=== 키 해시 생성 방법 ===")
    print("1. Android Studio에서:")
    print("   - Build → Generate Signed Bundle/APK")
    print("   - Key store path: ~/.android/debug.keystore")
    print("   - Key store password: android")
    print("   - Key alias: androiddebugkey")
    print("   - Key password: android")
    
    print("\n2. 터미널에서:")
    print("   keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64")
    
    print("\n3. Windows에서:")
    print("   keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\\.android\\debug.keystore | openssl sha1 -binary | openssl base64")
    
    return "키 해시는 위의 명령어로 생성할 수 있습니다."

if __name__ == "__main__":
    generate_key_hash() 