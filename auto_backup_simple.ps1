# Cursor 종료 시 자동 백업 스크립트 (간단 버전)

# UTF-8 인코딩 설정 강화
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# 콘솔 코드페이지를 UTF-8로 설정
try {
    chcp 65001 | Out-Null
} catch {
    Write-Host "코드페이지 설정 실패, 계속 진행..." -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cursor 종료 시 자동 백업 시작 (간단 버전)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$kstUrl = "https://time.is/ko/KST"

Write-Host "time.is에서 실시간 시간 가져오는 중..." -ForegroundColor Yellow

# time.is에서 직접 시간 가져오기
try {
    $response = Invoke-WebRequest -Uri "https://time.is/ko/KST" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        if ($response.Content -match '(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})') {
            $currentTime = $matches[1] + " KST"
            Write-Host "time.is에서 실시간 시간 가져오기 성공: $currentTime" -ForegroundColor Green
        } elseif ($response.Content -match '(\d{2}:\d{2}:\d{2})') {
            $currentTime = (Get-Date).ToString("yyyy-MM-dd ") + $matches[1] + " KST"
            Write-Host "time.is에서 실시간 시간 가져오기 성공: $currentTime" -ForegroundColor Green
        } else {
            throw "시간 패턴을 찾을 수 없음"
        }
    } else {
        throw "time.is 접근 실패"
    }
} catch {
    Write-Host "time.is 접근 실패, 로컬 시간 사용: $currentTime" -ForegroundColor Yellow
    $utcTime = [DateTime]::UtcNow
    $kstTime = $utcTime.AddHours(9)
    $currentTime = $kstTime.ToString("yyyy-MM-dd HH:mm:ss") + " KST (로컬)"
}

# 커밋 메시지 생성 (영어로 작성하여 한글 깨짐 방지)
$commitMessage = @"

Work Time: $kstUrl
Current Time: $currentTime

Cursor Auto Backup - $currentTime
"@

Write-Host "커밋 메시지 생성 완료" -ForegroundColor Green

# sumbo_flutter 백업
Write-Host "[1/2] sumbo_flutter 백업 중..." -ForegroundColor Yellow
Set-Location "C:\Users\82102\sumbo_flutter"

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