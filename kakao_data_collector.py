#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
카카오맵 전용 맛집 데이터 수집기
카카오맵 API를 사용하여 서울/경기도 맛집 데이터를 수집합니다.
"""

import requests
import json
import time
import pandas as pd
import numpy as np
from datetime import datetime
from typing import Dict, List, Optional
import logging

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('kakao_data_collection.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class KakaoDataCollector:
    def __init__(self):
        # 카카오맵 API 키
        self.kakao_api_key = "4de2f985cfcf673dc650623230990ccc"
        
        # 지역 설정
        self.regions = {
            'seoul': {
                'name': '서울',
                'districts': ['강남구', '서초구', '마포구', '홍대', '이태원', '명동', '동대문', '종로구', '용산구', '성동구', '광진구', '중구', '중랑구', '노원구', '도봉구', '강북구', '성북구', '강서구', '양천구', '영등포구', '구로구', '금천구', '동작구', '관악구', '서대문구', '은평구']
            },
            'gyeonggi': {
                'name': '경기도',
                'districts': ['분당구', '광교', '판교', '일산', '과천', '안양', '수원', '성남', '용인', '고양', '의정부', '남양주', '하남', '광주', '여주', '이천', '안성', '평택', '오산', '화성', '시흥', '부천', '광명', '군포', '의왕', '안산', '양평', '가평', '연천', '포천', '동두천', '구리']
            }
        }
        
        # 카테고리 매핑
        self.category_mapping = {
            '한식': ['한식', '한정식', '백반', '국밥', '국수', '찌개', '구이', '회'],
            '중식': ['중식', '중국요리', '딤섬', '마라탕', '훠궈'],
            '일식': ['일식', '스시', '라멘', '우동', '덮밥', '돈부리'],
            '양식': ['양식', '파스타', '피자', '스테이크', '샌드위치'],
            '분식': ['분식', '떡볶이', '김밥', '라면', '순대'],
            '카페': ['카페', '커피', '디저트', '베이커리'],
            '디저트': ['디저트', '아이스크림', '케이크', '마카롱', '크로플']
        }
        
        # 수집된 데이터
        self.collected_data = {
            'seoul': [],
            'gyeonggi': []
        }

    def collect_kakao_data(self, region: str, district: str, category: str) -> List[Dict]:
        """카카오맵 API에서 식당 데이터 수집"""
        logger.info(f"카카오맵 수집 시작: {region} - {district} - {category}")
        
        restaurants = []
        page = 1
        
        while page <= 3:  # 최대 3페이지까지만 수집
            try:
                url = "https://dapi.kakao.com/v2/local/search/keyword.json"
                headers = {
                    'Authorization': f'KakaoAK {self.kakao_api_key}'
                }
                params = {
                    'query': f"{district} {category}",
                    'page': page,
                    'size': 15
                }
                
                response = requests.get(url, headers=headers, params=params, timeout=10)
                response.raise_for_status()
                
                data = response.json()
                
                if 'documents' not in data or not data['documents']:
                    break
                
                for item in data['documents']:
                    restaurant = self._parse_kakao_item(item, region, district, category)
                    if restaurant:
                        restaurants.append(restaurant)
                
                page += 1
                time.sleep(0.5)  # API 호출 제한 준수
                
            except Exception as e:
                logger.error(f"카카오맵 수집 오류: {e}")
                break
        
        logger.info(f"카카오맵 수집 완료: {len(restaurants)}개")
        return restaurants

    def _parse_kakao_item(self, item: Dict, region: str, district: str, category: str) -> Optional[Dict]:
        """카카오맵 아이템 파싱"""
        try:
            return {
                'id': f"kakao_{item.get('id', '')}",
                'name': item.get('place_name', ''),
                'latitude': float(item.get('y', 0)),
                'longitude': float(item.get('x', 0)),
                'address': item.get('address_name', ''),
                'roadAddress': item.get('road_address_name', ''),
                'category': category,
                'subCategory': item.get('category_name', ''),
                'phone': item.get('phone', ''),
                'rating': 0.0,
                'reviewCount': 0,
                'openingHours': '',
                'region': region,
                'district': district,
                'tags': [],
                'description': f"{item.get('place_name', '')} - {item.get('category_name', '')}",
                'mission': f"{item.get('place_name', '')} 방문 인증",
                'reward': 100,
                'isOpen': True,
                'lastUpdated': datetime.now().isoformat(),
                'imageUrls': [],
                'likeCount': 0,
                'visitCount': 0,
                'isRecommended': False,
                'source': 'kakao'
            }
        except Exception as e:
            logger.error(f"카카오맵 파싱 오류: {e}")
            return None

    def _deduplicate_restaurants(self, restaurants: List[Dict]) -> List[Dict]:
        """중복 제거 (이름과 주소 기준)"""
        seen = set()
        unique_restaurants = []
        
        for restaurant in restaurants:
            key = f"{restaurant['name']}_{restaurant['address']}"
            if key not in seen:
                seen.add(key)
                unique_restaurants.append(restaurant)
        
        return unique_restaurants

    def _enrich_restaurant_data(self, restaurant: Dict) -> Dict:
        """식당 데이터 보강"""
        # 평점 랜덤 생성 (3.0 ~ 5.0)
        restaurant['rating'] = round(np.random.uniform(3.0, 5.0), 1)
        
        # 리뷰 수 랜덤 생성 (0 ~ 500)
        restaurant['reviewCount'] = np.random.randint(0, 500)
        
        # 좋아요 수 랜덤 생성 (0 ~ 100)
        restaurant['likeCount'] = np.random.randint(0, 100)
        
        # 방문 수 랜덤 생성 (0 ~ 1000)
        restaurant['visitCount'] = np.random.randint(0, 1000)
        
        # 추천 여부 (평점 4.0 이상이면 추천)
        restaurant['isRecommended'] = restaurant['rating'] >= 4.0
        
        # 태그 생성
        tags = []
        if restaurant['rating'] >= 4.5:
            tags.append('인기')
        if restaurant['visitCount'] > 500:
            tags.append('많이 찾는')
        if restaurant['category'] in ['한식', '중식', '일식']:
            tags.append('전통')
        if restaurant['category'] == '카페':
            tags.append('분위기 좋은')
        
        restaurant['tags'] = tags
        
        return restaurant

    def collect_all_data(self):
        """모든 데이터 수집"""
        logger.info("카카오맵 데이터 수집 시작")
        
        for region_key, region_info in self.regions.items():
            logger.info(f"{region_info['name']} 데이터 수집 시작")
            
            for district in region_info['districts']:
                logger.info(f"  {district} 수집 중...")
                
                # 카테고리별 카카오맵 데이터 수집
                all_restaurants = []
                
                for category in self.category_mapping.keys():
                    restaurants = self.collect_kakao_data(region_key, district, category)
                    all_restaurants.extend(restaurants)
                
                # 중복 제거
                unique_restaurants = self._deduplicate_restaurants(all_restaurants)
                
                # 데이터 보강
                enriched_restaurants = [self._enrich_restaurant_data(r) for r in unique_restaurants]
                
                # 지역별 데이터에 추가
                self.collected_data[region_key].extend(enriched_restaurants)
                
                logger.info(f"  {district} 완료: {len(enriched_restaurants)}개")
                time.sleep(1)  # 지역 간 딜레이
        
        logger.info("카카오맵 데이터 수집 완료")

    def save_data(self):
        """데이터 저장"""
        logger.info("데이터 저장 시작")
        
        # JSON 형식으로 저장
        with open('assets/restaurants_data.json', 'w', encoding='utf-8') as f:
            json.dump(self.collected_data, f, ensure_ascii=False, indent=2)
        
        # CSV 형식으로도 저장
        all_restaurants = []
        for region, restaurants in self.collected_data.items():
            for restaurant in restaurants:
                restaurant['region'] = region
                all_restaurants.append(restaurant)
        
        df = pd.DataFrame(all_restaurants)
        df.to_csv('assets/restaurants_data.csv', index=False, encoding='utf-8-sig')
        
        # 통계 정보
        stats = {
            'total_restaurants': len(all_restaurants),
            'seoul_count': len(self.collected_data['seoul']),
            'gyeonggi_count': len(self.collected_data['gyeonggi']),
            'categories': df['category'].value_counts().to_dict(),
            'sources': df['source'].value_counts().to_dict(),
            'collection_time': datetime.now().isoformat()
        }
        
        with open('assets/collection_stats.json', 'w', encoding='utf-8') as f:
            json.dump(stats, f, ensure_ascii=False, indent=2)
        
        logger.info(f"데이터 저장 완료: 총 {len(all_restaurants)}개")

    def run(self):
        """전체 프로세스 실행"""
        try:
            logger.info("카카오맵 데이터 수집기 시작")
            
            # 데이터 수집
            self.collect_all_data()
            
            # 데이터 저장
            self.save_data()
            
            logger.info("카카오맵 데이터 수집 완료!")
            
        except Exception as e:
            logger.error(f"데이터 수집 중 오류 발생: {e}")

if __name__ == "__main__":
    collector = KakaoDataCollector()
    collector.run() 