# EC2 VSCode Server - Secure Architecture

AWS CDK / CloudFormation을 사용하여 보안이 강화된 VSCode Server + Claude Code 개발 환경을 배포합니다.

## Architecture

![VSCode on EC2 Architecture](VSCode%20on%20EC2.png)

```
User ──HTTPS──> CloudFront ──HTTP:80──> ALB (Custom Header) ──HTTP:8888──> EC2 (Private Subnet)
```

### 구성 요소

| 구성 요소 | 설명 |
|---------|------|
| VPC | 10.254.0.0/16 (신규 생성) 또는 기존 VPC 선택 |
| Public Subnet A/B | ALB, NAT Gateway |
| Private Subnet A/B | VSCode Server EC2 |
| CloudFront | HTTPS 종료, ALB 오리진 |
| ALB | CloudFront Prefix List + Custom Header 검증 |
| EC2 | code-server + Claude Code + Kiro CLI |

### 보안 기능

- **CloudFront Prefix List**: ALB Security Group에서 CloudFront origin-facing IP만 허용
- **X-Custom-Secret Header**: CloudFront에서 ALB로 전달되는 커스텀 헤더로 직접 ALB 접근 차단 (403)
- **Private Subnet**: VSCode Server가 Private Subnet에 배치되어 직접 인터넷 노출 없음
- **SSM VPC Endpoints**: Private Subnet에서 SSM Session Manager 접근 (SSH 불필요)
- **EBS 암호화**: 100GB gp3 볼륨 암호화 활성화

### EC2 UserData 설치 항목

| 항목 | 버전 |
|------|------|
| AWS CLI | v2 (latest) |
| Node.js | 20 (nodesource + fnm fallback) |
| Python3 + pip | boto3, click, bedrock-agentcore |
| code-server | v4.110.0 |
| Claude Code CLI | latest (@anthropic-ai/claude-code) |
| Claude Code Extension | Anthropic.claude-code (Open VSX) |
| Kiro CLI | latest |
| Docker | latest |
| uv | latest (Python package manager) |
| CloudWatch Agent | latest |
| SSM Plugin | latest |

## 프로젝트 구조

```
.
├── vscode_server_secure.yaml     # 메인 CloudFormation 템플릿
├── deploy_vscode.sh              # 대화형 CDK 배포 스크립트
├── README.md
├── VSCode on EC2.png
│
├── infra-cdk/                    # CDK TypeScript 프로젝트
│   ├── bin/app.ts                #   App 진입점
│   ├── lib/vscode-stack.ts       #   메인 스택 (VPC, ALB, EC2, CloudFront, SSM)
│   ├── package.json
│   ├── tsconfig.json
│   └── cdk.json
│
├── claude-code-setup/                # VSCode Server 내 Claude Code 환경 설정
│   ├── 01-setup-bedrock-env.sh   #   Bedrock 환경변수 설정
│   ├── 02-setup-vscode-settings.sh #  VS Code Extension 설정
│   ├── 03-setup-plugins-and-mcp.sh #  플러그인 + MCP 서버 설치
│   ├── 04-update-claude.sh       #   Claude Code 업데이트
│   ├── 05-setup-custom-plugin.sh #   커스텀 플러그인 설치
│   ├── mcp-toggle.sh             #   MCP 서버 ON/OFF TUI
│   └── CLAUDE_SETUP.md           #   상세 설정 가이드
│
├── templates/                    # 대체 CloudFormation 템플릿
│   ├── ec2vscode.yaml            #   기본 VPC 단순 배포
│   ├── ec2vscode_ubuntu.yaml     #   Ubuntu 기반
│   ├── vscode_existing_vpc.yaml  #   기존 VPC 배포
│   ├── vscode_server_ecs.yaml    #   ECS 기반
│   ├── vscode_server_multiuser.yaml # 멀티유저
│   ├── vscode_user_stack.yaml    #   유저별 Nested Stack
│   └── vscode_secure.yml         #   보안 강화 (S3 중첩)
│
└── legacy/                       # 레거시 헬퍼 스크립트
    ├── defaultvpcid.sh
    ├── deploy_vscode_existing_vpc.sh
    └── ...
```

## Prerequisites

- AWS CLI 설치 및 적절한 권한 (CloudFormation, EC2, ELB, CloudFront, IAM, SSM, S3)
- Node.js 20+ / npm
- (CDK 배포 시) CDK CLI 자동 설치됨

## Quick Start (CDK 배포 - 권장)

### 1. Repository Clone

```bash
git clone https://github.com/whchoi98/ec2_vscode.git
cd ec2_vscode
```

### 2. 대화형 배포 실행

```bash
bash deploy_vscode.sh
```

