#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
더미 맛집 데이터 생성기
API 키 문제를 해결하는 동안 사용할 더미 데이터를 생성합니다.
"""

import json
import random
import numpy as np
from datetime import datetime
from typing import Dict, List

class DummyDataGenerator:
    def __init__(self):
        # 더미 식당 이름들
        self.restaurant_names = [
            "맛있는 한식당", "정통 중식당", "일본 스시바", "이탈리안 레스토랑", "분식집", "카페 모닝", "디저트 하우스",
            "강남 맛집", "서초 한식", "마포 술집", "홍대 카페", "이태원 레스토랑", "명동 중국집", "동대문 분식",
            "종로 전통집", "용산 스테이크", "성동 카페", "광진 맛집", "중구 한식", "중랑 분식", "노원 카페",
            "도봉 중국집", "강북 일본집", "성북 이탈리안", "강서 한식", "양천 분식", "영등포 카페", "구로 맛집",
            "금천 중국집", "동작 일본집", "관악 이탈리안", "서대문 한식", "은평 분식"
        ]
        
        # 카테고리별 이름 접미사
        self.category_suffixes = {
            '한식': ['한식당', '백반집', '국밥집', '찌개집', '구이집', '회집'],
            '중식': ['중국집', '중식당', '딤섬집', '마라탕집', '훠궈집'],
            '일식': ['스시바', '라멘집', '우동집', '일식당', '덮밥집'],
            '양식': ['이탈리안', '스테이크하우스', '피자집', '파스타집', '양식당'],
            '분식': ['분식집', '떡볶이집', '김밥집', '라면집', '순대집'],
            '카페': ['카페', '커피숍', '베이커리', '디저트카페', '브런치카페'],
            '디저트': ['디저트하우스', '아이스크림집', '케이크집', '마카롱집', '크로플집']
        }
        
        # 지역별 좌표 범위
        self.region_coordinates = {
            'seoul': {
                'lat_range': (37.4133, 37.7151),
                'lng_range': (126.7341, 127.2693)
            },
            'gyeonggi': {
                'lat_range': (37.0, 38.0),
                'lng_range': (126.5, 127.5)
            }
        }
        
        # 구/시별 좌표
        self.district_coordinates = {
            '강남구': (37.5172, 127.0473),
            '서초구': (37.4837, 127.0324),
            '마포구': (37.5637, 126.9084),
            '홍대': (37.5571, 126.9234),
            '이태원': (37.5344, 126.9941),
            '명동': (37.5636, 126.9834),
            '동대문': (37.5665, 127.0090),
            '종로구': (37.5735, 126.9788),
            '용산구': (37.5320, 126.9904),
            '성동구': (37.5506, 127.0409),
            '광진구': (37.5384, 127.0822),
            '중구': (37.5640, 126.9979),
            '중랑구': (37.6060, 127.0926),
            '노원구': (37.6542, 127.0568),
            '도봉구': (37.6688, 127.0471),
            '강북구': (37.6396, 127.0257),
            '성북구': (37.5894, 127.0167),
            '강서구': (37.5509, 126.8495),
            '양천구': (37.5270, 126.8565),
            '영등포구': (37.5264, 126.8890),
            '구로구': (37.4954, 126.8874),
            '금천구': (37.4600, 126.9012),
            '동작구': (37.5124, 126.9393),
            '관악구': (37.4784, 126.9516),
            '서대문구': (37.5791, 126.9368),
            '은평구': (37.6027, 126.9291),
            '분당구': (37.3519, 127.1086),
            '광교': (37.2998, 127.0471),
            '판교': (37.4015, 127.1084),
            '일산': (37.6584, 126.7698),
            '과천': (37.4290, 126.9877),
            '안양': (37.3942, 126.9568),
            '수원': (37.2636, 127.0286),
            '성남': (37.4449, 127.1389),
            '용인': (37.2411, 127.1776),
            '고양': (37.6584, 126.7698),
            '의정부': (37.7381, 127.0337),
            '남양주': (37.6363, 127.2162),
            '하남': (37.5392, 127.2148),
            '광주': (37.4295, 127.2550),
            '여주': (37.2984, 127.6370),
            '이천': (37.2720, 127.4350),
            '안성': (37.0080, 127.2797),
            '평택': (36.9920, 127.1127),
            '오산': (37.1498, 127.0772),
            '화성': (37.1995, 126.8311),
            '시흥': (37.3799, 126.8030),
            '부천': (37.5035, 126.7660),
            '광명': (37.4795, 126.8646),
            '군포': (37.3616, 126.9352),
            '의왕': (37.3446, 126.9683),
            '안산': (37.3219, 126.8309),
            '양평': (37.4914, 127.4874),
            '가평': (37.8315, 127.5105),
            '연천': (38.0966, 127.0747),
            '포천': (37.8949, 127.2002),
            '동두천': (37.9031, 127.0606),
            '구리': (37.5944, 127.1296)
        }

    def generate_restaurant(self, region: str, district: str, category: str, index: int) -> Dict:
        """개별 식당 데이터 생성"""
        # 기본 좌표 (구/시별 좌표 사용)
        base_lat, base_lng = self.district_coordinates.get(district, (37.5665, 126.9780))
        
        # 좌표에 약간의 랜덤성 추가 (±0.01도)
        lat = base_lat + random.uniform(-0.01, 0.01)
        lng = base_lng + random.uniform(-0.01, 0.01)
        
        # 식당 이름 생성
        base_name = random.choice(self.restaurant_names)
        suffix = random.choice(self.category_suffixes[category])
        name = f"{base_name} {suffix}"
        
        # 주소 생성
        address = f"서울 {district} {random.randint(1, 999)}-{random.randint(1, 999)}"
        road_address = f"서울특별시 {district} {random.choice(['강남대로', '테헤란로', '가로수길', '압구정로', '신사동길'])} {random.randint(1, 999)}"
        
        # 평점 및 리뷰 수
        rating = round(random.uniform(3.0, 5.0), 1)
        review_count = random.randint(0, 500)
        like_count = random.randint(0, 100)
        visit_count = random.randint(0, 1000)
        
        # 태그 생성
        tags = []
        if rating >= 4.5:
            tags.append('인기')
        if visit_count > 500:
            tags.append('많이 찾는')
        if category in ['한식', '중식', '일식']:
            tags.append('전통')
        if category == '카페':
            tags.append('분위기 좋은')
        if rating >= 4.8:
            tags.append('추천')
        
        return {
            'id': f"dummy_{region}_{district}_{category}_{index}",
            'name': name,
            'latitude': lat,
            'longitude': lng,
            'address': address,
            'roadAddress': road_address,
            'category': category,
            'subCategory': f"{category} 전문점",
            'phone': f"02-{random.randint(1000, 9999)}-{random.randint(1000, 9999)}",
            'rating': rating,
            'reviewCount': review_count,
            'openingHours': f"{random.randint(6, 10)}:00-{random.randint(20, 24)}:00",
            'region': region,
            'district': district,
            'tags': tags,
            'description': f"{name} - {category} 전문점입니다.",
            'mission': f"{name} 방문 인증",
            'reward': random.choice([100, 120, 150, 200]),
            'isOpen': random.choice([True, True, True, False]),  # 75% 확률로 영업중
            'lastUpdated': datetime.now().isoformat(),
            'imageUrls': [],
            'likeCount': like_count,
            'visitCount': visit_count,
            'isRecommended': rating >= 4.0,
            'source': 'dummy'
        }

    def generate_data(self):
        """전체 더미 데이터 생성"""
        print("더미 데이터 생성 시작...")
        
        collected_data = {
            'seoul': [],
            'gyeonggi': []
        }
        
        categories = ['한식', '중식', '일식', '양식', '분식', '카페', '디저트']
        
        # 서울 데이터 생성 (각 구별로 5-10개씩)
        seoul_districts = ['강남구', '서초구', '마포구', '홍대', '이태원', '명동', '동대문', '종로구', '용산구', '성동구', '광진구', '중구', '중랑구', '노원구', '도봉구', '강북구', '성북구', '강서구', '양천구', '영등포구', '구로구', '금천구', '동작구', '관악구', '서대문구', '은평구']
        
        for district in seoul_districts:
            for category in categories:
                count = random.randint(3, 8)  # 각 카테고리별 3-8개
                for i in range(count):
                    restaurant = self.generate_restaurant('seoul', district, category, i)
                    collected_data['seoul'].append(restaurant)
        
        # 경기도 데이터 생성 (각 시별로 3-6개씩)
        gyeonggi_districts = ['분당구', '광교', '판교', '일산', '과천', '안양', '수원', '성남', '용인', '고양', '의정부', '남양주', '하남', '광주', '여주', '이천', '안성', '평택', '오산', '화성', '시흥', '부천', '광명', '군포', '의왕', '안산', '양평', '가평', '연천', '포천', '동두천', '구리']
        
        for district in gyeonggi_districts:
            for category in categories:
                count = random.randint(2, 5)  # 각 카테고리별 2-5개
                for i in range(count):
                    restaurant = self.generate_restaurant('gyeonggi', district, category, i)
                    collected_data['gyeonggi'].append(restaurant)
        
        print(f"데이터 생성 완료: 서울 {len(collected_data['seoul'])}개, 경기도 {len(collected_data['gyeonggi'])}개")
        return collected_data

    def save_data(self, data: Dict):
        """데이터 저장"""
        print("데이터 저장 시작...")
        
        # JSON 형식으로 저장
        with open('assets/restaurants_data.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        # 통계 정보
        total_count = len(data['seoul']) + len(data['gyeonggi'])
        stats = {
            'total_restaurants': total_count,
            'seoul_count': len(data['seoul']),
            'gyeonggi_count': len(data['gyeonggi']),
            'generation_time': datetime.now().isoformat(),
            'source': 'dummy_data'
        }
        
        with open('assets/collection_stats.json', 'w', encoding='utf-8') as f:
            json.dump(stats, f, ensure_ascii=False, indent=2)
        
        print(f"데이터 저장 완료: 총 {total_count}개")

    def run(self):
        """전체 프로세스 실행"""
        try:
            print("더미 데이터 생성기 시작")
            
            # 데이터 생성
            data = self.generate_data()
            
            # 데이터 저장
            self.save_data(data)
            
            print("더미 데이터 생성 완료!")
            
        except Exception as e:
            print(f"데이터 생성 중 오류 발생: {e}")

if __name__ == "__main__":
    generator = DummyDataGenerator()
    generator.run() 