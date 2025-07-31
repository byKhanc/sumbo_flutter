#!/bin/bash

# Cursor 종료 시 자동 백업 스크립트 (Git Bash 버전)

echo "========================================"
echo "Cursor 종료 시 자동 백업 시작"
echo "========================================"

# 작업 시간 URL (항상 포함)
KST_URL="https://time.is/ko/KST"

# time.is에서 정확한 시간 가져오기
HAS_TIME=false
CURRENT_TIME=""

echo "time.is에서 정확한 시간 가져오기 시도 중..."

# curl을 사용하여 time.is에서 시간 정보 가져오기
if command -v curl &> /dev/null; then
    RESPONSE=$(curl -s "https://time.is/ko/KST" 2>/dev/null)
    if [ $? -eq 0 ]; then
        # 여러 패턴으로 시간 추출 시도
        if echo "$RESPONSE" | grep -qE '([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})'; then
            CURRENT_TIME=$(echo "$RESPONSE" | grep -oE '([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})' | head -1)
            CURRENT_TIME="$CURRENT_TIME KST"
            HAS_TIME=true
            echo "time.is에서 시간 정보 가져오기 성공: $CURRENT_TIME"
        elif echo "$RESPONSE" | grep -qE '([0-9]{2}:[0-9]{2}:[0-9]{2})'; then
            CURRENT_TIME=$(echo "$RESPONSE" | grep -oE '([0-9]{2}:[0-9]{2}:[0-9]{2})' | head -1)
            CURRENT_TIME="$CURRENT_TIME KST"
            HAS_TIME=true
            echo "time.is에서 시간 정보 가져오기 성공: $CURRENT_TIME"
        else
            echo "time.is에서 시간 패턴을 찾을 수 없음"
        fi
    else
        echo "time.is 접근 실패"
    fi
else
    echo "curl이 설치되지 않음"
fi

# 커밋 메시지 생성
if [ "$HAS_TIME" = true ]; then
    COMMIT_MESSAGE="

작업 시간: $KST_URL
현재 시간: $CURRENT_TIME

Cursor 자동 백업 - $CURRENT_TIME"
else
    COMMIT_MESSAGE="

작업 시간: $KST_URL

Cursor 자동 백업"
fi

echo "커밋 메시지 생성 완료"

# sumbo_flutter 백업
echo "[1/2] sumbo_flutter 백업 중..."
cd "C:/Users/82102/sumbo_flutter"

# Git 상태 확인
if [ -n "$(git status --porcelain)" ]; then
    git add .
    git commit -m "$COMMIT_MESSAGE"
    git push origin main
    if [ $? -ne 0 ]; then
        echo "sumbo_flutter 백업 실패! 강제 푸시 시도..."
        git push -f origin main
    fi
    echo "✅ sumbo_flutter 백업 완료"
else
    echo "sumbo_flutter: 변경사항 없음"
fi

# sumbo-web 백업
echo "[2/2] sumbo-web 백업 중..."
cd "C:/Users/82102/sumbo-web"

# Git 상태 확인
if [ -n "$(git status --porcelain)" ]; then
    git add .
    git commit -m "$COMMIT_MESSAGE"
    git push origin main
    if [ $? -ne 0 ]; then
        echo "sumbo-web 백업 실패! 강제 푸시 시도..."
        git push -f origin main
    fi
    echo "✅ sumbo-web 백업 완료"
else
    echo "sumbo-web: 변경사항 없음"
fi

echo "========================================"
echo "자동 백업 완료!"
if [ "$HAS_TIME" = true ]; then
    echo "백업 시간: $CURRENT_TIME"
fi
echo "시간 확인: $KST_URL"
echo "========================================"

read -p "계속하려면 Enter를 누르세요" 