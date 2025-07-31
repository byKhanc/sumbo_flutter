# Cursor 종료 시 자동 백업 스크립트 (시간 정보 포함)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cursor 종료 시 자동 백업 시작" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 현재 시간 가져오기 (한국 시간)
$currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss KST"
$kstUrl = "https://time.is/ko/KST"

# 커밋 메시지 생성
$commitMessage = @"

작업 시간: $kstUrl
현재 시간: $currentTime

Cursor 자동 백업 - $currentTime
"@

# sumbo_flutter 백업
Write-Host "[1/2] sumbo_flutter 백업 중..." -ForegroundColor Yellow
Set-Location "C:\Users\82102\sumbo_flutter"

# Git 상태 확인
$gitStatus = git status --porcelain
if ($gitStatus) {
    git add .
    git commit -m $commitMessage
    git push origin main
    if ($LASTEXITCODE -ne 0) {
        Write-Host "sumbo_flutter 백업 실패! 강제 푸시 시도..." -ForegroundColor Red
        git push -f origin main
    }
    Write-Host "✅ sumbo_flutter 백업 완료" -ForegroundColor Green
} else {
    Write-Host "sumbo_flutter: 변경사항 없음" -ForegroundColor Gray
}

# sumbo-web 백업
Write-Host "[2/2] sumbo-web 백업 중..." -ForegroundColor Yellow
Set-Location "C:\Users\82102\sumbo-web"

# Git 상태 확인
$gitStatus = git status --porcelain
if ($gitStatus) {
    git add .
    git commit -m $commitMessage
    git push origin main
    if ($LASTEXITCODE -ne 0) {
        Write-Host "sumbo-web 백업 실패! 강제 푸시 시도..." -ForegroundColor Red
        git push -f origin main
    }
    Write-Host "✅ sumbo-web 백업 완료" -ForegroundColor Green
} else {
    Write-Host "sumbo-web: 변경사항 없음" -ForegroundColor Gray
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "자동 백업 완료!" -ForegroundColor Green
Write-Host "백업 시간: $currentTime" -ForegroundColor Cyan
Write-Host "시간 확인: $kstUrl" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Read-Host "계속하려면 Enter를 누르세요" 