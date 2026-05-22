#!/usr/bin/env bash
# 自怼同步脚本 — 检测变更后 git push 到 origin/main（GitHub Pages 源分支）
set -euo pipefail

REPO_DIR="D:/desktop/frist cc"
cd "$REPO_DIR"

# 拉取最新，确保可 fast-forward
git fetch origin main --quiet 2>/dev/null || true

# 检查本地是否有未推送的 commits
LOCAL=$(git rev-parse HEAD 2>/dev/null)
REMOTE=$(git rev-parse origin/main 2>/dev/null)

if [[ "$LOCAL" == "$REMOTE" ]]; then
  # 检查是否有未提交的变更（针对核心文件）
  if git diff --quiet fitness-dashboard.html 2>/dev/null; then
    exit 0  # 无变更，静默退出
  fi
fi

# 暂存核心文件（仅当有变更时）
git add fitness-dashboard.html 2>/dev/null || true

# 检查是否有东西需要提交
if git diff --cached --quiet 2>/dev/null; then
  # 没有新内容，但本地有未推送的 commits
  git push origin HEAD:main 2>&1 | tail -1
  exit 0
fi

# 提交（只在有暂存内容时）
COMMIT_MSG="auto-sync: $(date '+%Y-%m-%d %H:%M')"
git commit -m "$COMMIT_MSG" 2>&1 | tail -1

# 推送到 main
git push origin HEAD:main 2>&1 | tail -1
echo "[$(date '+%H:%M:%S')] 已同步到 GitHub Pages"
