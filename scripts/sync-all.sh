#!/bin/bash
# 원본 동기화 + GitHub Push + Claude Plugin 업데이트 한 번에

PLUGIN_NAME="comply-cc"
MARKETPLACE_NAME="comply-cc-marketplace"
UPSTREAM_URL="https://github.com/affaan-m/everything-claude-code.git"

# 현재 브랜치 확인
current_branch=$(git branch --show-current)
if [ "$current_branch" != "main" ]; then
  echo "❌ main 브랜치에서 실행해주세요. 현재: $current_branch"
  exit 1
fi

# upstream remote 자동 설정
if ! git remote | grep -q "^upstream$"; then
  echo "🔧 upstream remote 설정 중..."
  git remote add upstream "$UPSTREAM_URL"
  echo "✅ upstream 추가됨: $UPSTREAM_URL"
fi

echo "📥 Fetching upstream..."
git fetch upstream

echo "🔀 Merging upstream/main..."
git merge upstream/main --no-edit

if [ $? -ne 0 ]; then
  echo "❌ Merge 충돌 발생. 수동 해결 필요."
  exit 1
fi

echo "📤 Pushing to origin..."
git push origin main

if [ $? -ne 0 ]; then
  echo "❌ Push 실패."
  exit 1
fi

echo "🔄 Updating Claude plugin..."
GITHUB_TOKEN=$(gh auth token) claude plugin update "${PLUGIN_NAME}@${MARKETPLACE_NAME}"

echo "✅ 완료!"
