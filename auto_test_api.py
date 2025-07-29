#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
자동 카카오맵 API 테스트 스크립트
"""

import requests
import json
import time

def test_api_with_retry():
    """재시도 기능이 있는 API 테스트"""
    
    api_key = "388c45ca23d7b8386311d06c1f752589"
    
    print("=== 자동 카카오맵 API 테스트 ===")
    print(f"API 키: {api_key}")
    print("키 해시: 2jmj7l5rSw0yVb/vlWAYkK/YBwk=")
    
    url = "https://dapi.kakao.com/v2/local/search/keyword.json"
    headers = {
        'Authorization': f'KakaoAK {api_key}'
    }
    params = {
        'query': '강남역 맛집',
        'size': 3
    }
    
    # 최대 5번 재시도
    for attempt in range(1, 6):
        try:
            print(f"\n🔍 API 요청 시도 {attempt}/5...")
            response = requests.get(url, headers=headers, params=params)
            
            print(f"응답 상태 코드: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                print("✅ API 테스트 성공!")
                print(f"검색 결과 개수: {len(data.get('documents', []))}")
                
                if data.get('documents'):
                    first_result = data['documents'][0]
                    print(f"\n📍 첫 번째 결과:")
                    print(f"  - 이름: {first_result.get('place_name', 'N/A')}")
                    print(f"  - 주소: {first_result.get('address_name', 'N/A')}")
                
                return True
            else:
                print(f"❌ API 테스트 실패: {response.status_code}")
                print(f"응답 내용: {response.text}")
                
                if "disabled OPEN_MAP_AND_LOCAL service" in response.text:
                    print(f"\n🚨 시도 {attempt}/5: 카카오맵 서비스가 비활성화되어 있습니다!")
                    if attempt < 5:
                        print("5초 후 재시도합니다...")
                        time.sleep(5)
                    else:
                        print("\n❌ 최대 재시도 횟수 초과!")
                        print("카카오 개발자 콘솔에서 서비스를 활성화해주세요.")
                
                elif response.status_code == 401:
                    print(f"\n🚨 시도 {attempt}/5: 인증 오류!")
                    if attempt < 5:
                        print("3초 후 재시도합니다...")
                        time.sleep(3)
                
                else:
                    print(f"\n🚨 시도 {attempt}/5: 알 수 없는 오류!")
                    if attempt < 5:
                        print("2초 후 재시도합니다...")
                        time.sleep(2)
                
        except Exception as e:
            print(f"❌ 시도 {attempt}/5 오류: {e}")
            if attempt < 5:
                print("1초 후 재시도합니다...")
                time.sleep(1)
    
    return False

def main():
    print("🚀 자동 카카오맵 API 테스트 시작...\n")
    
    # API 테스트 실행
    success = test_api_with_retry()
    
    print("\n" + "="*50)
    print("📊 최종 테스트 결과:")
    print("="*50)
    
    if success:
        print("🎉 API 테스트가 성공했습니다!")
        print("✅ 403 오류가 완전히 해결되었습니다!")
        print("✅ 카카오맵 API가 정상 작동합니다!")
        print("✅ Flutter 앱에서 카카오맵 API를 사용할 수 있습니다!")
    else:
        print("❌ API 테스트가 실패했습니다.")
        print("\n🔧 해결 방법:")
        print("1. https://developers.kakao.com/ 접속")
        print("2. 내 애플리케이션 → '숨보' 앱 선택")
        print("3. 서비스 탭 → 카카오맵 → 활성화")
        print("4. 동의항목 → 선택 동의 항목에서 카카오맵 API 체크")
        print("5. 설정 완료 후 1-2분 대기")
        print("6. 다시 이 스크립트를 실행하세요.")

if __name__ == "__main__":
    main() 