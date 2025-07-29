# 카카오맵 API IP 제한 문제 해결 가이드

## 문제 상황
카카오맵 API에서 "ip mismatched! callerIp=..." 오류가 발생하는 경우

## 해결 방법

### 1. 카카오 개발자 콘솔에서 IP 등록

1. **카카오 개발자 콘솔 접속**
   - https://developers.kakao.com/console/app 접속
   - 로그인 후 해당 앱 선택

2. **플랫폼 설정**
   - 왼쪽 메뉴에서 "플랫폼" 선택
   - "Web" 플랫폼 추가 (이미 있다면 수정)

3. **사이트 도메인 등록**
   - "사이트 도메인"에 다음 추가:
     ```
     http://localhost:8080
     http://localhost:3000
     http://localhost:5000
     http://127.0.0.1:8080
     http://127.0.0.1:3000
     http://127.0.0.1:5000
     ```

4. **IP 주소 등록**
   - "IP 주소" 필드에 다음 추가:
     ```
     0.0.0.0/0
     127.0.0.1
     localhost
     ```

5. **저장 후 확인**
   - 설정 저장 후 5-10분 대기
   - API 키가 활성화되었는지 확인

### 2. 서비스 활성화 확인

1. **앱 설정 > 동의항목**
   - "위치 정보" 동의항목이 활성화되어 있는지 확인
   - "카카오 로그인" 동의항목도 확인

2. **앱 설정 > 보안**
   - "카카오 로그인 활성화" 체크
   - "REST API 키" 확인

### 3. 대안 방법들

#### A. 프록시 서버 사용
```javascript
// 프록시 서버를 통해 API 호출
const proxyUrl = 'https://your-proxy-server.com/kakao-api';
const response = await fetch(proxyUrl, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    url: 'https://dapi.kakao.com/v2/local/search/keyword.json',
    params: { /* API 파라미터 */ }
  })
});
```

#### B. CORS 프록시 사용
```dart
// Flutter에서 CORS 프록시 사용
final url = Uri.parse('https://cors-anywhere.herokuapp.com/https://dapi.kakao.com/v2/local/search/keyword.json');
```

#### C. 백엔드 서버 구축
```python
# Python Flask 서버 예시
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

@app.route('/kakao-api', methods=['POST'])
def kakao_api_proxy():
    data = request.json
    response = requests.get(
        'https://dapi.kakao.com/v2/local/search/keyword.json',
        params=data['params'],
        headers={'Authorization': f"KakaoAK {data['api_key']}"}
    )
    return jsonify(response.json())
```

### 4. 임시 해결책

API가 작동하지 않는 경우를 위한 임시 해결책:

1. **더미 데이터 사용** (현재 구현됨)
2. **다른 지도 API 사용** (Google Maps, Naver Maps)
3. **정적 데이터 파일 사용**

### 5. 테스트 방법

```bash
# IP 확인
curl ifconfig.me

# 카카오맵 API 테스트
curl -H "Authorization: KakaoAK YOUR_API_KEY" \
     "https://dapi.kakao.com/v2/local/search/keyword.json?query=강남구 맛집"
```

### 6. 주의사항

- IP 등록 후 즉시 반영되지 않을 수 있음 (5-10분 대기)
- 개발 환경과 프로덕션 환경의 IP가 다를 수 있음
- 무료 플랜의 경우 API 호출 제한이 있을 수 있음
- CORS 정책으로 인해 브라우저에서 직접 호출이 제한될 수 있음

## 권장 해결 순서

1. 카카오 개발자 콘솔에서 IP 등록 시도
2. 웹 플랫폼 설정 확인
3. 서비스 활성화 상태 확인
4. 프록시 서버 구축 고려
5. 임시로 더미 데이터 사용 