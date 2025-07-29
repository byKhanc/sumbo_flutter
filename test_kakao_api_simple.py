import requests
import json

def test_kakao_api():
    api_key = '4de2f985cfcf673dc650623230990ccc'
    base_url = 'https://dapi.kakao.com/v2/local'
    
    # 강남구 맛집 검색 테스트
    url = f'{base_url}/search/keyword.json'
    params = {
        'query': '강남구 맛집',
        'x': '127.0473',
        'y': '37.5172',
        'radius': '5000',
        'size': '5',
        'category_group_code': 'FD6',
    }
    
    headers = {
        'Authorization': f'KakaoAK {api_key}',
        'Content-Type': 'application/json',
    }
    
    try:
        print('카카오맵 API 테스트 시작...')
        response = requests.get(url, params=params, headers=headers)
        
        print(f'HTTP 상태 코드: {response.status_code}')
        print(f'응답 헤더: {dict(response.headers)}')
        
        if response.status_code == 200:
            data = response.json()
            print(f'응답 데이터: {json.dumps(data, indent=2, ensure_ascii=False)}')
            
            if 'documents' in data:
                print(f'검색된 음식점 개수: {len(data["documents"])}')
                for i, place in enumerate(data['documents'][:3]):
                    print(f'{i+1}. {place.get("place_name", "N/A")} - {place.get("address_name", "N/A")}')
            else:
                print('documents 필드가 없습니다.')
        else:
            print(f'오류 응답: {response.text}')
            
    except Exception as e:
        print(f'API 호출 오류: {e}')

if __name__ == '__main__':
    test_kakao_api() 