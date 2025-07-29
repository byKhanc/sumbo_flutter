import requests
import json
import time
import pandas as pd
from typing import Dict, List, Optional
from datetime import datetime

class RestaurantDataCollector:
    def __init__(self):
        # API 키들을 여기에 입력하세요
        self.public_api_key = "YOUR_PUBLIC_DATA_API_KEY"
        self.kakao_api_key = "YOUR_KAKAO_API_KEY"
        self.naver_client_id = "YOUR_NAVER_CLIENT_ID"
        self.naver_client_secret = "YOUR_NAVER_CLIENT_SECRET"
        
        # 대상 지역 설정
        self.seoul_districts = [
            "강남구", "서초구", "마포구", "종로구", "중구",
            "용산구", "성동구", "광진구", "동대문구", "중랑구",
            "성북구", "강북구", "도봉구", "노원구", "은평구",
            "서대문구", "양천구", "강서구", "구로구", "금천구",
            "영등포구", "동작구", "관악구"
        ]
        
        self.gyeonggi_districts = [
            "판교", "광교", "분당", "일산", "과천", "안양"
        ]
    
    def collect_public_data(self, region: str, district: str) -> List[Dict]:
        """공공데이터포털에서 식당 정보 수집"""
        restaurants = []
        
        try:
            url = "http://apis.data.go.kr/1130000/FoodHygieneInfoService/getFoodHygieneInfo"
            params = {
                'serviceKey': self.public_api_key,
                'pageNo': '1',
                'numOfRows': '1000',  # 최대 1000개
                'type': 'json',
                'SIGUN_NM': district  # 시군구명
            }
            
            response = requests.get(url, params=params)
            if response.status_code == 200:
                data = response.json()
                items = data.get('body', {}).get('items', [])
                
                for item in items:
                    restaurant = {
                        'id': f"public_{item.get('BIZPLC_NM', '')}_{item.get('LICENSG_DE', '')}",
                        'name': item.get('BIZPLC_NM', ''),
                        'address': item.get('ADDR', ''),
                        'roadAddress': item.get('RDNWHLADDR', ''),
                        'phone': item.get('TELNO', ''),
                        'category': self._categorize_business(item.get('INDUTY_NM', '')),
                        'subCategory': item.get('INDUTY_NM', ''),
                        'region': region,
                        'district': district,
                        'openingHours': item.get('BSN_STATE_NM', ''),
                        'lastUpdated': datetime.now().isoformat(),
                        'tags': [],
                        'description': f"{item.get('INDUTY_NM', '')} 전문점",
                        'mission': f"{item.get('BIZPLC_NM', '')} 방문 인증",
                        'reward': 100,
                        'isOpen': True,
                        'rating': 0.0,
                        'reviewCount': 0,
                        'imageUrls': [],
                        'likeCount': 0,
                        'visitCount': 0,
                        'isRecommended': False
                    }
                    restaurants.append(restaurant)
                
                print(f"✅ {district}에서 {len(restaurants)}개 식당 수집 완료")
            else:
                print(f"❌ 공공데이터 수집 실패: {response.status_code}")
                
        except Exception as e:
            print(f"❌ 공공데이터 수집 오류: {e}")
        
        return restaurants
    
    def enrich_kakao_data(self, restaurants: List[Dict]) -> List[Dict]:
        """카카오맵 API로 상세 정보 보강"""
        enriched_restaurants = []
        
        for restaurant in restaurants:
            try:
                # 카카오맵에서 검색
                url = "https://dapi.kakao.com/v2/local/search/keyword.json"
                headers = {
                    'Authorization': f'KakaoAK {self.kakao_api_key}'
                }
                params = {
                    'query': restaurant['name'],
                    'size': 1
                }
                
                response = requests.get(url, headers=headers, params=params)
                if response.status_code == 200:
                    data = response.json()
                    documents = data.get('documents', [])
                    
                    if documents:
                        doc = documents[0]
                        restaurant.update({
                            'latitude': float(doc.get('y', 0)),
                            'longitude': float(doc.get('x', 0)),
                            'roadAddress': doc.get('road_address_name', restaurant['roadAddress']),
                            'phone': doc.get('phone', restaurant['phone']),
                            'rating': float(doc.get('rating', 0)),
                            'reviewCount': int(doc.get('review_count', 0)),
                            'likeCount': int(doc.get('like_count', 0)),
                            'visitCount': int(doc.get('visit_count', 0)),
                        })
                
                enriched_restaurants.append(restaurant)
                time.sleep(0.1)  # API 호출 제한 방지
                
            except Exception as e:
                print(f"❌ 카카오맵 보강 오류 ({restaurant['name']}): {e}")
                enriched_restaurants.append(restaurant)
        
        print(f"✅ 카카오맵 보강 완료: {len(enriched_restaurants)}개")
        return enriched_restaurants
    
    def enrich_naver_data(self, restaurants: List[Dict]) -> List[Dict]:
        """네이버맵 API로 추가 정보 보강"""
        enriched_restaurants = []
        
        for restaurant in restaurants:
            try:
                # 네이버맵에서 검색
                url = "https://openapi.naver.com/v1/search/local.json"
                headers = {
                    'X-Naver-Client-Id': self.naver_client_id,
                    'X-Naver-Client-Secret': self.naver_client_secret
                }
                params = {
                    'query': restaurant['name'],
                    'display': 1
                }
                
                response = requests.get(url, headers=headers, params=params)
                if response.status_code == 200:
                    data = response.json()
                    items = data.get('items', [])
                    
                    if items:
                        item = items[0]
                        # 네이버 데이터로 보강 (카카오에 없는 정보만)
                        if not restaurant.get('phone'):
                            restaurant['phone'] = item.get('telephone', '')
                        if not restaurant.get('roadAddress'):
                            restaurant['roadAddress'] = item.get('roadAddress', '')
                
                enriched_restaurants.append(restaurant)
                time.sleep(0.1)  # API 호출 제한 방지
                
            except Exception as e:
                print(f"❌ 네이버맵 보강 오류 ({restaurant['name']}): {e}")
                enriched_restaurants.append(restaurant)
        
        print(f"✅ 네이버맵 보강 완료: {len(enriched_restaurants)}개")
        return enriched_restaurants
    
    def _categorize_business(self, business_name: str) -> str:
        """업종명을 카테고리로 분류"""
        business_name = business_name.lower()
        
        if any(keyword in business_name for keyword in ['치킨', '닭', '통닭']):
            return '한식'
        elif any(keyword in business_name for keyword in ['짜장면', '탕수육', '중국']):
            return '중식'
        elif any(keyword in business_name for keyword in ['초밥', '라멘', '일본']):
            return '일식'
        elif any(keyword in business_name for keyword in ['피자', '파스타', '스테이크']):
            return '양식'
        elif any(keyword in business_name for keyword in ['떡볶이', '김밥', '분식']):
            return '분식'
        elif any(keyword in business_name for keyword in ['카페', '커피']):
            return '카페'
        else:
            return '한식'  # 기본값
    
    def collect_all_data(self) -> Dict[str, List[Dict]]:
        """모든 지역의 데이터 수집"""
        all_data = {
            'seoul': [],
            'gyeonggi': []
        }
        
        # 서울 지역 수집
        print("🚀 서울 지역 데이터 수집 시작...")
        for district in self.seoul_districts:
            restaurants = self.collect_public_data('seoul', district)
            restaurants = self.enrich_kakao_data(restaurants)
            restaurants = self.enrich_naver_data(restaurants)
            all_data['seoul'].extend(restaurants)
            time.sleep(1)  # 지역 간 딜레이
        
        # 경기도 지역 수집
        print("🚀 경기도 지역 데이터 수집 시작...")
        for district in self.gyeonggi_districts:
            restaurants = self.collect_public_data('gyeonggi', district)
            restaurants = self.enrich_kakao_data(restaurants)
            restaurants = self.enrich_naver_data(restaurants)
            all_data['gyeonggi'].extend(restaurants)
            time.sleep(1)  # 지역 간 딜레이
        
        return all_data
    
    def save_to_json(self, data: Dict[str, List[Dict]], filename: str):
        """데이터를 JSON 파일로 저장"""
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"✅ 데이터 저장 완료: {filename}")
    
    def save_to_csv(self, data: Dict[str, List[Dict]], filename: str):
        """데이터를 CSV 파일로 저장"""
        all_restaurants = []
        for region, restaurants in data.items():
            for restaurant in restaurants:
                restaurant['region'] = region
                all_restaurants.append(restaurant)
        
        df = pd.DataFrame(all_restaurants)
        df.to_csv(filename, index=False, encoding='utf-8-sig')
        print(f"✅ CSV 저장 완료: {filename}")

def main():
    collector = RestaurantDataCollector()
    
    print("🚀 식당 데이터 수집 시작...")
    data = collector.collect_all_data()
    
    # 결과 출력
    print(f"\n📊 수집 결과:")
    print(f"서울: {len(data['seoul'])}개")
    print(f"경기도: {len(data['gyeonggi'])}개")
    print(f"총계: {len(data['seoul']) + len(data['gyeonggi'])}개")
    
    # 파일 저장
    collector.save_to_json(data, 'restaurants_data.json')
    collector.save_to_csv(data, 'restaurants_data.csv')

if __name__ == "__main__":
    main() 