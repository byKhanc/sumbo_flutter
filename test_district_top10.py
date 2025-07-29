#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
구별 Top10 음식점 테스트 스크립트
"""
import requests
import json
import time

def test_district_top10():
    """구별 Top10 음식점 테스트"""
    api_key = "AIzaSyCmLleqfEJo6TUaER1AQcI6VMpaK66EptA"
    base_url = "https://maps.googleapis.com/maps/api/place"
    
    # 테스트할 구들
    test_districts = [
        "강남구",
        "서초구", 
        "송파구",
        "수원시",
        "성남시"
    ]
    
    # 각 구의 중심 좌표
    district_coordinates = {
        "강남구": {"lat": 37.5172, "lng": 127.0473},
        "서초구": {"lat": 37.4837, "lng": 127.0324},
        "송파구": {"lat": 37.5145, "lng": 127.1059},
        "수원시": {"lat": 37.2636, "lng": 127.0286},
        "성남시": {"lat": 37.4449, "lng": 127.1389},
    }
    
    print("=== 구별 Top10 음식점 테스트 ===")
    
    for district in test_districts:
        print(f"\n{district} Top10 맛집 검색 중...")
        
        coords = district_coordinates[district]
        
        # Google Places Text Search API 호출
        url = f"{base_url}/textsearch/json"
        params = {
            "query": f"{district} 맛집",
            "location": f"{coords['lat']},{coords['lng']}",
            "radius": "5000",
            "type": "restaurant",
            "key": api_key
        }
        
        try:
            response = requests.get(url, params=params)
            
            if response.status_code == 200:
                data = response.json()
                
                if data['status'] == 'OK':
                    results = data['results']
                    
                    # 평점 순으로 정렬
                    sorted_results = sorted(results, key=lambda x: x.get('rating', 0), reverse=True)
                    
                    # Top10만 추출
                    top10 = sorted_results[:10]
                    
                    print(f"✅ {district}: {len(top10)}개 음식점 발견")
                    
                    for i, restaurant in enumerate(top10, 1):
                        name = restaurant.get('name', 'N/A')
                        rating = restaurant.get('rating', 'N/A')
                        address = restaurant.get('formatted_address', 'N/A')
                        print(f"  {i}. {name} (평점: {rating}) - {address}")
                        
                else:
                    print(f"❌ {district}: API 오류 - {data['status']}")
                    
            else:
                print(f"❌ {district}: HTTP 오류 - {response.status_code}")
                
        except Exception as e:
            print(f"❌ {district}: 오류 발생 - {e}")
        
        # API 호출 제한을 위해 잠시 대기
        time.sleep(0.2)
    
    print("\n=== 테스트 완료 ===")

if __name__ == "__main__":
    test_district_top10() 