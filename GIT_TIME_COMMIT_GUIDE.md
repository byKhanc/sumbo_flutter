# Git 커밋 시 시간 정보 추가 가이드

이 가이드는 Git 커밋 시 작업 시간대를 파악할 수 있도록 시간 정보를 자동으로 추가하는 방법을 설명합니다.

## 방법 1: PowerShell 스크립트 사용 (권장)

### 사용법
```powershell
# 기본 사용법
.\git-commit-time.ps1 "커밋 메시지"

# 상세 설명과 함께 사용
.\git-commit-time.ps1 "커밋 메시지" "상세 설명"
```

### 예시
```powershell
.\git-commit-time.ps1 "기능 추가: 사용자 인증 구현"
.\git-commit-time.ps1 "버그 수정" "로그인 페이지에서 발생한 오류 수정"
```

## 방법 2: Git Alias 사용

### 설정된 Alias
- `git tcommit "메시지"` - 간단한 시간 정보와 함께 커밋

### 사용법
```bash
git tcommit "커밋 메시지"
```

## 방법 3: 수동으로 시간 정보 추가

커밋 메시지에 직접 시간 정보를 추가할 수 있습니다:

```bash
git commit -m "작업 시간: https://time.is/ko/KST
현재 시간: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss KST')

커밋 메시지"
```

## 커밋 메시지 템플릿

프로젝트에 `.gitmessage` 파일이 설정되어 있어서 `git commit` 명령어를 실행하면 자동으로 시간 정보가 포함된 템플릿이 표시됩니다.

## 생성된 파일들

1. **git-commit-time.ps1** - PowerShell 스크립트 (시간 정보 자동 추가)
2. **.gitmessage** - Git 커밋 메시지 템플릿
3. **setup-git-aliases.ps1** - Git alias 설정 스크립트

## 시간 정보 형식

- **URL**: https://time.is/ko/KST (한국 표준시 확인)
- **현재 시간**: yyyy-MM-dd HH:mm:ss KST 형식
- **예시**: 2024-01-15 14:30:25 KST

## 주의사항

1. PowerShell 스크립트를 실행하기 전에 실행 정책을 확인하세요:
   ```powershell
   Get-ExecutionPolicy
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. Git alias는 전역 설정이므로 다른 프로젝트에서도 사용할 수 있습니다.

3. 시간 정보는 한국 표준시(KST) 기준으로 표시됩니다. 