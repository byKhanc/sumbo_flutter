# API 키 발급 가이드

## 1. 공공데이터포털 API 키 발급

### 1-1. 회원가입 및 로그인
- **URL:** https://www.data.go.kr/
- **회원가입** → **로그인**

### 1-2. 식품위생업소 정보 API 신청
1. **검색창에 "식품위생업소 정보" 검색**
2. **API 신청** 클릭
3. **승인 대기** (보통 1-2일 소요)

### 1-3. API 키 확인
1. **마이페이지** → **API 키 관리**
2. **인증키 복사**

---

## 2. 카카오맵 API 키 발급

### 2-1. 카카오 개발자 계정 생성
- **URL:** https://developers.kakao.com/
- **회원가입** → **로그인**

### 2-2. 애플리케이션 등록
1. **내 애플리케이션** → **애플리케이션 추가**
2. **앱 이름:** "Sumbo"
3. **사업자명:** 개인 또는 회사명

### 2-3. REST API 키 확인
- **앱 키** → **REST API 키 복사**

---

## 3. 네이버맵 API 키 발급

### 3-1. 네이버 클라우드 플랫폼 가입
- **URL:** https://www.ncloud.com/
- **회원가입** → **로그인**

### 3-2. 애플리케이션 등록
1. **AI·NAVER API** → **Maps**
2. **애플리케이션 등록**
3. **서비스 환경:** Web 서비스
4. **등록 도메인:** localhost (개발용)

### 3-3. API 키 확인
- **인증 정보** → **Client ID, Client Secret 복사**

---

## 4. API 키 테스트

### 4-1. Python 환경 설정
```bash
pip install -r requirements.txt
```

### 4-2. API 키 입력
`api_test.py` 파일에서 API 키들을 입력:
```python
self.public_api_key = "YOUR_PUBLIC_DATA_API_KEY"
self.kakao_api_key = "YOUR_KAKAO_API_KEY"
self.naver_client_id = "YOUR_NAVER_CLIENT_ID"
self.naver_client_secret = "YOUR_NAVER_CLIENT_SECRET"
```

### 4-3. 테스트 실행
```bash
python api_test.py
```

---

## 5. 예상 결과

### 성공 시:
```
🚀 API 키 테스트 시작...

✅ 공공데이터포털 API 테스트 성공
데이터 개수: 10
✅ 카카오맵 API 테스트 성공
검색 결과 개수: 5
✅ 네이버맵 API 테스트 성공
검색 결과 개수: 5

📊 테스트 결과:
public_data: ✅ 성공
kakao: ✅ 성공
naver: ✅ 성공
```

### 실패 시:
- API 키가 올바르지 않음
- API 신청이 아직 승인되지 않음
- 네트워크 연결 문제

---

## 6. 다음 단계

API 키 테스트가 성공하면:
1. **데이터 수집 스크립트 개발**
2. **데이터 구조 설계**
3. **Flutter 앱 통합** 