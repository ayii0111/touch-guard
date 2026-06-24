#!/usr/bin/env bash
set -e

INSTALL_PATH="/usr/local/bin/TouchGuard"
PLIST_PATH="/Library/LaunchDaemons/org.amanagr.TouchGuard.driver.Daemon.plist"
LABEL="org.amanagr.TouchGuard.driver.Daemon"
BINARY_URL="https://raw.githubusercontent.com/ayii0111/touch-guard/main/TouchGuard"
TIME="${1:-1}"

if [ "$EUID" -ne 0 ]; then
  echo "請用 sudo 執行：sudo bash install.sh"
  exit 1
fi

echo "▶ 下載 TouchGuard binary..."
curl -fsSL "$BINARY_URL" -o "$INSTALL_PATH"
xattr -d com.apple.quarantine "$INSTALL_PATH" 2>/dev/null || true
chmod +x "$INSTALL_PATH"

echo "▶ 安裝 LaunchDaemon（delay: ${TIME}s）..."
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
	<string>/var/log/TouchGuard.log</string>
	<key>StandardErrorPath</key>
	<string>/var/log/TouchGuard.log</string>
</dict>
</plist>
EOF

launchctl bootstrap system "$PLIST_PATH"

echo ""
echo "✅ TouchGuard 安裝完成（delay: ${TIME}s）"
echo ""
echo "⚠️  手動步驟（只需做一次）："
echo "   系統設定 → 隱私權與安全性 → 輔助使用 → 加入 Terminal"
