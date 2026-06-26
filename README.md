# TouchGuard

打字時自動暫時禁用 MacBook 觸控板，防止手掌誤觸造成游標跳位。

基於 [thesyntaxinator/TouchGuard](https://github.com/thesyntaxinator/TouchGuard)，由 [amanagr](https://github.com/amanagr/TouchGuard) 加入開機自動啟動，本 repo 再加上一鍵安裝腳本，並改用 **LaunchAgent**（以使用者身份常駐，輔助使用權限好授權、不需 sudo）。

---

## 原理

每次按鍵後禁用觸控板一段時間（預設 1 秒），時間到自動恢復。
透過 macOS `CGEventTap` API 攔截系統事件，以 LaunchAgent 方式在登入後背景常駐。

---

## 相容性

- macOS 10.12+
- Intel / Apple Silicon（Rosetta 2）

---

## 安裝

- 預設按鍵壓按後阻擋秒數為 1 秒
- **不要加 sudo**（LaunchAgent 要以你自己的帳號安裝）

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/touch-guard/main/install.sh | bash
```

安裝後**必做一次**（否則不會生效）：

> **系統設定 → 隱私權與安全性 → 輔助使用 → 按「+」 → 跳出視窗按 `Cmd+Shift+G` → 貼上 `~/.local/bin/TouchGuard` → 加入後打開開關**

⚠️ 權限要給的是 **TouchGuard binary 本身**，不是 Terminal。daemon 由系統直接啟動，跟 Terminal 無關。

---

## 調整延遲秒數

不需重新安裝，直接換秒數並立即生效：(可改 0.5 秒)

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/touch-guard/main/set-time.sh | bash -s -- 0.5
```

---

## 卸載

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/touch-guard/main/uninstall.sh | bash
```

---

## 確認是否運行中

```bash
launchctl list | grep -i touchguard
```

有出現即代表正常運行。看 log：

```bash
cat ~/Library/Logs/TouchGuard.log
```

出現 `Disable interval 1000 milliSeconds` 代表已啟動並取得權限。
