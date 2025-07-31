# 커밋 시 시간 정보를 자동으로 추가하는 스크립트
param(
    [string]$Message = "",
    [string]$Description = ""
)

# 현재 시간 가져오기 (한국 시간)
$currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss KST"
$kstUrl = "https://time.is/ko/KST"

# 커밋 메시지 구성
$commitMessage = @"

작업 시간: $kstUrl
현재 시간: $currentTime

$Message

$Description
"@

# Git 커밋 실행
git commit -m $commitMessage

Write-Host "커밋이 완료되었습니다. 시간 정보가 포함되었습니다." -ForegroundColor Green 