대화형으로 다음을 선택합니다:
- **계정**: 현재 자격 증명 / AWS 프로파일 / Access Key 직접 입력
- **리전**: 서울, 도쿄, 버지니아 등 12개 리전
- **VPC**: 새 VPC 생성 (10.254.0.0/16) 또는 기존 VPC 선택
- **인스턴스 타입**: ARM64 Graviton (기본 t4g.2xlarge) 또는 x86_64
- **비밀번호**: VSCode Server 접속 비밀번호 (8자 이상)

배포 완료 후 CloudFront URL과 SSM 접속 명령이 출력됩니다.

### 3. 접속

```bash
# 방법 1: 브라우저 (CloudFront URL)
# 배포 완료 시 출력된 URL로 접속, 비밀번호 입력

# 방법 2: SSM Session Manager
aws ssm start-session --target <InstanceId> --region <Region>
```

## Quick Start (CloudFormation 직접 배포)

```bash
# CloudFront Prefix List ID 조회
CF_PREFIX_LIST_ID=$(aws ec2 describe-managed-prefix-lists \
  --query "PrefixLists[?PrefixListName=='com.amazonaws.global.cloudfront.origin-facing'].PrefixListId" \
  --output text)

# 스택 배포
aws cloudformation deploy \
  --stack-name mgmt-vpc \
  --template-file vscode_server_secure.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    CloudFrontPrefixListId=$CF_PREFIX_LIST_ID \
    VSCodePassword="YourPassword123" \
  --region ap-northeast-2

# CloudFront URL 확인
aws cloudformation describe-stacks \
  --stack-name mgmt-vpc \
  --query "Stacks[0].Outputs[?OutputKey=='CloudFrontURL'].OutputValue" \
  --output text --region ap-northeast-2
```

## Parameters

| 파라미터 | 기본값 | 설명 |
|---------|-------|------|
| CloudFrontPrefixListId | (필수) | CloudFront origin-facing managed prefix list ID |
| InstanceType | t4g.2xlarge | EC2 인스턴스 타입 (ARM64/x86_64) |
| VSCodePassword | (필수) | VSCode Server 비밀번호 (최소 8자) |
| ExistingVpcId | (빈값) | 기존 VPC ID (CDK 배포 시, 빈값이면 새 VPC 생성) |

## Outputs

| Output | 설명 |
|--------|------|
| CloudFrontURL | VSCode Server 접속 URL (HTTPS) |
| InstanceId | EC2 Instance ID (SSM 접속용) |
| PrivateIP | EC2 Private IP |
| PublicALBEndpoint | ALB DNS (직접 접근 불가 - 403) |
| CustomHeaderSecret | CloudFront -> ALB 검증용 시크릿 |

## 스택 삭제

```bash
# CDK 배포인 경우
cd infra-cdk && npx cdk destroy VscodeServerStack --region <Region>

# CloudFormation 직접 배포인 경우
aws cloudformation delete-stack --stack-name mgmt-vpc --region ap-northeast-2
```

## Claude Code + Amazon Bedrock 설정

VSCode Server 배포 후 Claude Code를 Amazon Bedrock과 연동하기 위한 설정 스크립트입니다.
자세한 내용은 [claude-code-setup/CLAUDE_SETUP.md](claude-code-setup/CLAUDE_SETUP.md)를 참조하세요.

### 빠른 시작

```bash
# 1. Bedrock 환경변수 설정
bash claude-code-setup/01-setup-bedrock-env.sh
source ~/.bashrc

# 2. VS Code 확장 설정 (code-server 사용 시)
bash claude-code-setup/02-setup-vscode-settings.sh

# 3. 플러그인 + MCP 서버 설치
bash claude-code-setup/03-setup-plugins-and-mcp.sh

# 4. Claude Code 업데이트 (선택)
bash claude-code-setup/04-update-claude.sh

# 5. 커스텀 플러그인 설치 (선택)
bash claude-code-setup/05-setup-custom-plugin.sh
```

### 스크립트 목록

| 순서 | 스크립트 | 설명 |
|------|---------|------|
| 01 | `01-setup-bedrock-env.sh` | Bedrock 환경변수 (~/.bashrc) 설정 |
| 02 | `02-setup-vscode-settings.sh` | VS Code Extension (code-server) 설정 |
| 03 | `03-setup-plugins-and-mcp.sh` | 플러그인 26개 + AWS MCP 서버 3개 설치 |
| 04 | `04-update-claude.sh` | Claude Code CLI 업데이트 |
| 05 | `05-setup-custom-plugin.sh` | 커스텀 플러그인 (project-init) 설치 |
| - | `mcp-toggle.sh` | MCP 서버 ON/OFF 인터랙티브 TUI |
