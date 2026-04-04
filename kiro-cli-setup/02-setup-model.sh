#!/bin/bash

# Kiro CLI 모델 설정 스크립트

echo "=== Kiro CLI 모델 설정 ==="
echo
echo "모델 선택은 Kiro CLI 안에서 인터랙티브하게 진행됩니다."
echo "사용 가능한 모델은 리전에 따라 동적으로 제공됩니다."
echo

echo "모델 설정 방법:"
echo
echo "  방법 1) 인터랙티브 선택 (권장)"
echo "    kiro-cli chat 실행 후:"
echo "    /model                          모델 목록에서 선택"
echo "    /model set-current-as-default   선택한 모델을 기본값으로 저장"
echo
echo "  방법 2) CLI에서 직접 지정 (모델 ID를 알고 있을 때)"
echo "    kiro-cli settings chat.defaultModel <model-id>"
echo
echo "  방법 3) 시작할 때 모델 지정"
echo "    kiro-cli chat --model <model-id>"
echo

read -p "지금 Kiro CLI를 열어 모델을 선택하시겠습니까? (y/n, 기본값: y): " OPEN_KIRO

if [ "$OPEN_KIRO" != "n" ] && [ "$OPEN_KIRO" != "N" ]; then
    echo
    echo "Kiro CLI를 시작합니다. /model 명령어로 모델을 선택하세요."
    echo "선택 후 /model set-current-as-default 로 기본값을 저장하세요."
    echo "종료하려면 /quit 을 입력하세요."
    echo
    kiro-cli chat
fi

# 현재 설정 확인
echo
echo "=== 현재 모델 설정 ==="
CURRENT_MODEL=$(kiro-cli settings chat.defaultModel 2>/dev/null)
if [ -n "$CURRENT_MODEL" ]; then
    echo "  기본 모델: $CURRENT_MODEL"
else
    echo "  기본 모델: 설정되지 않음 (시스템 기본값 사용)"
fi
