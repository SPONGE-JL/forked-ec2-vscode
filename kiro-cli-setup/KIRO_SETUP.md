# Kiro CLI Setup Scripts

VSCode Server 내에서 Kiro CLI 환경을 구성하는 스크립트 모음입니다.

## 사전 요구사항

| 항목 | 설치 확인 | 설치 방법 |
|------|----------|-----------|
| Kiro CLI | `kiro-cli --version` | UserData에서 자동 설치됨 |
| uv / uvx | `uvx --version` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| AWS CLI | `aws --version` | UserData에서 자동 설치됨 |
| jq | `jq --version` | `sudo dnf install -y jq` |

## 스크립트 실행 순서

```
01-setup-bedrock-env.sh        Bedrock 환경변수 설정
        |
        v
   source ~/.bashrc             환경변수 적용
        |
        v
02-setup-mcp-servers.sh        MCP 서버 설정 (~/.kiro/settings/mcp.json)
        |
        v
03-update-kiro.sh              Kiro CLI 업데이트 (수시)
```

---

## 01-setup-bedrock-env.sh

Amazon Bedrock 연동에 필요한 환경변수를 `~/.bashrc`에 설정합니다.

**실행:**
```bash
bash kiro-cli-setup/01-setup-bedrock-env.sh
source ~/.bashrc
```

**대화형 입력 항목:**
- `AWS_BEARER_TOKEN_BEDROCK` - AWS Bearer Token
- AWS Region 선택

**설정되는 환경변수:**
```bash
AWS_BEARER_TOKEN_BEDROCK
AWS_REGION
```

---

## 02-setup-mcp-servers.sh

`~/.kiro/settings/mcp.json`에 AWS MCP 서버를 등록합니다.

**실행:**
```bash
bash kiro-cli-setup/02-setup-mcp-servers.sh
```

**등록되는 MCP 서버:**

| 서버 | 패키지 | 기능 |
|------|--------|------|
| awslabs-terraform-mcp-server | `awslabs.terraform-mcp-server` | Terraform/Terragrunt AWS 인프라 개발 |
| awslabs-core-mcp-server | `awslabs.core-mcp-server` | AWS API, Cost Explorer, 다이어그램, 가격 분석 |
| bedrock-agentcore-mcp-server | `awslabs.amazon-bedrock-agentcore-mcp-server` | Bedrock AgentCore Gateway, Memory, Runtime |

**설정 파일:**
```
~/.kiro/settings/mcp.json
```

**MCP 서버 ON/OFF 토글:**
```bash
bash claude-code-setup/mcp-toggle.sh
```

---

## 03-update-kiro.sh

Kiro CLI를 최신 버전으로 업데이트합니다. ARM64/x86_64 아키텍처를 자동 감지합니다.

**실행:**
```bash
bash kiro-cli-setup/03-update-kiro.sh
```

---

## 빠른 시작

```bash
# 1. Bedrock 환경변수 설정
bash kiro-cli-setup/01-setup-bedrock-env.sh
source ~/.bashrc

# 2. MCP 서버 설정
bash kiro-cli-setup/02-setup-mcp-servers.sh

# 3. Kiro CLI 업데이트 (선택)
bash kiro-cli-setup/03-update-kiro.sh

# 4. Kiro CLI 실행
kiro-cli
```
