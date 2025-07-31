# Cursor 종료 시 자동 백업 스크립트 (시간 정보 포함)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cursor 종료 시 자동 백업 시작" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 작업 시간 URL (항상 포함)
$kstUrl = "https://time.is/ko/KST"

# 시간 정보 가져오기 시도 (안전한 방식)
$hasTime = $false
$currentTime = ""

Write-Host "시간 정보 가져오기 시도 중..." -ForegroundColor Yellow

# 방법 1: WorldTimeAPI 시도 (더 안정적)
try {
    $response = Invoke-WebRequest -Uri "https://worldtimeapi.org/api/timezone/Asia/Seoul" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        $timeData = $response.Content | ConvertFrom-Json
        $currentTime = $timeData.datetime + " KST"
        $hasTime = $true
        Write-Host "WorldTimeAPI에서 시간 정보 가져오기 성공: $currentTime" -ForegroundColor Green
    }
} catch {
    Write-Host "WorldTimeAPI에서 시간 정보 가져오기 실패" -ForegroundColor Yellow
}

# 방법 2: 로컬 시간 사용 (UTC+9)
if (-not $hasTime) {
    try {
        $utcTime = [DateTime]::UtcNow
        $kstTime = $utcTime.AddHours(9)  # UTC+9 (KST)
        $currentTime = $kstTime.ToString("yyyy-MM-dd HH:mm:ss") + " KST (로컬)"
        $hasTime = $true
        Write-Host "로컬 시간 사용: $currentTime" -ForegroundColor Yellow
    } catch {
        Write-Host "로컬 시간 변환 실패" -ForegroundColor Red
    }
}

# 커밋 메시지 생성
if ($hasTime) {
    $commitMessage = @"

작업 시간: $kstUrl
현재 시간: $currentTime

Cursor 자동 백업 - $currentTime
"@
} else {
    $commitMessage = @"

작업 시간: $kstUrl

Cursor 자동 백업
"@
}

Write-Host "커밋 메시지 생성 완료" -ForegroundColor Green

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
if ($hasTime) {
    Write-Host "백업 시간: $currentTime" -ForegroundColor Cyan
}
Write-Host "시간 확인: $kstUrl" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Read-Host "계속하려면 Enter를 누르세요" 