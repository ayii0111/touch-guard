# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 這是什麼

打字時自動暫時禁用 MacBook 觸控板，防止手掌誤觸。核心是**預編譯的 `TouchGuard` binary**（無原始碼於本 repo，來自上游 thesyntaxinator → amanagr），本 repo 只負責「打包成 macOS **LaunchAgent** 並提供一鍵安裝/卸載/調整腳本」。

binary 用 `CGEventTap` 攔截系統按鍵事件，每次按鍵後禁用觸控板 `-time` 秒，到時自動恢復。

## 為什麼是 LaunchAgent（不是 LaunchDaemon）

`CGEventTap` 需要「輔助使用」(Accessibility) 權限，而該權限**無法用腳本授權**（TCC 受 SIP 保護，是 macOS 硬性限制）。
- LaunchDaemon 以 root 在 system domain 跑，替 root daemon 授權輔助使用很難生效。
- 改用 **LaunchAgent**：跑在使用者 GUI session、用使用者身份，**不需 sudo**，授權對象就是 binary 本身，標準流程就會生效。

權限要給的是 **`~/.local/bin/TouchGuard` 這支 binary**，不是 Terminal。手動跑 binary 能動只是借了 Terminal 的權限，daemon 由系統直接啟動跟 Terminal 無關——這是上一版 README 講錯的地方。

## 架構重點

安裝是「下載 binary + 寫一份 LaunchAgent plist + bootstrap 到 gui domain」三步，散在三個腳本，全部**以一般使用者身份執行（不可加 sudo）**：

- `install.sh` — 從 `BINARY_URL`（GitHub raw）下載 binary 到 `~/.local/bin/TouchGuard`，**動態產生** plist 到 `~/Library/LaunchAgents/`，`launchctl bootstrap gui/$(id -u)` 啟動。延遲秒數從 `$1` 帶入（預設 1）。
- `set-time.sh <秒數>` — 不重裝改延遲：`bootout` → `sed` 改 plist「第 3 個純數字 `<string>`」→ `bootstrap`。
- `uninstall.sh` — `bootout` + 刪 plist 與 binary。

關鍵常數在三個腳本各自重複定義（`INSTALL_PATH` / `PLIST_PATH` / `LABEL` = `org.amanagr.TouchGuard.driver.Agent`），改路徑或 Label 要三處同步。

### binary 的命令列參數（plist 內固定寫死）
`--startupDelay 1000000 --notificationDelay 20000 -time <秒數>`。只有 `-time` 是使用者會調的；其餘來自上游預設。

### `set-time.sh` 的 sed 為何是「第 3 個」
正規式 `<string>[0-9.]*</string>` 只匹配**純數字** string。plist 裡純數字 string 依序是 `1000000`(1)、`20000`(2)、`<時間>`(3)，所以第 3 個就是 `-time` 的值。改 plist 結構時要留意這個隱性依賴。

### 陷阱：寫死的 repo URL
腳本內所有 GitHub raw URL 寫死 `ayii0111/touch-guard`（README 也是）。Fork 或改 repo 名要一起換，否則 `curl | bash` 會抓到別人的 binary。

## 常用指令（皆不加 sudo）

```bash
# 安裝（延遲秒數可選，預設 1）
bash install.sh 0.5

# 改延遲、立即生效（不重裝）
bash set-time.sh 0.3

# 卸載
bash uninstall.sh

# 確認是否運行中
launchctl list | grep -i touchguard

# 看 log（出現 "Disable interval ..." 代表已啟動且拿到權限）
cat ~/Library/Logs/TouchGuard.log
```

## 安裝後手動步驟（必做一次，否則不生效）
系統設定 → 隱私權與安全性 → 輔助使用 → 按「+」→ `Cmd+Shift+G` → 貼上 `~/.local/bin/TouchGuard` → 加入後打開開關。

## 腳本慣例
- macOS BSD sed：`sed -i ''`（需空字串參數，與 GNU sed 不同）。
- 全部 `set -e`，且開頭檢查**不可為 root**（`$EUID -eq 0` 就擋掉）。
