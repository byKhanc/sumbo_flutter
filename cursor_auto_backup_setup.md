# Cursor 자동 백업 설정 가이드

## 방법 1: Cursor 설정에서 자동 백업 활성화

1. **Cursor 설정 열기**
   - `Ctrl + ,` 또는 `File > Preferences > Settings`

2. **검색창에 "exit" 입력**

3. **다음 설정 찾기 및 변경:**
   ```json
   {
     "workbench.onExit": "run",
     "terminal.integrated.shellArgs.windows": ["/c", "C:\\Users\\82102\\sumbo_flutter\\auto_backup.bat"]
   }
   ```

## 방법 2: 수동 실행 (권장)

### 매번 Cursor 종료 시:
1. `Win + R` 키를 누르고 `cmd` 입력
2. 다음 명령어 실행:
   ```cmd
   C:\Users\82102\sumbo_flutter\auto_backup.bat
   ```

### 또는 바로가기 만들기:
1. `auto_backup.bat` 파일을 우클릭
2. "바로 가기 만들기" 선택
3. 바탕화면에 바로가기 생성
4. Cursor 종료 시 바로가기 더블클릭

## 방법 3: 작업 스케줄러 설정 (완전 자동화)

1. **작업 스케줄러 열기**
   - `Win + R` → `taskschd.msc` 입력

2. **기본 작업 만들기**
   - "작업 만들기" 클릭
   - 트리거: "로그온할 때"
   - 동작: "프로그램 시작"
   - 프로그램: `C:\Users\82102\sumbo_flutter\auto_backup.bat`

## 백업 확인 방법

### GitHub에서 확인:
- [sumbo_flutter](https://github.com/byKhanc/sumbo_flutter.git)
- [sumbo_web-BackUp](https://github.com/byKhanc/sumbo_web-BackUp.git)

### 로컬에서 확인:
```cmd
cd C:\Users\82102\sumbo_flutter
git log --oneline -5
```

## 문제 해결

### Git 인증 오류 시:
```cmd
git config --global user.name "your_username"
git config --global user.email "your_email@example.com"
```

### 강제 푸시 필요 시:
```cmd
git push -f origin main
```

## 백업 내용

### sumbo_flutter 백업:
- ✅ 모든 Dart 파일
- ✅ assets 폴더 (이미지, JSON 데이터)
- ✅ pubspec.yaml 및 설정 파일
- ✅ Android/iOS 설정
- ✅ 웹 설정

### sumbo-web 백업:
- ✅ HTML, CSS, JavaScript 파일
- ✅ 이미지 및 리소스
- ✅ JSON 데이터 파일
- ✅ 배포 설정

## 주의사항

1. **인터넷 연결 필요**: GitHub에 푸시하려면 인터넷이 필요합니다
2. **Git 인증**: 처음 실행 시 GitHub 로그인 필요할 수 있습니다
3. **충돌 해결**: 자동 백업은 강제 푸시를 사용하므로 주의하세요
4. **백업 시간**: 대용량 파일이 많으면 시간이 걸릴 수 있습니다

## 백업 스크립트 커스터마이징

`auto_backup.bat` 파일을 수정하여:
- 백업할 폴더 추가/제거
- 백업 메시지 변경
- 오류 처리 개선
- 로그 파일 생성

가능합니다! 