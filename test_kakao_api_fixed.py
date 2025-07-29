#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
카카오맵 API 테스트 (KA Header 수정)
"""

import requests
import json

def test_kakao_api():
    """카카오맵 API 테스트"""
    
    # 네이티브 앱 키
    api_key = "388c45ca23d7b8386311d06c1f752589"
    
    print("=== 카카오맵 API 테스트 ===")
    print(f"API 키: {api_key}")
    
    # 카카오맵 키워드 검색 API 테스트
    url = "https://dapi.kakao.com/v2/local/search/keyword.json"
    headers = {
        'Authorization': f'KakaoAK {api_key}',
        'KA': 'sdk/1.0.0 os/android'
    }
    params = {
        'query': '강남역 맛집',
        'size': 5
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
            return False
            
    except Exception as e:
        print(f"❌ API 테스트 오류: {e}")
        return False

def test_kakao_place_api():
    """카카오맵 장소 검색 API 테스트"""
    
    api_key = "388c45ca23d7b8386311d06c1f752589"
    
    print("\n=== 카카오맵 장소 검색 API 테스트 ===")
    
    url = "https://dapi.kakao.com/v2/local/search/address.json"
    headers = {
        'Authorization': f'KakaoAK {api_key}',
        'KA': 'sdk/1.0.0 os/android'
    }
    params = {
        'query': '서울 강남구',
        'size': 3
    }
    
    try:
        print("🔍 주소 검색 API 요청 중...")
        response = requests.get(url, headers=headers, params=params)
        
        print(f"응답 상태 코드: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ 주소 검색 API 테스트 성공!")
            print(f"검색 결과 개수: {len(data.get('documents', []))}")
            return True
        else:
            print(f"❌ 주소 검색 API 테스트 실패: {response.status_code}")
            print(f"응답 내용: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ 주소 검색 API 테스트 오류: {e}")
        return False

def test_kakao_api_simple():
    """간단한 카카오맵 API 테스트 (헤더 없이)"""
    
    api_key = "388c45ca23d7b8386311d06c1f752589"
    
    print("\n=== 간단한 카카오맵 API 테스트 ===")
    
    url = "https://dapi.kakao.com/v2/local/search/keyword.json"
    headers = {
        'Authorization': f'KakaoAK {api_key}'
    }
    params = {
        'query': '강남역',
        'size': 1
    }
    
    try:
        print("🔍 간단한 API 요청 중...")
        response = requests.get(url, headers=headers, params=params)
        
        print(f"응답 상태 코드: {response.status_code}")
        print(f"응답 헤더: {dict(response.headers)}")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ 간단한 API 테스트 성공!")
            return True
        else:
            print(f"❌ 간단한 API 테스트 실패: {response.status_code}")
            print(f"응답 내용: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ 간단한 API 테스트 오류: {e}")
        return False

if __name__ == "__main__":
    print("🚀 카카오맵 API 테스트 시작...\n")
    
    # 간단한 테스트 먼저
    simple_test = test_kakao_api_simple()
    
    # 키워드 검색 테스트
    keyword_test = test_kakao_api()
    
    # 주소 검색 테스트
    address_test = test_kakao_place_api()
    
    print("\n📊 테스트 결과:")
    print(f"간단한 테스트: {'✅ 성공' if simple_test else '❌ 실패'}")
    print(f"키워드 검색: {'✅ 성공' if keyword_test else '❌ 실패'}")
    print(f"주소 검색: {'✅ 성공' if address_test else '❌ 실패'}")
    
    if keyword_test and address_test:
        print("\n🎉 모든 API 테스트가 성공했습니다!")
        print("403 오류가 해결되었습니다!")
    else:
        print("\n⚠️ 일부 API 테스트가 실패했습니다.")
        print("카카오 개발자 콘솔에서 키 해시와 권한 설정을 다시 확인해주세요.") 