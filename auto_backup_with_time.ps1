# Cursor 종료 시 자동 백업 스크립트 (시간 정보 포함)

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
Write-Host "Cursor 종료 시 자동 백업 시작" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 작업 시간 URL (항상 포함)
$kstUrl = "https://time.is/ko/KST"

# time.is에서 정확한 시간 가져오기
$hasTime = $false
$currentTime = ""

Write-Host "time.is에서 정확한 시간 가져오기 시도 중..." -ForegroundColor Yellow

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

# 방법 2: time.is에서 시간 추출 (WorldTimeAPI 실패 시)
if (-not $hasTime) {
    try {
        $response = Invoke-WebRequest -Uri "https://time.is/ko/KST" -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            # 더 강력한 패턴으로 시간 추출
            $patterns = @(
                '(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})',
                '(\d{2}:\d{2}:\d{2})',
                '(\d{4}년 \d{1,2}월 \d{1,2}일 \d{2}:\d{2}:\d{2})',
                '(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})',
                '(\d{4}-\d{2}-\d{2})',
                '(\d{2}:\d{2})'
            )
            
            foreach ($pattern in $patterns) {
                if ($response.Content -match $pattern) {
                    $currentTime = $matches[1] + " KST"
                    $hasTime = $true
                    Write-Host "time.is에서 시간 정보 가져오기 성공: $currentTime" -ForegroundColor Green
                    break
                }
            }
            
            if (-not $hasTime) {
                Write-Host "time.is에서 시간 패턴을 찾을 수 없음" -ForegroundColor Yellow
            }
        } else {
            Write-Host "time.is 접근 실패: $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "time.is에서 시간 정보 가져오기 실패: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 방법 3: 로컬 시간 사용 (마지막 수단)
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

# 커밋 메시지 생성 (영어로 작성하여 한글 깨짐 방지)
if ($hasTime) {
    $commitMessage = @"

Work Time: $kstUrl
Current Time: $currentTime

Cursor Auto Backup - $currentTime
"@
} else {
    $commitMessage = @"

Work Time: $kstUrl

Cursor Auto Backup
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