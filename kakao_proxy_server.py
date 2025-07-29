from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import os

app = Flask(__name__)
CORS(app)  # CORS 허용

# 카카오맵 API 설정
KAKAO_API_KEY = '4de2f985cfcf673dc650623230990ccc'
KAKAO_BASE_URL = 'https://dapi.kakao.com/v2/local'

@app.route('/kakao-api/search', methods=['GET'])
def kakao_search():
    """카카오맵 API 검색 프록시"""
    try:
        # 쿼리 파라미터 가져오기
        query = request.args.get('query', '')
        x = request.args.get('x', '')
        y = request.args.get('y', '')
        radius = request.args.get('radius', '5000')
        size = request.args.get('size', '30')
        category_group_code = request.args.get('category_group_code', 'FD6')
        
        # 카카오맵 API 호출
        url = f'{KAKAO_BASE_URL}/search/keyword.json'
        params = {
            'query': query,
            'x': x,
            'y': y,
            'radius': radius,
            'size': size,
            'category_group_code': category_group_code,
        }
        
        headers = {
            'Authorization': f'KakaoAK {KAKAO_API_KEY}',
            'Content-Type': 'application/json',
        }
        
        print(f'카카오맵 API 호출: {url}')
        print(f'파라미터: {params}')
        
        response = requests.get(url, params=params, headers=headers, timeout=10)
        
        print(f'응답 상태: {response.status_code}')
        
        if response.status_code == 200:
            data = response.json()
            print(f'성공: {len(data.get("documents", []))}개 결과')
            return jsonify(data)
        else:
            print(f'오류: {response.text}')
            return jsonify({
                'status': 'ERROR',
                'message': f'HTTP {response.status_code}: {response.text}'
            }), response.status_code
            
    except Exception as e:
        print(f'프록시 서버 오류: {e}')
        return jsonify({
            'status': 'ERROR',
            'message': str(e)
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    """서버 상태 확인"""
    return jsonify({'status': 'OK', 'message': 'Kakao API Proxy Server is running'})

if __name__ == '__main__':
    print('카카오맵 API 프록시 서버 시작...')
    print(f'API 키: {KAKAO_API_KEY[:10]}...')
    print('서버 주소: http://localhost:5000')
    print('사용법: GET /kakao-api/search?query=강남구 맛집&x=127.0473&y=37.5172')
    
    app.run(host='0.0.0.0', port=5000, debug=True) 