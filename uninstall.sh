#!/usr/bin/env bash
set -e

INSTALL_PATH="$HOME/.local/bin/TouchGuard"
PLIST_PATH="$HOME/Library/LaunchAgents/org.amanagr.TouchGuard.driver.Agent.plist"
LABEL="org.amanagr.TouchGuard.driver.Agent"

if [ "$EUID" -eq 0 ]; then
  echo "請『不要』用 sudo 執行：bash uninstall.sh"
  exit 1
fi

echo "▶ 停止 TouchGuard agent..."
launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true

echo "▶ 移除檔案..."
rm -f "$PLIST_PATH"
rm -f "$INSTALL_PATH"

echo "✅ TouchGuard 已完全移除"
echo "（輔助使用清單裡的殘留項可自行到系統設定移除）"
