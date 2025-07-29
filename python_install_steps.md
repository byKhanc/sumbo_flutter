# Python 설치 단계별 가이드

## 1. 다운로드

### 1-1. Python 공식 사이트 접속
- **URL:** https://www.python.org/downloads/
- **브라우저에서 접속**

### 1-2. 다운로드 버튼 클릭
- **"Download Python 3.12.x"** 버튼 클릭
- **Windows installer (64-bit)** 자동 선택됨

### 1-3. 다운로드 완료
- **다운로드 폴더에서 파일 확인**
- **파일명:** `python-3.12.x-amd64.exe`

---

## 2. 설치 과정

### 2-1. 설치 파일 실행
- **다운로드한 .exe 파일 더블클릭**
- **관리자 권한 요청 시 "예" 클릭**

### 2-2. 설치 옵션 설정 ⚠️ 중요!
- **"Add Python to PATH" 체크박스 반드시 선택**
- **"Install Now" 클릭**
- **"Customize installation" 선택하지 않음**

### 2-3. 설치 진행
- **설치 진행률 표시**
- **완료까지 대기 (약 2-3분)**

### 2-4. 설치 완료
- **"Setup was successful" 메시지 확인**
- **"Close" 클릭**

---

## 3. 설치 확인

### 3-1. 명령 프롬프트에서 확인
```bash
python --version
```
**예상 결과:** `Python 3.12.x`

### 3-2. pip 확인
```bash
pip --version
```
**예상 결과:** `pip 23.x.x from ...`

---

## 4. 문제 해결

### 4-1. Python이 인식되지 않는 경우
1. **컴퓨터 재시작**
2. **환경 변수 확인**
3. **PATH에 Python 경로 추가**

### 4-2. 환경 변수 수동 설정
1. **시스템 속성** → **환경 변수**
2. **Path** → **편집**
3. **Python 경로 추가:**
   - `C:\Users\[사용자명]\AppData\Local\Programs\Python\Python312\`
   - `C:\Users\[사용자명]\AppData\Local\Programs\Python\Python312\Scripts\`

---

## 5. 설치 완료 후

### 5-1. 패키지 설치
```bash
pip install requests pandas numpy
```

### 5-2. 테스트
```bash
python -c "print('Python 설치 성공!')"
```

---

## 📋 체크리스트

- [ ] Python 3.12.x 다운로드
- [ ] "Add Python to PATH" 선택
- [ ] 설치 완료
- [ ] python --version 확인
- [ ] pip --version 확인
- [ ] 테스트 실행

---

## 🎯 다음 단계

Python 설치 완료 후:
1. **API 키 발급 시작**
2. **API 테스트 환경 준비**
3. **데이터 수집 스크립트 실행** 