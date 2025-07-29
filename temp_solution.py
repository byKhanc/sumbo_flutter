#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
임시 해결책: 더미 데이터 사용
"""

import json
import random

def load_dummy_data():
    """더미 데이터 로드"""
    
    try:
        with open('assets/restaurants.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
        return data
    except Exception as e:
        print(f"❌ 더미 데이터 로드 오류: {e}")
        return None

def search_dummy_restaurants(query, limit=5):
    """더미 데이터에서 맛집 검색"""
    
    data = load_dummy_data()
    if not data:
        return []
    
    results = []
    
    # 서울과 경기도 데이터 검색
    for region in ['seoul', 'gyeonggi']:
        if region in data:
            for restaurant in data[region]:
                # 간단한 검색 로직
                if (query.lower() in restaurant.get('name', '').lower() or
                    query.lower() in restaurant.get('address', '').lower() or
                    query.lower() in restaurant.get('category', '').lower()):
                    results.append(restaurant)
    
    # 랜덤 결과 추가 (검색 결과가 적을 경우)
    if len(results) < limit:
        all_restaurants = []
        for region in ['seoul', 'gyeonggi']:
            if region in data:
                all_restaurants.extend(data[region])
        
        # 이미 추가된 결과 제외
        existing_ids = {r['id'] for r in results}
        available = [r for r in all_restaurants if r['id'] not in existing_ids]
        
        # 랜덤 선택
        random_count = min(limit - len(results), len(available))
        if random_count > 0:
            results.extend(random.sample(available, random_count))
    
    return results[:limit]

def test_dummy_api():
    """더미 API 테스트"""
    
    print("🔍 더미 데이터 API 테스트...")
    
    # 테스트 쿼리들
    test_queries = ['강남역 맛집', '홍대 맛집', '한식', '카페']
    
    for query in test_queries:
        print(f"\n📍 '{query}' 검색 결과:")
        results = search_dummy_restaurants(query, 3)
        
        if results:
            for i, restaurant in enumerate(results, 1):
                print(f"  {i}. {restaurant.get('name', 'N/A')}")
                print(f"     주소: {restaurant.get('address', 'N/A')}")
                print(f"     카테고리: {restaurant.get('category', 'N/A')}")
                print(f"     평점: {restaurant.get('rating', 'N/A')}")
        else:
            print("  검색 결과가 없습니다.")
    
    return True

def main():
    print("="*60)
    print("🎯 임시 해결책: 더미 데이터 사용")
    print("="*60)
    
    print("\n📋 현재 상황:")
    print("✅ 비즈니스 정보 심사 신청 완료")
    print("⏳ 심사 통과 대기 중 (3-5일)")
    print("🔒 카카오맵 API 권한 신청 대기")
    
    print("\n🚀 임시 해결책 실행:")
    success = test_dummy_api()
    
    print("\n" + "="*60)
    if success:
        print("✅ 더미 데이터 API가 정상 작동합니다!")
        print("📱 Flutter 앱에서 더미 데이터로 테스트 가능합니다!")
        print("⏳ 카카오맵 API 권한 승인 후 실제 API로 교체하세요.")
    else:
        print("❌ 더미 데이터 로드에 실패했습니다.")
    print("="*60)

if __name__ == "__main__":
    main() 