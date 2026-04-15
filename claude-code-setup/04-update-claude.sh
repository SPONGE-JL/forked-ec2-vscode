#!/bin/bash

echo "=== Claude Code 업데이트 시작 ==="
echo ""

# 현재 버전 확인 (업데이트 전후 비교용)
OLD_VERSION=$(claude --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
echo "현재 버전: $OLD_VERSION"
echo ""

# 업데이트 실행 (npm latest 채널 사용 — brew cask는 stable 채널이라 버전이 느림)
echo "업데이트 중..."
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS: brew cask가 설치되어 있으면 제거 안내 후 npm으로 통일
    if brew list --cask claude-code &>/dev/null; then
        echo "⚠️  brew cask (stable 채널)로 설치되어 있습니다."
        echo "   npm (latest 채널)이 더 빠르게 최신 버전을 제공합니다."
        echo ""
        read -p "brew cask를 제거하고 npm으로 전환하시겠습니까? (y/n, 기본값: y): " SWITCH
        if [ "$SWITCH" != "n" ] && [ "$SWITCH" != "N" ]; then
            echo "brew cask 제거 중..."
            brew uninstall --cask claude-code
            echo "npm으로 설치 중..."
            npm install -g @anthropic-ai/claude-code
        else
            echo "brew cask로 업데이트합니다 (stable 채널)..."
            brew upgrade claude-code
        fi
    else
        npm update -g @anthropic-ai/claude-code
    fi
else
    # Linux: 글로벌 설치는 sudo 필요
    sudo npm update -g @anthropic-ai/claude-code
fi

# 업데이트 후 버전 확인
NEW_VERSION=$(claude --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
echo ""
echo "업데이트 완료! 새 버전: $NEW_VERSION"
echo ""

# 버전 변경 시 릴리스 노트(새 기능 요약) 출력
if [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
    echo "ℹ️  이미 최신 버전입니다."
else
    echo "🆕 $OLD_VERSION → $NEW_VERSION 변경사항:"
    echo "────────────────────────────────────────"

    # GitHub Releases API에서 해당 버전의 릴리스 노트 가져오기
    RELEASE_BODY=""
    if command -v curl &>/dev/null; then
        RELEASE_JSON=$(curl -sf --max-time 10 \
            "https://api.github.com/repos/anthropics/claude-code/releases/tags/v${NEW_VERSION}" \
            2>/dev/null || true)
        if [ -n "$RELEASE_JSON" ]; then
            # python3이 있으면 JSON 파싱, 없으면 sed로 추출
            if command -v python3 &>/dev/null; then
                RELEASE_BODY=$(echo "$RELEASE_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('body',''))" 2>/dev/null || true)
            else
                RELEASE_BODY=$(echo "$RELEASE_JSON" | sed -n 's/.*"body"[[:space:]]*:[[:space:]]*"//p' | sed 's/"[[:space:]]*$//' | sed 's/\\r\\n/\n/g; s/\\n/\n/g' || true)
            fi
        fi
    fi

    if [ -n "$RELEASE_BODY" ]; then
        # JSON 이스케이프 문자 복원 후 주요 내용만 추출
        echo "$RELEASE_BODY" \
            | sed 's/\\r\\n/\n/g; s/\\n/\n/g; s/\\t/\t/g; s/\\"/"/g' \
            | sed -n '/^##\|^- \|^\* \|^[0-9]\./p' \
            | head -30
    else
        # 릴리스 노트를 가져올 수 없는 경우 npm info에서 대체 정보 표시
        echo "  릴리스 노트를 가져올 수 없습니다."
        echo "  아래에서 직접 확인하세요:"
        echo "  → https://github.com/anthropics/claude-code/releases/tag/v${NEW_VERSION}"
        echo ""
        # changelog 명령이 있으면 표시
        if npm view @anthropic-ai/claude-code dist-tags --json &>/dev/null 2>&1; then
            echo "  npm 채널별 최신 버전:"
            npm view @anthropic-ai/claude-code dist-tags --json 2>/dev/null \
                | grep -E '"(latest|beta|next)"' \
                | sed 's/[",]//g; s/^/    /'
        fi
    fi
    echo "────────────────────────────────────────"
fi

echo ""
echo "=== 업데이트 완료 ==="
