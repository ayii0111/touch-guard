#!/usr/bin/env bash
set -e

# LaunchAgent：跑在使用者登入 session，不需要 sudo（CGEventTap 只需輔助使用權限）
INSTALL_PATH="$HOME/.local/bin/TouchGuard"
PLIST_PATH="$HOME/Library/LaunchAgents/org.amanagr.TouchGuard.driver.Agent.plist"
LABEL="org.amanagr.TouchGuard.driver.Agent"
LOG_PATH="$HOME/Library/Logs/TouchGuard.log"
BINARY_URL="https://raw.githubusercontent.com/ayii0111/touch-guard/main/TouchGuard"
TIME="${1:-1}"

if [ "$EUID" -eq 0 ]; then
  echo "請『不要』用 sudo 執行（LaunchAgent 要以你的帳號安裝）：bash install.sh"
  exit 1
fi

echo "▶ 下載 TouchGuard binary..."
mkdir -p "$(dirname "$INSTALL_PATH")" "$(dirname "$PLIST_PATH")"
curl -fsSL "$BINARY_URL" -o "$INSTALL_PATH"
xattr -d com.apple.quarantine "$INSTALL_PATH" 2>/dev/null || true
chmod +x "$INSTALL_PATH"

echo "▶ 安裝 LaunchAgent（delay: ${TIME}s）..."
cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>${LABEL}</string>
	<key>RunAtLoad</key>
	<true/>
	<key>KeepAlive</key>
	<true/>
	<key>Program</key>
	<string>${INSTALL_PATH}</string>
	<key>ProgramArguments</key>
	<array>
		<string>${INSTALL_PATH}</string>
		<string>--startupDelay</string>
		<string>1000000</string>
		<string>--notificationDelay</string>
		<string>20000</string>
		<string>-time</string>
		<string>${TIME}</string>
	</array>
	<key>StandardOutPath</key>
	<string>${LOG_PATH}</string>
	<key>StandardErrorPath</key>
	<string>${LOG_PATH}</string>
</dict>
</plist>
EOF

launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH"

echo ""
echo "✅ TouchGuard 安裝完成（delay: ${TIME}s）"
echo ""
echo "⚠️  會顯示授權，按允許後，把 TouchGuard 勾選起來"
# echo "⚠️  手動步驟（只需做一次，否則不會生效）："
# echo "   系統設定 → 隱私權與安全性 → 輔助使用 → 按「+」"
# echo "   → 跳出視窗按 Cmd+Shift+G → 貼上：${INSTALL_PATH}"
# echo "   → 加入後把開關打開"
