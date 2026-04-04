#!/bin/bash

# Gemini CLI 환경변수 bashrc 설정 스크립트

BASHRC_FILE="$HOME/.bashrc"

echo "=== Gemini CLI 환경변수 설정 ==="
echo

# Provider 선택
echo "API Provider를 선택하세요:"
echo "  1) Google AI Studio (GEMINI_API_KEY)"
echo "  2) Google Cloud Vertex AI (프로젝트 + gcloud 인증)"
echo
read -p "선택 (1-2, 기본값: 1): " PROVIDER_CHOICE

case "$PROVIDER_CHOICE" in
    2)
        PROVIDER="vertex"
        echo "선택: Vertex AI"
        ;;
    *)
        PROVIDER="google-ai"
        echo "선택: Google AI Studio"
        ;;
esac

echo

# Provider별 설정
if [ "$PROVIDER" = "google-ai" ]; then
    read -p "GEMINI_API_KEY 값을 입력하세요: " API_KEY
    if [ -z "$API_KEY" ]; then
        echo "오류: GEMINI_API_KEY 값이 비어있습니다."
        echo "  Google AI Studio에서 발급: https://aistudio.google.com/apikey"
        exit 1
    fi

elif [ "$PROVIDER" = "vertex" ]; then
    read -p "GOOGLE_CLOUD_PROJECT (프로젝트 ID)를 입력하세요: " GCP_PROJECT
    if [ -z "$GCP_PROJECT" ]; then
        echo "오류: 프로젝트 ID가 비어있습니다."
        exit 1
    fi

    echo
    echo "Vertex AI Region을 선택하세요:"
    echo "  1) us-central1    (아이오와)"
    echo "  2) us-east1       (사우스캐롤라이나)"
    echo "  3) us-west1       (오레곤)"
    echo "  4) asia-northeast1 (도쿄)"
    echo "  5) asia-northeast3 (서울)"
    echo "  6) europe-west1   (벨기에)"
    echo
    read -p "선택 (1-6, 기본값: 1): " REGION_CHOICE

    case "$REGION_CHOICE" in
        2) GCP_LOCATION="us-east1" ;;
        3) GCP_LOCATION="us-west1" ;;
        4) GCP_LOCATION="asia-northeast1" ;;
        5) GCP_LOCATION="asia-northeast3" ;;
        6) GCP_LOCATION="europe-west1" ;;
        *) GCP_LOCATION="us-central1" ;;
    esac
    echo "선택된 리전: $GCP_LOCATION"
fi

# 모델 선택
echo
echo "사용할 모델을 선택하세요:"
echo "  1) gemini-2.5-pro   (최고 성능)"
echo "  2) gemini-2.5-flash (빠르고 경제적)"
echo "  3) 직접 입력"
echo
read -p "선택 (1-3, 기본값: 1): " MODEL_CHOICE

case "$MODEL_CHOICE" in
    2) SELECTED_MODEL="gemini-2.5-flash" ;;
    3)
        read -p "모델 ID를 입력하세요: " SELECTED_MODEL
        if [ -z "$SELECTED_MODEL" ]; then
            echo "오류: 모델 ID가 비어있습니다."
            exit 1
        fi
        ;;
    *) SELECTED_MODEL="gemini-2.5-pro" ;;
esac
echo "선택된 모델: $SELECTED_MODEL"

# 기존 설정 확인
if grep -q "# Gemini CLI 환경변수 설정" "$BASHRC_FILE" 2>/dev/null; then
    echo
    echo "기존 Gemini CLI 설정이 발견되었습니다."
    read -p "기존 설정을 덮어쓰시겠습니까? (y/n): " OVERWRITE
    if [ "$OVERWRITE" = "y" ] || [ "$OVERWRITE" = "Y" ]; then
        sed -i '/# Gemini CLI 환경변수 설정/,/^$/d' "$BASHRC_FILE"
        echo "기존 설정을 제거했습니다."
    else
        echo "설정을 취소합니다."
        exit 0
    fi
fi

# bashrc에 설정 추가
{
    echo ""
    echo "# Gemini CLI 환경변수 설정"

    if [ "$PROVIDER" = "google-ai" ]; then
        echo "export GEMINI_API_KEY='${API_KEY}'"
    elif [ "$PROVIDER" = "vertex" ]; then
        echo "export GOOGLE_CLOUD_PROJECT='${GCP_PROJECT}'"
        echo "export GOOGLE_CLOUD_LOCATION='${GCP_LOCATION}'"
    fi

    echo "export GEMINI_MODEL='${SELECTED_MODEL}'"
    echo ""
} >> "$BASHRC_FILE"

echo
echo "bashrc에 설정이 추가되었습니다."
echo
echo "  Provider: $PROVIDER"
echo "  Model:    $SELECTED_MODEL"
if [ "$PROVIDER" = "vertex" ]; then
    echo "  Project:  $GCP_PROJECT"
    echo "  Location: $GCP_LOCATION"
    echo
    echo "  Vertex AI를 사용하려면 gcloud 인증이 필요합니다:"
    echo "    gcloud auth application-default login"
fi
echo
echo "설정을 적용하려면 다음 명령어를 실행하세요:"
echo "  source ~/.bashrc"
