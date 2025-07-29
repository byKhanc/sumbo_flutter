# 카카오맵 API 403 오류 해결 가이드

## 문제 원인
- **403 Forbidden 오류**: API 키는 인증되었지만 권한이 없습니다
- **Android 키 해시 누락**: 카카오 개발자 콘솔에서 Android 플랫폼 설정이 불완전합니다

## 해결 방법

### 1. Android 키 해시 생성

#### 방법 1: Android Studio 사용
1. **Android Studio 실행**
2. **Build → Generate Signed Bundle/APK**
3. **Key store path**: `~/.android/debug.keystore`
4. **Key store password**: `android`
5. **Key alias**: `androiddebugkey`
6. **Key password**: `android`

#### 방법 2: 터미널 사용 (Windows)
```bash
# Java 환경 변수 설정 후
keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore | openssl sha1 -binary | openssl base64
```

#### 방법 3: 온라인 키 해시 생성기
- https://developers.kakao.com/tool/clear/androidsample
- 패키지명: `com.example.sumbo_flutter`
- 키스토어 비밀번호: `android`

### 2. 카카오 개발자 콘솔 설정

#### Android 플랫폼 설정
1. **플랫폼 → Android**
2. **패키지명**: `com.example.sumbo_flutter`
3. **키 해시**: 위에서 생성한 키 해시 입력
4. **마켓 URL**: `market://details?id=com.example.sumbo_flutter`

#### Web 플랫폼 설정
1. **플랫폼 → Web**
2. **사이트 도메인**: `localhost`, `127.0.0.1` 추가

### 3. API 권한 확인
1. **동의항목 → 선택 동의 항목**
2. **카카오 로그인**: 활성화
3. **사용자 정보 수집**: 동의

### 4. 임시 해결책
현재 더미 데이터로 앱 테스트 가능:
- **1775개 더미 맛집 데이터** 생성 완료
- **Flutter 앱에서 맛집 목록 기능** 테스트 가능

## 다음 단계
1. 키 해시 생성 후 카카오 개발자 콘솔에 입력
2. 실제 카카오맵 API로 데이터 수집
3. 더미 데이터를 실제 데이터로 교체 