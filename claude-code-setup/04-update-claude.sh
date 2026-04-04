#!/bin/bash

echo "=== Claude Code 업데이트 시작 ==="
echo ""

# 현재 버전 확인
echo "현재 버전:"
claude --version
echo ""

# 업데이트 실행
echo "업데이트 중..."
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS: brew (formula 또는 cask)로 설치한 경우 brew upgrade, 아니면 npm
    if brew list --cask claude-code &>/dev/null || brew list --formula claude-code &>/dev/null; then
        brew upgrade claude-code
    else
        npm update -g @anthropic-ai/claude-code
    fi
else
    # Linux: 글로벌 설치는 sudo 필요
    sudo npm update -g @anthropic-ai/claude-code
fi

# 업데이트 후 버전 확인
echo ""
echo "업데이트 완료! 새 버전:"
claude --version
echo ""
echo "=== 업데이트 완료 ==="
