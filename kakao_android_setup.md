# 카카오 개발자 콘솔 Android 설정 가이드

## 키 해시 값
**키 해시**: `2jmj7l5rSw0yVb/vlWAYkK/YBwk=`

## 카카오 개발자 콘솔 설정 방법

### 1. Android 플랫폼 설정
1. **https://developers.kakao.com/** 접속
2. **내 애플리케이션 → 해당 앱 선택**
3. **"플랫폼" 탭 → "Android" 클릭**
4. **다음 정보 입력:**

#### 패키지명
```
com.example.sumbo_flutter
```

#### 키 해시
```
2jmj7l5rSw0yVb/vlWAYkK/YBwk=
```

#### 마켓 URL
```
market://details?id=com.example.sumbo_flutter
```

### 2. Web 플랫폼 설정 (Python 스크립트용)
1. **"플랫폼" 탭 → "Web" 클릭**
2. **사이트 도메인 추가:**
   - `localhost`
   - `127.0.0.1`

### 3. 동의항목 설정
1. **"동의항목" 탭 클릭**
2. **"선택 동의 항목" 확인**
3. **"카카오 로그인" 활성화**

## 설정 완료 후 테스트
1. **설정 저장 후 5-10분 대기**
2. **Python 스크립트 재실행:**
   ```bash
   python kakao_data_collector.py
   ```

## 키 해시 생성 명령어 (참고)
```bash
keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64
```

## 현재 상황
- **키 해시 생성 완료**: `2jmj7l5rSw0yVb/vlWAYkK/YBwk=`
- **카카오 개발자 콘솔 설정 필요**: 위 정보로 Android 플랫폼 설정
- **설정 완료 후 실제 데이터 수집 가능** 