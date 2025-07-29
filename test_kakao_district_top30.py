#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
카카오맵 구별 Top30 음식점 테스트 스크립트
"""
import requests
import json
import time

def test_kakao_district_top30():
    """카카오맵 구별 Top30 음식점 테스트"""
    api_key = "4de2f985cfcf673dc650623230990ccc"  # REST API 키
    base_url = "https://dapi.kakao.com/v2/local"
    
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
    
    print("=== 카카오맵 구별 Top30 음식점 테스트 ===")
    
    for district in test_districts:
        print(f"\n{district} Top30 맛집 검색 중...")
        
        coords = district_coordinates[district]
        
        # 카카오맵 키워드 검색 API 호출
        url = f"{base_url}/search/keyword.json"
        params = {
            "query": f"{district} 맛집",
            "x": str(coords['lng']),
            "y": str(coords['lat']),
            "radius": "5000",
            "size": "30",  # Top30으로 변경
            "category_group_code": "FD6",  # 음식점 카테고리
        }
        
        headers = {
            "Authorization": f"KakaoAK {api_key}",
            "Content-Type": "application/json"
        }
        
        try:
            response = requests.get(url, params=params, headers=headers)
            
            if response.status_code == 200:
                data = response.json()
                
                if data['status'] == 'OK':
                    results = data['documents']
                    
                    # 평점 순으로 정렬 (카카오맵은 평점 정보가 제한적)
                    sorted_results = sorted(results, key=lambda x: x.get('rating', 0), reverse=True)
                    
                    # Top30만 추출
                    top30 = sorted_results[:30]
                    
                    print(f"✅ {district}: {len(top30)}개 음식점 발견")
                    
                    for i, restaurant in enumerate(top30, 1):
                        name = restaurant.get('place_name', 'N/A')
                        address = restaurant.get('address_name', 'N/A')
                        category = restaurant.get('category_name', 'N/A')
                        print(f"  {i}. {name} - {category}")
                        print(f"     주소: {address}")
                        
                else:
                    print(f"❌ {district}: API 오류 - {data['status']}")
                    
            else:
                print(f"❌ {district}: HTTP 오류 - {response.status_code}")
                print(f"응답: {response.text}")
                
        except Exception as e:
            print(f"❌ {district}: 오류 발생 - {e}")
        
        # API 호출 제한을 위해 잠시 대기
        time.sleep(0.2)
    
    print("\n=== 테스트 완료 ===")

if __name__ == "__main__":
    test_kakao_district_top30() 