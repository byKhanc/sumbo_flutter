# 카카오맵 API 403 오류 해결 가이드

## 🚨 문제 원인
- **403 Forbidden**: API 키는 인증되었지만 권한이 없습니다
- **Android 키 해시 누락**: 카카오 개발자 콘솔에서 Android 플랫폼 설정이 불완전

## 🔧 해결 방법

### 1. 카카오 개발자 콘솔 접속
1. **https://developers.kakao.com/** 접속
2. **카카오 계정으로 로그인**
3. **내 애플리케이션 → 앱 선택**

### 2. Android 플랫폼 설정
1. **플랫폼 → Android 클릭**
2. **패키지명 입력**: `com.example.sumbo_flutter`
3. **키 해시 입력**: 아래 방법으로 생성한 키 해시

### 3. 키 해시 생성 방법

#### 방법 1: 온라인 키 해시 생성기 (추천)
1. **https://developers.kakao.com/tool/clear/androidsample** 접속
2. **패키지명**: `com.example.sumbo_flutter`
3. **키스토어 비밀번호**: `android`
4. **생성된 키 해시 복사**

#### 방법 2: Android Studio 사용
1. **Android Studio 실행**
2. **Build → Generate Signed Bundle/APK**
3. **Key store path**: `~/.android/debug.keystore`
4. **Key store password**: `android`
5. **Key alias**: `androiddebugkey`
6. **Key password**: `android`

### 4. API 권한 설정
1. **동의항목 → 선택 동의 항목**
2. **카카오 로그인**: 활성화
3. **사용자 정보 수집**: 동의
4. **카카오맵 API**: 활성화

### 5. Web 플랫폼 설정 (웹 테스트용)
1. **플랫폼 → Web**
2. **사이트 도메인 추가**:
   - `localhost`
   - `127.0.0.1`
   - `http://localhost:3000`

## ✅ 설정 완료 후 테스트

### API 키 테스트
```bash
python api_test.py
```

### 데이터 수집 테스트
```bash
python data_collector_enhanced.py
```

## 🎯 핵심 포인트

### 권한 문제 해결 순서
1. **키 해시 등록** (가장 중요!)
2. **패키지명 확인**
3. **API 권한 활성화**
4. **도메인 설정**

### 자주 발생하는 오류
- **키 해시 불일치**: 정확한 키 해시 입력 필요
- **패키지명 오류**: `com.example.sumbo_flutter` 확인
- **API 권한 미활성화**: 카카오맵 API 권한 확인

## 📞 추가 도움
- **카카오 개발자 센터**: https://developers.kakao.com/docs
- **API 문서**: https://developers.kakao.com/docs/latest/ko/local 