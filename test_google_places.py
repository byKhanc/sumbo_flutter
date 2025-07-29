#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
구글맵 Places API 테스트
"""

import requests
import json

def test_google_places_api():
    """구글맵 Places API 테스트"""
    
    api_key = "AIzaSyCmLleqfEJo6TUaER1AQcI6VMpaK66EptA"
    
    print("=== 구글맵 Places API 테스트 ===")
    print(f"API 키: {api_key}")
    
    # 서울 강남역 좌표
    latitude = 37.4979
    longitude = 127.0276
    
    # 맛집 검색 테스트
    url = "https://maps.googleapis.com/maps/api/place/textsearch/json"
    params = {
        'query': '강남역 맛집',
        'location': f'{latitude},{longitude}',
        'radius': '5000',
        'type': 'restaurant',
        'key': api_key
    }
    
    try:
        print("\n🔍 맛집 검색 중...")
        response = requests.get(url, params=params)
        
        print(f"응답 상태 코드: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            
            if data['status'] == 'OK':
                print("✅ 구글맵 Places API 테스트 성공!")
                print(f"검색 결과 개수: {len(data.get('results', []))}")
                
                # 첫 번째 결과 출력
                if data.get('results'):
                    first_result = data['results'][0]
                    print(f"\n📍 첫 번째 결과:")
                    print(f"  - 이름: {first_result.get('name', 'N/A')}")
                    print(f"  - 주소: {first_result.get('formatted_address', 'N/A')}")
                    print(f"  - 평점: {first_result.get('rating', 'N/A')}")
                    print(f"  - 리뷰 수: {first_result.get('user_ratings_total', 'N/A')}")
                    print(f"  - Place ID: {first_result.get('place_id', 'N/A')}")
                
                return True
            else:
                print(f"❌ API 오류: {data['status']}")
                if 'error_message' in data:
                    print(f"오류 메시지: {data['error_message']}")
                return False
        else:
            print(f"❌ HTTP 오류: {response.status_code}")
            print(f"응답 내용: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ API 테스트 오류: {e}")
        return False

def test_geocoding_api():
    """구글맵 Geocoding API 테스트"""
    
    api_key = "AIzaSyCmLleqfEJo6TUaER1AQcI6VMpaK66EptA"
    
    print("\n=== 구글맵 Geocoding API 테스트 ===")
    
    url = "https://maps.googleapis.com/maps/api/geocode/json"
    params = {
        'address': '서울 강남구 강남대로',
        'key': api_key
    }
    
    try:
        print("🔍 주소를 좌표로 변환 중...")
        response = requests.get(url, params=params)
        
        print(f"응답 상태 코드: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            
            if data['status'] == 'OK':
                print("✅ Geocoding API 테스트 성공!")
                if data.get('results'):
                    location = data['results'][0]['geometry']['location']
                    print(f"  - 위도: {location['lat']}")
                    print(f"  - 경도: {location['lng']}")
                    print(f"  - 주소: {data['results'][0]['formatted_address']}")
                return True
            else:
                print(f"❌ Geocoding API 오류: {data['status']}")
                return False
        else:
            print(f"❌ HTTP 오류: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Geocoding API 테스트 오류: {e}")
        return False

def test_directions_api():
    """구글맵 Directions API 테스트"""
    
    api_key = "AIzaSyCmLleqfEJo6TUaER1AQcI6VMpaK66EptA"
    
    print("\n=== 구글맵 Directions API 테스트 ===")
    
    url = "https://maps.googleapis.com/maps/api/directions/json"
    params = {
        'origin': '37.4979,127.0276',  # 강남역
        'destination': '37.5665,126.9780',  # 서울시청
        'key': api_key
    }
    
    try:
        print("🔍 경로 안내 계산 중...")
        response = requests.get(url, params=params)
        
        print(f"응답 상태 코드: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            
            if data['status'] == 'OK':
                print("✅ Directions API 테스트 성공!")
                if data.get('routes'):
                    route = data['routes'][0]
                    leg = route['legs'][0]
                    print(f"  - 출발지: {leg['start_address']}")
                    print(f"  - 도착지: {leg['end_address']}")
                    print(f"  - 거리: {leg['distance']['text']}")
                    print(f"  - 소요시간: {leg['duration']['text']}")
                return True
            else:
                print(f"❌ Directions API 오류: {data['status']}")
                return False
        else:
            print(f"❌ HTTP 오류: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Directions API 테스트 오류: {e}")
        return False

if __name__ == "__main__":
    print("🚀 구글맵 API 테스트 시작...\n")
    
    # Places API 테스트
    places_test = test_google_places_api()
    
    # Geocoding API 테스트
    geocoding_test = test_geocoding_api()
    
    # Directions API 테스트
    directions_test = test_directions_api()
    
    print("\n📊 테스트 결과:")
    print(f"Places API: {'✅ 성공' if places_test else '❌ 실패'}")
    print(f"Geocoding API: {'✅ 성공' if geocoding_test else '❌ 실패'}")
    print(f"Directions API: {'✅ 성공' if directions_test else '❌ 실패'}")
    
    if places_test and geocoding_test and directions_test:
        print("\n🎉 모든 구글맵 API 테스트가 성공했습니다!")
        print("✅ 카카오맵 대신 구글맵으로 모든 기능을 구현할 수 있습니다!")
    else:
        print("\n⚠️ 일부 API 테스트가 실패했습니다.")
        print("API 키 설정을 확인해주세요.") 