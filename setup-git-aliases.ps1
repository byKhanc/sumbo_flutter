# Git alias 설정 스크립트

# 시간 정보가 포함된 커밋을 위한 alias 설정 (간단한 버전)
git config --global alias.tcommit '!f() { git commit -m "[$(date)] $1"; }; f'

# 더 상세한 시간 정보를 위한 별도 스크립트 생성
$commitScript = @'
#!/bin/bash
current_time=$(date "+%Y-%m-%d %H:%M:%S KST")
git commit -m "작업 시간: https://time.is/ko/KST
현재 시간: $current_time

$1"
'@

# 스크립트 파일 생성
$commitScript | Out-File -FilePath "git-commit-with-time.sh" -Encoding UTF8

Write-Host "Git alias가 설정되었습니다!" -ForegroundColor Green
Write-Host ""
Write-Host "사용 방법:" -ForegroundColor Yellow
Write-Host "  git tcommit \"커밋 메시지\" - 간단한 시간 정보와 함께 커밋" -ForegroundColor White
Write-Host "  .\git-commit-with-time.sh \"커밋 메시지\" - 상세한 시간 정보와 함께 커밋" -ForegroundColor White
Write-Host ""
Write-Host "예시:" -ForegroundColor Yellow
Write-Host "  git tcommit \"기능 추가: 사용자 인증 구현\"" -ForegroundColor White
Write-Host "  .\git-commit-with-time.sh \"버그 수정\"" -ForegroundColor White 