# Python 설치 가이드

## 1. Python 다운로드 및 설치

### 1-1. Python 공식 사이트에서 다운로드
1. **https://www.python.org/downloads/** 접속
2. **"Download Python 3.12.x"** 클릭 (최신 버전)
3. **Windows installer (64-bit)** 다운로드

### 1-2. 설치 과정
1. **다운로드한 파일 실행**
2. **"Add Python to PATH" 체크박스 선택** ⚠️ 중요!
3. **"Install Now" 클릭**
4. **설치 완료까지 대기**

### 1-3. 설치 확인
```bash
python --version
```
또는
```bash
py --version
```

---

## 2. pip 설치 확인

### 2-1. pip 버전 확인
```bash
pip --version
```

### 2-2. pip 업그레이드 (필요시)
```bash
python -m pip install --upgrade pip
```

---

## 3. 필요한 패키지 설치

### 3-1. requirements.txt 설치
```bash
pip install -r requirements.txt
```

### 3-2. 개별 패키지 설치 (필요시)
```bash
pip install requests
pip install pandas
pip install numpy
```

---

## 4. 설치 확인

### 4-1. Python 테스트
```bash
python -c "print('Python 설치 성공!')"
```

### 4-2. 패키지 테스트
```bash
python -c "import requests; import pandas; import numpy; print('모든 패키지 설치 성공!')"
```

---

## 5. 문제 해결

### 5-1. Python이 인식되지 않는 경우
- **시스템 환경 변수 확인**
- **PATH에 Python 경로 추가**
- **컴퓨터 재시작**

### 5-2. pip 오류 발생 시
```bash
python -m pip install --upgrade pip
```

### 5-3. 권한 오류 발생 시
- **관리자 권한으로 명령 프롬프트 실행**
- **또는 가상환경 사용**

---

## 6. 가상환경 사용 (권장)

### 6-1. 가상환경 생성
```bash
python -m venv sumbo_env
```

### 6-2. 가상환경 활성화
```bash
# Windows
sumbo_env\Scripts\activate

# macOS/Linux
source sumbo_env/bin/activate
```

### 6-3. 패키지 설치
```bash
pip install -r requirements.txt
```

---

## 7. 다음 단계

Python 설치 완료 후:
1. **API 키 발급 진행**
2. **API 테스트 실행**
3. **데이터 수집 시작**

---

## 📋 체크리스트

- [ ] Python 3.12.x 설치
- [ ] "Add Python to PATH" 선택
- [ ] pip 설치 확인
- [ ] requirements.txt 설치
- [ ] 가상환경 생성 (권장)
- [ ] 설치 테스트 완료 