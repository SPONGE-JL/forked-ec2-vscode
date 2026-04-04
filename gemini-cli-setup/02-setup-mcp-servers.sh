#!/bin/bash
###############################################################################
# Gemini CLI - AWS MCP 서버 설정 스크립트
#
# ~/.gemini/settings/mcp.json 에 MCP 서버를 등록합니다.
#
# [MCP 서버]
#   awslabs-terraform-mcp-server      : Terraform/Terragrunt AWS 인프라 개발
#   awslabs-core-mcp-server           : AWS API, Cost Explorer, 다이어그램, 가격 분석
#   bedrock-agentcore-mcp-server      : Bedrock AgentCore Gateway, Memory, Runtime
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

MCP_DIR="$HOME/.gemini/settings"
MCP_FILE="$MCP_DIR/mcp.json"

###############################################################################
# 1. 사전 요구사항 확인
###############################################################################
info "=== 사전 요구사항 확인 ==="

if command -v gemini >/dev/null 2>&1; then
    ok "gemini CLI: $(gemini --version 2>&1 | head -1)"
else
    warn "gemini CLI가 설치되어 있지 않습니다. 03-update-gemini.sh로 설치하세요."
fi

if command -v uvx >/dev/null 2>&1; then
    ok "uvx: $(uvx --version 2>&1 | head -1)"
else
    fail "uvx가 설치되어 있지 않습니다. 설치: curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

if aws sts get-caller-identity >/dev/null 2>&1; then
    ok "AWS 자격 증명: 정상"
else
    warn "AWS 자격 증명이 설정되지 않았습니다. 일부 MCP 서버가 정상 동작하지 않을 수 있습니다."
fi

echo ""

###############################################################################
# 2. 기존 설정 백업
###############################################################################
info "=== MCP 설정 파일 준비 ==="

mkdir -p "$MCP_DIR"

if [ -f "$MCP_FILE" ]; then
    BACKUP_FILE="${MCP_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$MCP_FILE" "$BACKUP_FILE"
    ok "기존 설정 백업: $BACKUP_FILE"
fi

echo ""

###############################################################################
# 3. MCP 서버 설정 생성
###############################################################################
info "=== MCP 서버 설정 생성 ==="

# 기존 파일이 있으면 읽기, 없으면 빈 구조 생성
if [ -f "$MCP_FILE" ] && [ -s "$MCP_FILE" ]; then
    EXISTING=$(cat "$MCP_FILE")
else
    EXISTING='{"mcpServers":{}}'
fi

# uvx 경로 확인
UVX_PATH=$(which uvx 2>/dev/null || echo "$HOME/.local/bin/uvx")

# MCP 서버 3개 추가
NEW_SERVERS=$(cat <<JSONEOF
{
  "mcpServers": {
    "awslabs-terraform-mcp-server": {
      "command": "${UVX_PATH}",
      "args": ["awslabs.terraform-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      },
      "disabled": false,
      "_description": "Terraform/Terragrunt AWS 인프라 개발"
    },
    "awslabs-core-mcp-server": {
      "command": "${UVX_PATH}",
      "args": ["awslabs.core-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "aws-foundation": "true",
        "solutions-architect": "true"
      },
      "disabled": false,
      "_description": "AWS API, Cost Explorer, 다이어그램, 가격 분석"
    },
    "bedrock-agentcore-mcp-server": {
      "command": "${UVX_PATH}",
      "args": ["awslabs.amazon-bedrock-agentcore-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      },
      "disabled": false,
      "_description": "Bedrock AgentCore Gateway, Memory, Runtime"
    }
  }
}
JSONEOF
)

# jq로 기존 설정과 병합
if command -v jq >/dev/null 2>&1; then
    echo "$EXISTING" | jq -s '.[0] * .[1]' - <(echo "$NEW_SERVERS") > "$MCP_FILE"
    ok "MCP 서버 설정 병합 완료"
else
    echo "$NEW_SERVERS" > "$MCP_FILE"
    warn "jq가 없어 새 설정으로 덮어썼습니다."
fi

echo ""

###############################################################################
# 4. 결과 출력
###############################################################################
info "=== 설정 결과 ==="
echo ""
echo "설정 파일: $MCP_FILE"
echo ""

if command -v jq >/dev/null 2>&1; then
    echo "등록된 MCP 서버:"
    jq -r '.mcpServers | keys[]' "$MCP_FILE" 2>/dev/null | while read -r server; do
        disabled=$(jq -r ".mcpServers[\"$server\"].disabled // false" "$MCP_FILE")
        desc=$(jq -r ".mcpServers[\"$server\"]._description // \"\"" "$MCP_FILE")
        if [ "$disabled" = "true" ]; then
            echo -e "  ${RED}[OFF]${NC} $server - $desc"
        else
            echo -e "  ${GREEN}[ON ]${NC} $server - $desc"
        fi
    done
else
    cat "$MCP_FILE"
fi

echo ""
ok "설정이 완료되었습니다! Gemini CLI를 재시작하면 적용됩니다."
echo ""
echo "  [MCP 서버] 3개"
echo "    awslabs-terraform-mcp-server      : Terraform/Terragrunt AWS 인프라 개발"
echo "    awslabs-core-mcp-server           : AWS API, Cost Explorer, 다이어그램, 가격 분석"
echo "    bedrock-agentcore-mcp-server      : Bedrock AgentCore Gateway, Memory, Runtime"
