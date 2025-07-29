import requests
import json
from typing import Dict, List, Optional

class APITester:
    def __init__(self):
        # API 키들을 여기에 입력하세요
        self.public_api_key = "YOUR_PUBLIC_DATA_API_KEY"
        self.kakao_api_key = "YOUR_KAKAO_API_KEY"
        self.naver_client_id = "YOUR_NAVER_CLIENT_ID"
        self.naver_client_secret = "YOUR_NAVER_CLIENT_SECRET"
    
    def test_public_data_api(self) -> bool:
        """공공데이터포털 API 테스트"""
        try:
            url = "http://apis.data.go.kr/1130000/FoodHygieneInfoService/getFoodHygieneInfo"
            params = {
                'serviceKey': self.public_api_key,
                'pageNo': '1',
                'numOfRows': '10',
                'type': 'json'
            }
            
            response = requests.get(url, params=params)
            if response.status_code == 200:
                data = response.json()
                print("✅ 공공데이터포털 API 테스트 성공")
                print(f"데이터 개수: {len(data.get('body', {}).get('items', []))}")
                return True
            else:
                print(f"❌ 공공데이터포털 API 테스트 실패: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ 공공데이터포털 API 테스트 오류: {e}")
            return False
    
    def test_kakao_api(self) -> bool:
        """카카오맵 API 테스트"""
        try:
            url = "https://dapi.kakao.com/v2/local/search/keyword.json"
            headers = {
                'Authorization': f'KakaoAK {self.kakao_api_key}'
            }
            params = {
                'query': '강남역 맛집',
                'size': 5
            }
            
            response = requests.get(url, headers=headers, params=params)
            if response.status_code == 200:
                data = response.json()
                print("✅ 카카오맵 API 테스트 성공")
                print(f"검색 결과 개수: {len(data.get('documents', []))}")
                return True
            else:
                print(f"❌ 카카오맵 API 테스트 실패: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ 카카오맵 API 테스트 오류: {e}")
            return False
    
    def test_naver_api(self) -> bool:
        """네이버맵 API 테스트"""
        try:
            url = "https://openapi.naver.com/v1/search/local.json"
            headers = {
                'X-Naver-Client-Id': self.naver_client_id,
                'X-Naver-Client-Secret': self.naver_client_secret
            }
            params = {
                'query': '강남역 맛집',
                'display': 5
            }
            
            response = requests.get(url, headers=headers, params=params)
            if response.status_code == 200:
                data = response.json()
                print("✅ 네이버맵 API 테스트 성공")
                print(f"검색 결과 개수: {len(data.get('items', []))}")
                return True
            else:
                print(f"❌ 네이버맵 API 테스트 실패: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ 네이버맵 API 테스트 오류: {e}")
            return False
    
    def run_all_tests(self):
        """모든 API 테스트 실행"""
        print("🚀 API 키 테스트 시작...\n")
        
        results = {
            'public_data': self.test_public_data_api(),
            'kakao': self.test_kakao_api(),
            'naver': self.test_naver_api()
        }
        
        print("\n📊 테스트 결과:")
        for api_name, result in results.items():
            status = "✅ 성공" if result else "❌ 실패"
            print(f"{api_name}: {status}")
        
        return results

if __name__ == "__main__":
    tester = APITester()
    tester.run_all_tests() 