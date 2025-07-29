#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Android 키 해시 생성기 (간단 버전)
"""

import os
import subprocess
import sys

def generate_key_hash():
    """Android 키 해시 생성"""
    
    print("=== Android 키 해시 생성 ===")
    
    # 방법 1: keytool 명령어 사용
    try:
        # Windows에서 키 해시 생성
        cmd = [
            "keytool", 
            "-exportcert", 
            "-alias", "androiddebugkey",
            "-keystore", os.path.expanduser("~/.android/debug.keystore"),
            "-storepass", "android",
            "-keypass", "android"
        ]
        
        print("키 해시 생성 중...")
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            # SHA1 해시 생성
            import hashlib
            import base64
            
            sha1_hash = hashlib.sha1(result.stdout.encode()).digest()
            key_hash = base64.b64encode(sha1_hash).decode()
            
            print(f"✅ 키 해시 생성 성공!")
            print(f"키 해시: {key_hash}")
            return key_hash
        else:
            print(f"❌ 키 해시 생성 실패: {result.stderr}")
            return None
            
    except Exception as e:
        print(f"❌ 오류: {e}")
        return None

def main():
    key_hash = generate_key_hash()
    
    if key_hash:
        print("\n=== 카카오 개발자 콘솔 설정 방법 ===")
        print("1. https://developers.kakao.com/ 접속")
        print("2. 내 애플리케이션 → 앱 선택")
        print("3. 플랫폼 → Android")
        print("4. 패키지명: com.example.sumbo_flutter")
        print(f"5. 키 해시: {key_hash}")
        print("6. 저장")
    else:
        print("\n=== 대안 방법 ===")
        print("1. Android Studio에서:")
        print("   - Build → Generate Signed Bundle/APK")
        print("   - Key store path: ~/.android/debug.keystore")
        print("   - Key store password: android")
        print("   - Key alias: androiddebugkey")
        print("   - Key password: android")
        print("\n2. 온라인 키 해시 생성기:")
        print("   - https://developers.kakao.com/tool/clear/androidsample")
        print("   - 패키지명: com.example.sumbo_flutter")

if __name__ == "__main__":
    main() 