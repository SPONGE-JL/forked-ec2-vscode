# EC2 VSCode Server - Secure Architecture

AWS CloudFormation을 사용하여 보안이 강화된 VSCode Server를 배포합니다.

## Architecture

![VSCode on EC2 Architecture](VSCode%20on%20EC2.png)

### 구성 요소

| 구성 요소 | CIDR / 설명 |
|---------|------------|
| VPC | 10.254.0.0/16 |
| Public Subnet A | 10.254.11.0/24 (ALB, NAT Gateway) |
| Public Subnet B | 10.254.12.0/24 (NAT Gateway) |
| Private Subnet A | 10.254.21.0/24 (VSCode Server EC2) |

### 트래픽 흐름

```
User -> CloudFront (HTTPS) -> ALB (HTTP:80) -> EC2 VSCode Server (TCP:8888)
```

### 보안 기능

- **CloudFront Prefix List**: ALB Security Group에서 CloudFront origin-facing IP만 허용
- **X-Custom-Secret Header**: CloudFront에서 ALB로 전달되는 커스텀 헤더로 직접 ALB 접근 차단
- **Private Subnet**: VSCode Server가 Private Subnet에 배치되어 직접 인터넷 노출 없음
- **SSM VPC Endpoints**: Private Subnet에서 SSM Session Manager 접근 지원

### EC2 User-Data 설치 항목

- SSM Agent
- AWS CLI Latest
- Node.js 20, Python3
- Kiro CLI
- Claude Code
- code-server v4.110.0
- Development Tools (Util)

## Prerequisites

- AWS CLI 설치 및 적절한 권한 구성
- CloudFormation IAM 역할 생성 권한

## Quick Start

### 1. Repository Clone

```bash
git clone https://github.com/whchoi98/ec2_vscode.git
```

### 2. VSCode Server Password 설정

```bash
# VSCode Server Password를 변경하세요 (최소 8자 이상)
export VSCODE_PASSWORD='1234Qwer'
```

### 3. CloudFront Prefix List ID 조회

```bash
CF_PREFIX_LIST_ID=$(aws ec2 describe-managed-prefix-lists \
  --query "PrefixLists[?PrefixListName=='com.amazonaws.global.cloudfront.origin-facing'].PrefixListId" \
  --output text)
echo "CloudFront Prefix List ID = $CF_PREFIX_LIST_ID"
```

### 4. CloudFormation 스택 배포

```bash
aws cloudformation deploy \
  --stack-name mgmt-vpc \
  --template-file ~/ec2_vscode/vscode_server_secure.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    CloudFrontPrefixListId=$CF_PREFIX_LIST_ID \
    VSCodePassword="$VSCODE_PASSWORD" \
  --region ap-northeast-2
```

### 5. 접속

CloudFormation Output에 CloudFront URL이 자동 포함되어 있습니다. 배포 시 설정한 패스워드를 입력하세요.

```bash
aws cloudformation describe-stacks \
  --stack-name mgmt-vpc \
  --query "Stacks[0].Outputs[?OutputKey=='CloudFrontURL'].OutputValue" \
  --output text \
  --region ap-northeast-2
```

## Parameters

| 파라미터 | 기본값 | 설명 |
|---------|-------|------|
| CloudFrontPrefixListId | (필수) | CloudFront origin-facing managed prefix list ID |
| AvailabilityZoneA | ap-northeast-2a | 첫 번째 가용 영역 |
| AvailabilityZoneB | ap-northeast-2b | 두 번째 가용 영역 |
| VPCCIDRBlock | 10.254.0.0/16 | VPC CIDR |
| PublicSubnetABlock | 10.254.11.0/24 | Public Subnet A CIDR |
| PublicSubnetBBlock | 10.254.12.0/24 | Public Subnet B CIDR |
| PrivateSubnetABlock | 10.254.21.0/24 | Private Subnet A CIDR |
| PrivateSubnetBBlock | 10.254.22.0/24 | Private Subnet B CIDR |
| InstanceType | m7i.2xlarge | EC2 인스턴스 타입 |
| VSCodePassword | (필수) | VSCode Server 비밀번호 (최소 8자) |

## Outputs

| Output | 설명 |
|--------|------|
| CloudFrontURL | VSCode Server 접속 URL (HTTPS) |
| VSCodeServerInstanceId | EC2 Instance ID (SSM 접속용) |
| VSCodeServerPrivateIP | EC2 Private IP |

## SSM 접속

```bash
aws ssm start-session --target <VSCodeServerInstanceId>
```

## 스택 삭제

```bash
aws cloudformation delete-stack --stack-name mgmt-vpc --region ap-northeast-2
```

## Claude Code + Amazon Bedrock 설정 스크립트

VSCode Server 배포 후 Claude Code를 Amazon Bedrock과 연동하기 위한 설정 스크립트입니다.
자세한 내용은 [scripts/CLAUDE_SETUP.md](scripts/CLAUDE_SETUP.md)를 참조하세요.

### 빠른 시작

```bash
# 1. Bedrock 환경변수 설정
bash ~/ec2_vscode/scripts/01-setup-bedrock-env.sh
source ~/.bashrc

# 2. VS Code 확장 설정 (code-server 사용 시)
bash ~/ec2_vscode/scripts/02-setup-vscode-settings.sh

# 3. 플러그인 + MCP 서버 설치
bash ~/ec2_vscode/scripts/03-setup-plugins-and-mcp.sh

# 4. Claude Code 업데이트 (선택)
bash ~/ec2_vscode/scripts/04-update-claude.sh

# 5. 커스텀 플러그인 설치 (선택)
bash ~/ec2_vscode/scripts/05-setup-custom-plugin.sh
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
