# Cursor 자동 백업 설정 가이드 (시간 정보 포함)

## 🕐 **시간 정보 자동 추가 기능**

Cursor 종료 시 자동으로 다음 정보가 포함된 커밋이 생성됩니다:
- **작업 시간 URL**: https://time.is/ko/KST (항상 포함)
- **현재 시간**: 정확한 한국 시간 (가능한 경우)
- **커밋 메시지**: "Cursor 자동 백업 - [시간]"

### 시간 정보 가져오기 우선순위:
1. **time.is/ko/KST**에서 정확한 시간 추출
2. **WorldTimeAPI**에서 한국 시간 가져오기
3. **로컬 시간**을 KST로 변환 (UTC+9)
4. **시간 정보 없음**: 작업 시간 링크만 포함

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

## 방법 2: PowerShell 스크립트 사용 (권장)

### 더 정확한 시간 정보를 위해 PowerShell 스크립트 사용:
```powershell
# Cursor 종료 시 실행
C:\Users\82102\sumbo_flutter\auto_backup_with_time.ps1
```

### Cursor 설정에서 PowerShell 스크립트 사용:
```json
{
  "workbench.onExit": "run",
  "terminal.integrated.shellArgs.windows": ["-Command", "& 'C:\\Users\\82102\\sumbo_flutter\\auto_backup_with_time.ps1'"]
}
```

## 방법 3: 수동 실행

### 매번 Cursor 종료 시:
1. `Win + R` 키를 누르고 `powershell` 입력
2. 다음 명령어 실행:
   ```powershell
   C:\Users\82102\sumbo_flutter\auto_backup_with_time.ps1
   ```

### 또는 바로가기 만들기:
1. `auto_backup_with_time.ps1` 파일을 우클릭
2. "바로 가기 만들기" 선택
3. 바탕화면에 바로가기 생성
4. Cursor 종료 시 바로가기 더블클릭

## 방법 4: 작업 스케줄러 설정 (완전 자동화)

1. **작업 스케줄러 열기**
   - `Win + R` → `taskschd.msc` 입력

2. **기본 작업 만들기**
   - "작업 만들기" 클릭
   - 트리거: "로그온할 때"
   - 동작: "프로그램 시작"
   - 프로그램: `powershell.exe`
   - 인수: `-ExecutionPolicy Bypass -File "C:\Users\82102\sumbo_flutter\auto_backup_with_time.ps1"`

## 📊 **백업 확인 방법**

### GitHub에서 확인:
- [sumbo_flutter](https://github.com/byKhanc/sumbo_flutter.git)
- [sumbo_web-BackUp](https://github.com/byKhanc/sumbo_web-BackUp.git)

### 로컬에서 확인:
```cmd
cd C:\Users\82102\sumbo_flutter
git log --oneline -5
```

### 커밋 메시지 예시:

**시간 정보 성공 시:**
```
작업 시간: https://time.is/ko/KST
현재 시간: 2025-01-27 15:30:25 KST

Cursor 자동 백업 - 2025-01-27 15:30:25 KST
```

**시간 정보 실패 시:**
```
작업 시간: https://time.is/ko/KST

Cursor 자동 백업
```

## 🔧 **문제 해결**

### Git 인증 오류 시:
```cmd
git config --global user.name "your_username"
git config --global user.email "your_email@example.com"
```

### PowerShell 실행 정책 오류 시:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 강제 푸시 필요 시:
```cmd
git push -f origin main
```

## 📁 **백업 내용**

### sumbo_flutter 백업:
- ✅ 모든 Dart 파일
- ✅ assets 폴더 (이미지, JSON 데이터)
- ✅ pubspec.yaml 및 설정 파일
- ✅ Android/iOS 설정
- ✅ 웹 설정
- ✅ 시간 정보 포함 커밋

### sumbo-web 백업:
- ✅ HTML, CSS, JavaScript 파일
- ✅ 이미지 및 리소스
- ✅ JSON 데이터 파일
- ✅ 배포 설정
- ✅ 시간 정보 포함 커밋

## ⚠️ **주의사항**

1. **인터넷 연결 필요**: GitHub에 푸시하려면 인터넷이 필요합니다
2. **Git 인증**: 처음 실행 시 GitHub 로그인 필요할 수 있습니다
3. **충돌 해결**: 자동 백업은 강제 푸시를 사용하므로 주의하세요
4. **백업 시간**: 대용량 파일이 많으면 시간이 걸릴 수 있습니다
5. **시간 정보**: 한국 표준시(KST) 기준으로 기록됩니다

## 🛠️ **백업 스크립트 커스터마이징**

### auto_backup_with_time.ps1 수정하여:
- 백업할 폴더 추가/제거
- 커밋 메시지 형식 변경
- 오류 처리 개선
- 로그 파일 생성
- 이메일 알림 추가

가능합니다! 