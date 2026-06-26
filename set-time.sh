#!/usr/bin/env bash
set -e

PLIST_PATH="$HOME/Library/LaunchAgents/org.amanagr.TouchGuard.driver.Agent.plist"
LABEL="org.amanagr.TouchGuard.driver.Agent"
TIME="$1"

if [ "$EUID" -eq 0 ]; then
  echo "請『不要』用 sudo 執行：bash set-time.sh <秒數>"
  exit 1
fi

if [ -z "$TIME" ]; then
  echo "用法：bash set-time.sh <秒數>"
  echo "範例：bash set-time.sh 0.3"
  exit 1
fi

if [ ! -f "$PLIST_PATH" ]; then
  echo "找不到 plist，請先執行 install.sh"
  exit 1
fi

echo "▶ 停止 TouchGuard..."
launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true

echo "▶ 更新 delay 為 ${TIME}s..."
# ponytail: sed -i '' 是 macOS BSD sed 語法；第 3 個純數字 <string> 就是 -time 的值
sed -i '' "s|<string>[0-9.]*</string>|<string>${TIME}</string>|3" "$PLIST_PATH"

echo "▶ 重新啟動 TouchGuard..."
launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH"

echo "✅ TouchGuard delay 已更新為 ${TIME}s"
