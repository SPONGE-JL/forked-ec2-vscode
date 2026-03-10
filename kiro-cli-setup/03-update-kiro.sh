#!/bin/bash

# Kiro CLI 업데이트 스크립트

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}=== Kiro CLI 업데이트 ===${NC}"
echo ""

# 현재 버전 확인
if command -v kiro-cli >/dev/null 2>&1; then
    echo "현재 버전:"
    kiro-cli --version 2>&1 || echo "(버전 확인 불가)"
else
    echo -e "${RED}kiro-cli가 설치되어 있지 않습니다.${NC}"
    echo "새로 설치를 진행합니다."
fi

echo ""

# 아키텍처 감지
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
    KIRO_ZIP="kirocli-aarch64-linux.zip"
else
    KIRO_ZIP="kirocli-x86_64-linux.zip"
fi

echo "아키텍처: $ARCH"
echo "다운로드: $KIRO_ZIP"
echo ""

# 다운로드 및 설치
cd /tmp
if curl --proto '=https' --tlsv1.2 -sSf \
    "https://desktop-release.q.us-east-1.amazonaws.com/latest/${KIRO_ZIP}" \
    -o kirocli.zip; then

    unzip -qo kirocli.zip

    if [ -d "kirocli/bin" ]; then
        chmod +x kirocli/bin/*
        sudo cp kirocli/bin/* /usr/local/bin/
        rm -rf kirocli kirocli.zip
        echo -e "${GREEN}업데이트 완료!${NC}"
        echo ""
        echo "새 버전:"
        kiro-cli --version 2>&1 || echo "(버전 확인 불가)"
    else
        echo -e "${RED}kirocli/bin 디렉토리를 찾을 수 없습니다.${NC}"
        rm -f kirocli.zip
        exit 1
    fi
else
    echo -e "${RED}다운로드 실패${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=== 업데이트 완료 ===${NC}"
