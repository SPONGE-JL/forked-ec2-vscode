# Gemini CLI Setup Scripts

VSCode Server 내에서 Google Gemini CLI 환경을 구성하는 스크립트 모음입니다.

## 사전 요구사항

| 항목 | 설치 확인 | 설치 방법 |
|------|----------|-----------|
| Gemini CLI | `gemini --version` | `npm install -g @google/gemini-cli` (03번 스크립트) |
| Node.js / npm | `node --version` | `sudo dnf install -y nodejs` |
| uv / uvx | `uvx --version` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| AWS CLI | `aws --version` | UserData에서 자동 설치됨 |
| jq | `jq --version` | `sudo dnf install -y jq` |
| gcloud (Vertex AI 시) | `gcloud --version` | [gcloud CLI 설치](https://cloud.google.com/sdk/docs/install) |

## 스크립트 실행 순서

```
03-update-gemini.sh            Gemini CLI 설치 (최초 1회)
        |
        v
01-setup-env.sh                환경변수 설정 (API 키/Vertex AI, 모델)
        |
        v
   source ~/.bashrc             환경변수 적용
        |
        v
02-setup-mcp-servers.sh        MCP 서버 설정 (~/.gemini/settings/mcp.json)
        |
        v
   gemini                       Gemini CLI 실행
```

---

## 01-setup-env.sh

Gemini CLI 실행에 필요한 환경변수를 `~/.bashrc`에 설정합니다.

**실행:**
```bash
bash gemini-cli-setup/01-setup-env.sh
source ~/.bashrc
```

**대화형 입력 항목:**
- API Provider 선택 (Google AI Studio / Vertex AI)
- `GEMINI_API_KEY` - API 키 (Google AI Studio 선택 시)
- `GOOGLE_CLOUD_PROJECT` + `GOOGLE_CLOUD_LOCATION` (Vertex AI 선택 시)
- 모델 선택 (gemini-2.5-pro / gemini-2.5-flash / 직접 입력)

**설정되는 환경변수:**

Google AI Studio:
```bash
GEMINI_API_KEY          # Google AI Studio API 키
GEMINI_MODEL            # 선택한 모델
```

Vertex AI:
```bash
GOOGLE_CLOUD_PROJECT    # GCP 프로젝트 ID
GOOGLE_CLOUD_LOCATION   # Vertex AI 리전
GEMINI_MODEL            # 선택한 모델
```

---

## 02-setup-mcp-servers.sh

`~/.gemini/settings/mcp.json`에 AWS MCP 서버를 등록합니다.

**실행:**
```bash
bash gemini-cli-setup/02-setup-mcp-servers.sh
```

**등록되는 MCP 서버:**

| 서버 | 패키지 | 기능 |
|------|--------|------|
| awslabs-terraform-mcp-server | `awslabs.terraform-mcp-server` | Terraform/Terragrunt AWS 인프라 개발 |
| awslabs-core-mcp-server | `awslabs.core-mcp-server` | AWS API, Cost Explorer, 다이어그램, 가격 분석 |
| bedrock-agentcore-mcp-server | `awslabs.amazon-bedrock-agentcore-mcp-server` | Bedrock AgentCore Gateway, Memory, Runtime |

**설정 파일:**
```
~/.gemini/settings/mcp.json
```

---

## 03-update-gemini.sh

Gemini CLI를 설치하거나 최신 버전으로 업데이트합니다.

**실행:**
```bash
bash gemini-cli-setup/03-update-gemini.sh
```

**동작:**
1. Node.js 설치 확인
2. 현재 버전 출력 (이미 설치된 경우)
3. `npm install -g @google/gemini-cli` 실행
4. 설치/업데이트 후 버전 출력

---

## 빠른 시작

```bash
# 1. Gemini CLI 설치
bash gemini-cli-setup/03-update-gemini.sh

# 2. 환경변수 설정
bash gemini-cli-setup/01-setup-env.sh
source ~/.bashrc

# 3. MCP 서버 설정
bash gemini-cli-setup/02-setup-mcp-servers.sh

# 4. Gemini CLI 실행
gemini
```

## 참고: Google AI Studio API 키 발급

1. [Google AI Studio](https://aistudio.google.com/apikey) 접속
2. "Create API Key" 클릭
3. 발급된 키를 01-setup-env.sh에서 입력
