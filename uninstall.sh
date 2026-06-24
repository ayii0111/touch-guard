#!/usr/bin/env bash
set -e

INSTALL_PATH="/usr/local/bin/TouchGuard"
PLIST_PATH="/Library/LaunchDaemons/org.amanagr.TouchGuard.driver.Daemon.plist"

if [ "$EUID" -ne 0 ]; then
  echo "請用 sudo 執行：sudo bash uninstall.sh"
  exit 1
fi

echo "▶ 停止 TouchGuard daemon..."
launchctl bootout system "$PLIST_PATH" 2>/dev/null || true

echo "▶ 移除檔案..."
rm -f "$PLIST_PATH"
rm -f "$INSTALL_PATH"

echo "✅ TouchGuard 已完全移除"
