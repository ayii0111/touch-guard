#!/usr/bin/env bash
set -e

PLIST_PATH="/Library/LaunchDaemons/org.amanagr.TouchGuard.driver.Daemon.plist"
LABEL="org.amanagr.TouchGuard.driver.Daemon"
TIME="$1"

if [ "$EUID" -ne 0 ]; then
  echo "請用 sudo 執行：sudo bash set-time.sh <秒數>"
  exit 1
fi

if [ -z "$TIME" ]; then
  echo "用法：sudo bash set-time.sh <秒數>"
  echo "範例：sudo bash set-time.sh 0.3"
  exit 1
fi

if [ ! -f "$PLIST_PATH" ]; then
  echo "找不到 plist，請先執行 install.sh"
  exit 1
fi

echo "▶ 停止 TouchGuard..."
launchctl bootout system "$PLIST_PATH" 2>/dev/null || true

echo "▶ 更新 delay 為 ${TIME}s..."
# ponytail: sed -i '' is macOS BSD sed syntax
sed -i '' "s|<string>[0-9.]*</string>|<string>${TIME}</string>|3" "$PLIST_PATH"

echo "▶ 重新啟動 TouchGuard..."
launchctl bootstrap system "$PLIST_PATH"

echo "✅ TouchGuard delay 已更新為 ${TIME}s"
