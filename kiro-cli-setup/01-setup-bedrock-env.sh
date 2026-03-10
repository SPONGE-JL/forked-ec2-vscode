#!/bin/bash

# Kiro CLI + Amazon Bedrock bashrc 설정 스크립트

BASHRC_FILE="$HOME/.bashrc"

echo "=== Kiro CLI + Amazon Bedrock bashrc 설정 ==="
echo

# AWS_BEARER_TOKEN_BEDROCK 값 입력받기
read -p "AWS_BEARER_TOKEN_BEDROCK 값을 입력하세요: " AWS_TOKEN

if [ -z "$AWS_TOKEN" ]; then
    echo "오류: AWS_BEARER_TOKEN_BEDROCK 값이 비어있습니다."
    exit 1
fi

# AWS_REGION 선택
echo
echo "AWS Region을 선택하세요:"
echo "  1) us-east-1       (버지니아)"
echo "  2) us-west-2       (오레곤)"
echo "  3) ap-northeast-2  (서울)"
echo "  4) ap-northeast-1  (도쿄)"
echo "  5) eu-west-1       (아일랜드)"
echo
read -p "선택 (1-5, 기본값: 1): " REGION_CHOICE

case "$REGION_CHOICE" in
    2) SELECTED_REGION="us-west-2" ;;
    3) SELECTED_REGION="ap-northeast-2" ;;
    4) SELECTED_REGION="ap-northeast-1" ;;
    5) SELECTED_REGION="eu-west-1" ;;
    *) SELECTED_REGION="us-east-1" ;;
esac
echo "선택된 리전: $SELECTED_REGION"

# 기존 설정 확인
if grep -q "# Kiro CLI + Amazon Bedrock 설정" "$BASHRC_FILE" 2>/dev/null; then
    echo "기존 Kiro CLI + Bedrock 설정이 발견되었습니다."
    read -p "기존 설정을 덮어쓰시겠습니까? (y/n): " OVERWRITE
    if [ "$OVERWRITE" = "y" ] || [ "$OVERWRITE" = "Y" ]; then
        sed -i '/# Kiro CLI + Amazon Bedrock 설정/,/^$/d' "$BASHRC_FILE"
        echo "기존 설정을 제거했습니다."
    else
        echo "설정을 취소합니다."
        exit 0
    fi
fi

# bashrc에 설정 추가
cat >> "$BASHRC_FILE" << EOF

# Kiro CLI + Amazon Bedrock 설정
export AWS_BEARER_TOKEN_BEDROCK='${AWS_TOKEN}'
export AWS_REGION='${SELECTED_REGION}'

EOF

echo
echo "bashrc에 설정이 추가되었습니다."
echo "설정을 적용하려면 다음 명령어를 실행하세요:"
echo "  source ~/.bashrc"
