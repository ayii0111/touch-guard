# TouchGuard

打字時自動暫時禁用 MacBook 觸控板，防止手掌誤觸造成游標跳位。

基於 [thesyntaxinator/TouchGuard](https://github.com/thesyntaxinator/TouchGuard)，由 [amanagr](https://github.com/amanagr/TouchGuard) 加入開機自動啟動，本 repo 再加上一鍵安裝腳本。

---

## 原理

每次按鍵後禁用觸控板一段時間（預設 0.5 秒），時間到自動恢復。
透過 macOS `CGEventTap` API 攔截系統事件，以 LaunchDaemon 方式在背景常駐。

---

## 相容性

- macOS 10.12+
- Intel / Apple Silicon（Rosetta 2）

---

## 安裝
- 預設按鍵壓按後阻擋秒數為 1 秒
```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/touch-guard/main/install.sh | sudo bash
```
安裝後需手動做一次：

> **系統設定 → 隱私權與安全性 → 輔助使用 → 加入 Terminal**

---

## 調整延遲秒數

不需重新安裝，直接換秒數並立即生效：(可改 0.5 秒)

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/touch-guard/main/set-time.sh | sudo bash -s -- 0.5
```
---

## 卸載

```bash
curl -fsSL https://raw.githubusercontent.com/ayii0111/touch-guard/main/uninstall.sh | sudo bash
```

---

## 確認是否運行中

```bash
sudo launchctl list | grep -i touch
```

有出現即代表正常運行。
