#!/bin/bash
###############################################################################
# Claude Code - project-init 플러그인 설치 (GitHub 마켓플레이스 방식)
#
# GitHub에서 마켓플레이스를 등록하고 플러그인을 설치합니다.
# [마켓플레이스] project-init (https://github.com/whchoi98/project-init.git)
# [플러그인]     project-init (/init-project, /add-module, /sync-docs)
###############################################################################

set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
fail()  { echo -e "${RED}[FAIL]${NC} $*"; exit 1; }

MARKETPLACE_REPO="https://github.com/whchoi98/project-init.git"
MARKETPLACE_NAME="project-init"
PLUGIN_NAME="project-init"

###############################################################################
# 1. 사전 요구사항 확인
###############################################################################
info "=== 사전 요구사항 확인 ==="

if command -v claude >/dev/null 2>&1; then
    ok "claude CLI: $(claude --version 2>&1 | head -1)"
else
    fail "claude CLI가 설치되어 있지 않습니다."
fi

if command -v git >/dev/null 2>&1; then
    ok "git: $(git --version)"
else
    fail "git이 설치되어 있지 않습니다."
fi

echo ""

###############################################################################
# 2. 마켓플레이스 등록
###############################################################################
info "=== 마켓플레이스 등록 ==="

if claude plugin marketplace list 2>&1 | grep -q "$MARKETPLACE_NAME"; then
    ok "$MARKETPLACE_NAME 마켓플레이스 이미 등록됨"
    info "마켓플레이스 업데이트 중..."
    claude plugin marketplace update "$MARKETPLACE_NAME" 2>&1 && ok "마켓플레이스 업데이트 완료" || warn "마켓플레이스 업데이트 실패 (계속 진행)"
else
    info "$MARKETPLACE_NAME 마켓플레이스 등록 중..."
    if claude plugin marketplace add "$MARKETPLACE_REPO" 2>&1; then
        ok "마켓플레이스 등록 완료"
    else
        fail "마켓플레이스 등록 실패"
    fi
fi

echo ""

###############################################################################
# 3. 플러그인 설치
###############################################################################
info "=== 플러그인 설치 ==="

info "$PLUGIN_NAME 설치 중..."
if claude plugin install "${PLUGIN_NAME}@${MARKETPLACE_NAME}" 2>&1; then
    ok "$PLUGIN_NAME 설치 완료"
else
    warn "설치 실패 또는 이미 설치됨. 재설치를 시도합니다..."
    claude plugin uninstall "$PLUGIN_NAME" 2>/dev/null || true
    if claude plugin install "${PLUGIN_NAME}@${MARKETPLACE_NAME}" 2>&1; then
        ok "$PLUGIN_NAME 재설치 완료"
    else
        fail "$PLUGIN_NAME 설치에 실패했습니다."
    fi
fi

echo ""

###############################################################################
# 4. 결과 요약
###############################################################################
ok "설치가 완료되었습니다! Claude Code를 재시작하면 적용됩니다."
echo ""
echo "  [마켓플레이스] $MARKETPLACE_NAME"
echo "    소스: $MARKETPLACE_REPO"
echo ""
echo "  [플러그인] $PLUGIN_NAME"
echo "    /init-project  - 프로젝트 구조 초기화"
echo "    /add-module    - 모듈 추가"
echo "    /sync-docs     - 문서 동기화"
echo ""
echo "  [업데이트 방법]"
echo "    claude plugin marketplace update $MARKETPLACE_NAME"
echo "    claude plugin update ${PLUGIN_NAME}@${MARKETPLACE_NAME}"
