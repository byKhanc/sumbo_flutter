#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
REST API 키로 카카오맵 API 테스트
"""

import requests
import json

def test_rest_api():
    """REST API 키로 카카오맵 API 테스트"""
    
    # REST API 키
    api_key = "4de2f985cfcf673dc650623230990ccc"
    
    print("=== REST API 키로 카카오맵 API 테스트 ===")
    print(f"REST API 키: {api_key}")
    
    # 카카오맵 키워드 검색 API 테스트
    url = "https://dapi.kakao.com/v2/local/search/keyword.json"
    headers = {
        'Authorization': f'KakaoAK {api_key}'
    }
    params = {
        'query': '강남역 맛집',
        'size': 5
    }
    
    try:
        print("\n🔍 REST API 요청 중...")
        response = requests.get(url, headers=headers, params=params)
        
        print(f"응답 상태 코드: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ REST API 테스트 성공!")
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
            print(f"❌ REST API 테스트 실패: {response.status_code}")
            print(f"응답 내용: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ REST API 테스트 오류: {e}")
        return False

if __name__ == "__main__":
    print("🚀 REST API 키 테스트 시작...\n")
    
    # REST API 테스트
    rest_test = test_rest_api()
    
    print("\n📊 테스트 결과:")
    print(f"REST API 테스트: {'✅ 성공' if rest_test else '❌ 실패'}")
    
    if rest_test:
        print("\n🎉 REST API 테스트가 성공했습니다!")
        print("403 오류가 해결되었습니다!")
    else:
        print("\n⚠️ REST API 테스트가 실패했습니다.")
        print("카카오 개발자 콘솔에서 서비스 활성화를 확인해주세요.") 