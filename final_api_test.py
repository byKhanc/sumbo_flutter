#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
최종 카카오맵 API 테스트
"""

import requests
import json

def test_final_api():
    """최종 카카오맵 API 테스트"""
    
    # 네이티브 앱 키 사용
    api_key = "388c45ca23d7b8386311d06c1f752589"
    
    print("=== 최종 카카오맵 API 테스트 ===")
    print(f"API 키: {api_key}")
    print("키 해시: 2jmj7l5rSw0yVb/vlWAYkK/YBwk=")
    
    # 카카오맵 키워드 검색 API 테스트
    url = "https://dapi.kakao.com/v2/local/search/keyword.json"
    headers = {
        'Authorization': f'KakaoAK {api_key}'
    }
    params = {
        'query': '강남역 맛집',
        'size': 3
    }
    
    try:
        print("\n🔍 API 요청 중...")
        response = requests.get(url, headers=headers, params=params)
        
        print(f"응답 상태 코드: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ API 테스트 성공!")
            print(f"검색 결과 개수: {len(data.get('documents', []))}")
            
            # 첫 번째 결과 출력
            if data.get('documents'):
                first_result = data['documents'][0]
                print(f"\n📍 첫 번째 결과:")
                print(f"  - 이름: {first_result.get('place_name', 'N/A')}")
                print(f"  - 주소: {first_result.get('address_name', 'N/A')}")
                print(f"  - 카테고리: {first_result.get('category_name', 'N/A')}")
            
            return True
        else:
            print(f"❌ API 테스트 실패: {response.status_code}")
            print(f"응답 내용: {response.text}")
            
            if "disabled OPEN_MAP_AND_LOCAL service" in response.text:
                print("\n🚨 문제: 카카오맵 서비스가 비활성화되어 있습니다!")
                print("해결 방법:")
                print("1. https://developers.kakao.com/ 접속")
                print("2. 내 애플리케이션 → '숨보' 앱 선택")
                print("3. 서비스 탭 → 카카오맵 → 활성화")
                print("4. 동의항목 → 선택 동의 항목에서 카카오맵 API 체크")
            
            return False
            
    except Exception as e:
        print(f"❌ API 테스트 오류: {e}")
        return False

if __name__ == "__main__":
    print("🚀 최종 카카오맵 API 테스트 시작...\n")
    
    # 최종 테스트
    final_test = test_final_api()
    
    print("\n📊 테스트 결과:")
    print(f"최종 테스트: {'✅ 성공' if final_test else '❌ 실패'}")
    
    if final_test:
        print("\n🎉 API 테스트가 성공했습니다!")
        print("403 오류가 완전히 해결되었습니다!")
        print("이제 Flutter 앱에서 카카오맵 API를 사용할 수 있습니다!")
    else:
        print("\n⚠️ API 테스트가 실패했습니다.")
        print("카카오 개발자 콘솔에서 서비스 활성화를 확인해주세요.") 