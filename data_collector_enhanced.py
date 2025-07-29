#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
향상된 맛집 데이터 수집기
공공데이터포털, 카카오맵, 네이버맵 API를 통합하여 맛집 데이터를 수집합니다.
"""

import requests
import json
import time
import pandas as pd
import numpy as np
from datetime import datetime
from typing import Dict, List, Optional, Tuple
import logging

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('data_collection.log', encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class EnhancedDataCollector:
    def __init__(self):
        # API 키 설정 (실제 발급 후 교체)
        self.public_data_api_key = "YOUR_PUBLIC_DATA_API_KEY"
        self.kakao_api_key = "388c45ca23d7b8386311d06c1f752589"
        self.naver_client_id = "YOUR_NAVER_CLIENT_ID"
        self.naver_client_secret = "YOUR_NAVER_CLIENT_SECRET"
        
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

    def collect_public_data(self, region: str, district: str) -> List[Dict]:
        """공공데이터포털에서 식당 데이터 수집"""
        logger.info(f"공공데이터 수집 시작: {region} - {district}")
        
        restaurants = []
        page = 1
        
        while True:
            try:
                url = "http://apis.data.go.kr/B551011/restaurant/list"
                params = {
                    'serviceKey': self.public_data_api_key,
                    'type': 'json',
                    'pageNo': page,
                    'numOfRows': 100,
                    'sido': region,
                    'sigungu': district
                }
                
                response = requests.get(url, params=params, timeout=10)
                response.raise_for_status()
                
                data = response.json()
                
                if 'items' not in data or not data['items']:
                    break
                
                for item in data['items']:
                    restaurant = self._parse_public_data_item(item, region, district)
                    if restaurant:
                        restaurants.append(restaurant)
                
                page += 1
                time.sleep(0.5)  # API 호출 제한 준수
                
            except Exception as e:
                logger.error(f"공공데이터 수집 오류: {e}")
                break
        
        logger.info(f"공공데이터 수집 완료: {len(restaurants)}개")
        return restaurants

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
                time.sleep(0.5)
                
            except Exception as e:
                logger.error(f"카카오맵 수집 오류: {e}")
                break
        
        logger.info(f"카카오맵 수집 완료: {len(restaurants)}개")
        return restaurants

    def collect_naver_data(self, region: str, district: str, category: str) -> List[Dict]:
        """네이버맵 API에서 식당 데이터 수집"""
        logger.info(f"네이버맵 수집 시작: {region} - {district} - {category}")
        
        restaurants = []
        start = 1
        
        while start <= 5:  # 최대 5페이지까지만 수집
            try:
                url = "https://openapi.naver.com/v1/search/local.json"
                headers = {
                    'X-Naver-Client-Id': self.naver_client_id,
                    'X-Naver-Client-Secret': self.naver_client_secret
                }
                params = {
                    'query': f"{district} {category}",
                    'display': 10,
                    'start': start
                }
                
                response = requests.get(url, headers=headers, params=params, timeout=10)
                response.raise_for_status()
                
                data = response.json()
                
                if 'items' not in data or not data['items']:
                    break
                
                for item in data['items']:
                    restaurant = self._parse_naver_item(item, region, district, category)
                    if restaurant:
                        restaurants.append(restaurant)
                
                start += 10
                time.sleep(0.5)
                
            except Exception as e:
                logger.error(f"네이버맵 수집 오류: {e}")
                break
        
        logger.info(f"네이버맵 수집 완료: {len(restaurants)}개")
        return restaurants

    def _parse_public_data_item(self, item: Dict, region: str, district: str) -> Optional[Dict]:
        """공공데이터 아이템 파싱"""
        try:
            return {
                'id': f"public_{item.get('bizplc_nm', '').replace(' ', '_')}_{int(time.time())}",
                'name': item.get('bizplc_nm', ''),
                'latitude': float(item.get('refine_wgs84_lat', 0)),
                'longitude': float(item.get('refine_wgs84_logt', 0)),
                'address': item.get('refine_roadnm_addr', ''),
                'roadAddress': item.get('refine_roadnm_addr', ''),
                'category': self._classify_category(item.get('sanittn_bizplc_nm', '')),
                'subCategory': item.get('sanittn_bizplc_nm', ''),
                'phone': item.get('telno', ''),
                'rating': 0.0,
                'reviewCount': 0,
                'openingHours': '',
                'region': region,
                'district': district,
                'tags': [],
                'description': f"{item.get('bizplc_nm', '')} - {item.get('sanittn_bizplc_nm', '')}",
                'mission': f"{item.get('bizplc_nm', '')} 방문 인증",
                'reward': 100,
                'isOpen': True,
                'lastUpdated': datetime.now().isoformat(),
                'imageUrls': [],
                'likeCount': 0,
                'visitCount': 0,
                'isRecommended': False,
                'source': 'public_data'
            }
        except Exception as e:
            logger.error(f"공공데이터 파싱 오류: {e}")
            return None

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

    def _parse_naver_item(self, item: Dict, region: str, district: str, category: str) -> Optional[Dict]:
        """네이버맵 아이템 파싱"""
        try:
            return {
                'id': f"naver_{item.get('title', '').replace(' ', '_')}_{int(time.time())}",
                'name': item.get('title', '').replace('<b>', '').replace('</b>', ''),
                'latitude': 0.0,  # 네이버는 좌표 정보가 없음
                'longitude': 0.0,
                'address': item.get('address', ''),
                'roadAddress': item.get('roadAddress', ''),
                'category': category,
                'subCategory': '',
                'phone': item.get('telephone', ''),
                'rating': 0.0,
                'reviewCount': 0,
                'openingHours': '',
                'region': region,
                'district': district,
                'tags': [],
                'description': f"{item.get('title', '')} - {item.get('category', '')}",
                'mission': f"{item.get('title', '')} 방문 인증",
                'reward': 100,
                'isOpen': True,
                'lastUpdated': datetime.now().isoformat(),
                'imageUrls': [],
                'likeCount': 0,
                'visitCount': 0,
                'isRecommended': False,
                'source': 'naver'
            }
        except Exception as e:
            logger.error(f"네이버맵 파싱 오류: {e}")
            return None

    def _classify_category(self, business_name: str) -> str:
        """업종명을 기반으로 카테고리 분류"""
        business_name = business_name.lower()
        
        for category, keywords in self.category_mapping.items():
            for keyword in keywords:
                if keyword in business_name:
                    return category
        
        return '기타'

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
        logger.info("전체 데이터 수집 시작")
        
        for region_key, region_info in self.regions.items():
            logger.info(f"{region_info['name']} 데이터 수집 시작")
            
            for district in region_info['districts']:
                logger.info(f"  {district} 수집 중...")
                
                # 공공데이터 수집
                public_restaurants = self.collect_public_data(region_info['name'], district)
                
                # 카테고리별 카카오맵 데이터 수집
                kakao_restaurants = []
                
                for category in self.category_mapping.keys():
                    kakao_restaurants.extend(self.collect_kakao_data(region_key, district, category))
                
                # 모든 데이터 합치기 (공공데이터 + 카카오맵)
                all_restaurants = public_restaurants + kakao_restaurants
                
                # 중복 제거
                unique_restaurants = self._deduplicate_restaurants(all_restaurants)
                
                # 데이터 보강
                enriched_restaurants = [self._enrich_restaurant_data(r) for r in unique_restaurants]
                
                # 지역별 데이터에 추가
                self.collected_data[region_key].extend(enriched_restaurants)
                
                logger.info(f"  {district} 완료: {len(enriched_restaurants)}개")
                time.sleep(1)  # 지역 간 딜레이
        
        logger.info("전체 데이터 수집 완료")

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
            logger.info("향상된 데이터 수집기 시작")
            
            # API 키 확인 (공공데이터는 선택사항, 카카오맵만 필수)
            if self.kakao_api_key == "YOUR_KAKAO_API_KEY":
                logger.error("카카오맵 API 키를 설정해주세요!")
                return
            
            # 데이터 수집
            self.collect_all_data()
            
            # 데이터 저장
            self.save_data()
            
            logger.info("데이터 수집 완료!")
            
        except Exception as e:
            logger.error(f"데이터 수집 중 오류 발생: {e}")

if __name__ == "__main__":
    collector = EnhancedDataCollector()
    collector.run() 