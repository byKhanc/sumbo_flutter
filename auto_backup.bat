@echo off
echo ========================================
echo Cursor 종료 시 자동 백업 시작
echo ========================================

:: sumbo_flutter 백업
cd /d "C:\Users\82102\sumbo_flutter"
echo [1/2] sumbo_flutter 백업 중...
git add .
git commit -m "Auto backup: %date% %time%"
git push origin main
if %errorlevel% neq 0 (
    echo sumbo_flutter 백업 실패! 강제 푸시 시도...
    git push -f origin main
)

:: sumbo-web 백업
cd /d "C:\Users\82102\sumbo-web"
echo [2/2] sumbo-web 백업 중...
git add .
git commit -m "Auto backup: %date% %time%"
git push origin main
if %errorlevel% neq 0 (
    echo sumbo-web 백업 실패! 강제 푸시 시도...
    git push -f origin main
)

echo ========================================
echo 자동 백업 완료!
echo 백업 시간: %date% %time%
echo ========================================
pause 