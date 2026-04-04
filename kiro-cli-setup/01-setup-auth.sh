#!/bin/bash

# Kiro CLI 인증 설정 스크립트

echo "=== Kiro CLI 인증 설정 ==="
echo
echo "Kiro CLI는 브라우저 기반 인증을 사용합니다."
echo
echo "지원되는 인증 방법:"
echo "  - GitHub"
echo "  - Google"
echo "  - AWS Builder ID"
echo "  - AWS IAM Identity Center (엔터프라이즈)"
echo "  - 외부 IdP (Okta, Microsoft Entra ID 등)"
echo

# 로그인 상태 확인
if kiro-cli chat --no-interactive "echo test" >/dev/null 2>&1; then
    echo "✅ 이미 로그인되어 있습니다."
    echo
    read -p "다시 로그인하시겠습니까? (y/n, 기본값: n): " RELOGIN
    if [ "$RELOGIN" != "y" ] && [ "$RELOGIN" != "Y" ]; then
        echo "기존 인증을 유지합니다."
        exit 0
    fi
fi

echo "브라우저에서 인증을 진행합니다..."
echo
echo "※ 원격 서버(SSH)에서 실행 중이라면:"
echo "  1) kiro-cli login 실행 후 표시되는 포트 번호를 확인"
echo "  2) 로컬에서 포트 포워딩: ssh -L <PORT>:localhost:<PORT> -N user@remote-host"
echo "  3) 브라우저에서 표시된 URL을 열어 인증 완료"
echo

kiro-cli login

echo
echo "=== 인증 완료 ==="
