#!/bin/bash

# Gemini CLI 설치/업데이트 스크립트

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}=== Gemini CLI 설치/업데이트 ===${NC}"
echo ""

# Node.js 확인
if ! command -v node >/dev/null 2>&1; then
    echo -e "${RED}Node.js가 설치되어 있지 않습니다.${NC}"
    echo "설치: sudo dnf install -y nodejs"
    exit 1
fi
echo "Node.js: $(node --version)"

# 현재 버전 확인
if command -v gemini >/dev/null 2>&1; then
    echo "현재 Gemini CLI 버전:"
    gemini --version 2>&1 || echo "(버전 확인 불가)"
else
    echo -e "${YELLOW}gemini CLI가 설치되어 있지 않습니다. 새로 설치합니다.${NC}"
fi

echo ""

# 설치/업데이트 실행
echo "설치/업데이트 중..."
sudo npm install -g @google/gemini-cli

echo ""

# 설치 확인
if command -v gemini >/dev/null 2>&1; then
    echo -e "${GREEN}설치/업데이트 완료!${NC}"
    echo "새 버전:"
    gemini --version 2>&1 || echo "(버전 확인 불가)"
else
    echo -e "${RED}설치에 실패했습니다. npm 로그를 확인하세요.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=== 완료 ===${NC}"
