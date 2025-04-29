# 實用設定

Git 的設定可以分成兩大類：`config` 設定和 `attributes` 設定。

- config ：設定 Git 的行為與使用習慣，**不針對**特定檔案。
- attributes ：設定 Git 在**處理特定檔案或目錄**時的行為，例如合併策略、匯出行為等。

## Git config

Git 有三個層級的設定檔，依照優先級由高至低排序如下：

1. `.git/config` （專案層級）
2. `~/.gitconfig`（使用 --global 參數，使用者層級）
3. `/etc/gitconfig`（使用 --system 參數，系統層級）

### 實用的設定項目

- `core.editor` ：設定 Git 預設的文字編輯器。
- `commit.template` ：設定 commit message 的預設模板。
- `user.signingkey` ：設定簽署用的 GPG 金鑰。
- `core.excludesfile` ：設定全域的忽略檔案（類似 .gitignore，但適用所有專案）。
- `help.autocorrect` ：自動修正輸錯的 Git 指令。
- `core.autocrlf` ：處理跨平台換行（CRLF 和 LF）問題。
- `core.hooksPath` ：指定 Git hooks 腳本的放置路徑。

## Git Attributes

Git Attributes 的設定檔有三個層級，依照優先級由高至低排序如下：

1. `/etc/gitattributes` ：系統層級設定。
2. `.gitattributes` ：版本控制的屬性設定，會隨專案一起被提交。
3. `.git/info/attributes` ：專案層級設定，但不會被版本控制。

### 實用屬性設定

- `export-ignore` ：在使用 git archive 指令時，忽略特定檔案或目錄。
- `merge=ours`： 指定特定檔案在合併衝突時，自動採用「本地版本」（ours）而忽略對方變更。

```{warning}
:class: dropdown
使用 merge=ours 前，需要先在 Git config 中定義 ours 合併驅動器，例如：  
``` bash
git config merge.ours.driver true
```

## Hook

Hook 的功能是在重要事件發生時觸發自訂腳本。下面列出常用的 `hook`

| Hook 名稱     | 執行時機               | 常見用途                                             |
|---------------|------------------------|------------------------------------------------------|
| pre-commit    | `git commit` 前        | 格式化程式碼、Lint 檢查、單元測試、阻止錯誤提交     |
| commit-msg    | commit 訊息輸入後      | 驗證訊息格式（如 Conventional Commits）             |
| pre-push      | `git push` 前          | 確認測試通過、限制推送、檢查 branch 名稱等         |
| post-checkout | 切換分支後             | 自動切換 .env、設定環境、執行初始化腳本等           |
