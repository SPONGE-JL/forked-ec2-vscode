#!/bin/bash

# Kiro CLI 모델 설정 스크립트

echo "=== Kiro CLI 모델 설정 ==="
echo
echo "사용할 모델을 선택하세요:"
echo
echo "  [Auto]"
echo "   1) auto                    (1.00x) 작업별 최적 모델 자동 선택"
echo
echo "  [Claude Opus]"
echo "   2) claude-opus-4.6         (2.20x) 최신 Claude Opus"
echo "   3) claude-opus-4.6-1m      (2.20x) 최신 Claude Opus, 1M 컨텍스트"
echo "   4) claude-opus-4.5         (2.20x) Claude Opus 4.5"
echo
echo "  [Claude Sonnet]"
echo "   5) claude-sonnet-4.6       (1.30x) 최신 Claude Sonnet"
echo "   6) claude-sonnet-4.6-1m    (1.30x) 최신 Claude Sonnet, 1M 컨텍스트"
echo "   7) claude-sonnet-4.5       (1.30x) Claude Sonnet 4.5"
echo "   8) claude-sonnet-4         (1.30x) 하이브리드 추론 및 코딩"
echo
echo "  [Claude Haiku]"
echo "   9) claude-haiku-4.5        (0.40x) 최신 Claude Haiku"
echo
echo "  [Third-Party]"
echo "  10) deepseek-3.2            (0.25x) DeepSeek V3.2 프리뷰"
echo "  11) kimi-k2.5               (0.25x) Kimi K2.5 프리뷰"
echo "  12) minimax-m2.5            (0.25x) MiniMax M2.5 프리뷰"
echo "  13) minimax-m2.1            (0.15x) MiniMax M2.1 프리뷰"
echo "  14) glm-5                   (0.50x) GLM-5 프리뷰"
echo "  15) qwen3-coder-next        (0.05x) Qwen3 Coder Next 프리뷰"
echo "  16) agi-nova-beta-1m        (0.01x) AGI Nova SWE Beta"
echo "  17) qwen3-coder-480b        (0.01x) Qwen3 Coder 480B 프리뷰"
echo
read -p "선택 (1-17, 기본값: 1): " MODEL_CHOICE

case "$MODEL_CHOICE" in
    2)  SELECTED_MODEL="claude-opus-4.6" ;;
    3)  SELECTED_MODEL="claude-opus-4.6-1m" ;;
    4)  SELECTED_MODEL="claude-opus-4.5" ;;
    5)  SELECTED_MODEL="claude-sonnet-4.6" ;;
    6)  SELECTED_MODEL="claude-sonnet-4.6-1m" ;;
    7)  SELECTED_MODEL="claude-sonnet-4.5" ;;
    8)  SELECTED_MODEL="claude-sonnet-4" ;;
    9)  SELECTED_MODEL="claude-haiku-4.5" ;;
    10) SELECTED_MODEL="deepseek-3.2" ;;
    11) SELECTED_MODEL="kimi-k2.5" ;;
    12) SELECTED_MODEL="minimax-m2.5" ;;
    13) SELECTED_MODEL="minimax-m2.1" ;;
    14) SELECTED_MODEL="glm-5" ;;
    15) SELECTED_MODEL="qwen3-coder-next" ;;
    16) SELECTED_MODEL="agi-nova-beta-1m" ;;
    17) SELECTED_MODEL="qwen3-coder-480b" ;;
    *)  SELECTED_MODEL="auto" ;;
esac

echo
echo "선택된 모델: $SELECTED_MODEL"

if command -v kiro-cli &> /dev/null; then
    kiro-cli settings chat.defaultModel "$SELECTED_MODEL"
    echo "✅ 기본 모델 설정 완료: $SELECTED_MODEL"
else
    echo "⚠️  kiro-cli가 설치되어 있지 않습니다. 설치 후 실행하세요:"
    echo "    kiro-cli settings chat.defaultModel $SELECTED_MODEL"
fi

echo
echo "모델 변경은 언제든 가능합니다:"
echo "  /model                          대화 중 모델 변경"
echo "  /model set-current-as-default   현재 모델을 기본값으로 저장"
