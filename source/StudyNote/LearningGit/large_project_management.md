# 大型專案管理

大型專案裡面可能會使用其他專案的內容， git 提供了兩種管理方法

- submodule
- subtree

如果只是單純要導入某個專案，而**不需要負責其主要維護工作**，選用 `subtree merge` 會比較單純且易於管理。  
但如果**同時也是要導入的專案的貢獻者或維護者**，推薦選擇 `submodule` ，因為它能更精確地追蹤與同步版本，較為合適。

## submodule

Submodule 本身可以視為是一個獨立的 `Git repository` ，你可以在其中使用自己的版本控制操作（如 commit、branch、push 等）。
在現代 Git 中，submodule 的 Git 資料會被儲存在主專案的 `.git/modules/<submodule>` 資料夾中，而不是 submodule 工作目錄下的 `.git/`，但它依然是一個完整的 Git 倉庫。

主專案透過 `.gitmodules` 檔案來記錄 submodule 的路徑與來源 URL，讓 Git 知道如何初始化 submodule。而 submodule 的實際版本（commit ID）則記錄在主專案的 commit 中，用來指定 submodule 在那個 commit 時應該指向哪一個版本。

以下是 [ProGit 的範例](https://iissnan.com/progit/html/zh-tw/ch6_6.html)，要在主專案的 `rack` 子目錄導入在 `git://github.com/chneukirchen/rack.git` 的專案。

### 新增子模組

此指令會自動 clone submodule ，無需另外手動操作。

```bash
git submodule add git://github.com/chneukirchen/rack.git rack
```

### Submodule 更新

主專案是透過追蹤 submodule 的`特定 commit（即 HEAD 指向的 hash）` 來進行版本控制。
因此當你修改 submodule 的檔案時，主專案並不會直接偵測到變化，只有在 submodule 有執行如 **commit** 或 **checkout** 等會`改變 HEAD` 的操作時，主專案才會察覺變動。

變更 submodule 的 HEAD，可能原因如下：

- 修改程式並 commit
- 切換到其他版本
- pull 更新

```bash
# 在主專案中 stage 對 submodule 的指向變化，並 commit
git add rack
git commit -m "Update submodule to latest commit"
```

### Clone 有 submodule 的專案

`git submodule update` 會將 `working directory` 中的 submodule checkout 到主專案目前 commit 中所記錄的版本（也就是 Git index 中記錄的 submodule commit ID）。這可以理解為對 submodule 執行一次 checkout，切換到指定 commit，因此 submodule 的 HEAD 會變成 `detached` 狀態（若沒有 branch 指向該 commit）。

下面這段指令是當你 clone 了一個包含 submodule 的專案時要如何處理。

```bash
git clone <your-main-project>
cd <your-main-project>
git submodule update --init --recursive
```

## subtree merge

`subtree merge` 的想法是將另外一個專案映射到當前專案的子目錄下。由於 subtree merge 有可能不完整保留導入的專案的 commit 歷史，因此通常不建議直接修改引入的專案內容。

以下是 [ProGit 的範例](https://iissnan.com/progit/html/zh-tw/ch6_7.html)，要在主專案的 `rack` 子目錄導入在 `git@github.com:schacon/rack.git` 的專案。  

### 第一次將別的專案加入

1. 新增遠端 `git@github.com:schacon/rack.git` ，命名為 `rack_remote` 。
2. 使用 `rack_remote/master` 建立本地分支 `rack_branch` 。
3. 在主專案的 `master` 分支執行 `git read-tree` ，建立映射。
   - `--prefix=rack/` 指定將 `rack_branch` 內容匯入 `rack/` 子目錄。
   - `-u` 會更新 `index` 和工作目錄，但不會建立 `commit` ，因此需手動提交以紀錄變更。

```bash
# 將要導入的專案的 remote 加入並下載
git remote add rack_remote git@github.com:schacon/rack.git
git fetch rack_remote
git checkout -b rack_branch rack_remote/master

# 在主專案的 main branch 執行
git checkout master
git read-tree --prefix=rack/ -u rack_branch

# 留下紀錄
git commit -m "Add rack as a subtree"
```

### 更新專案

1. 切換到 `rack_branch` 分支，將相關的檔案更新。
2. 切換回主專案的分支並更新 subtree 的映射。
   - `--squash` 會把 `rack_branch` 的整個歷史變更壓縮成一個單一的 node
   - `-s subtree` 表示是要合併 subtree ，所以必須要先建立過 subtree 的映射才能使用。
   - `--no-commit` 會把檔案 `staged` ，但不會建立 commit 。

```bash
# 更新導入專案相關的檔案本身
git checkout rack_branch
git pull

# 更新在主專案裡面的映射
git checkout master
git merge --squash -s subtree --no-commit rack_branch
```

## submodule vs subtree 比較

| 特性 | submodule | subtree |
|------|-----------|---------|
| 操作簡單度 | 較複雜 | 較簡單 |
| 適合對象 | 同時維護雙方專案 | 僅引用其他專案 |
| Commit 歷史保留 | 保留完整歷史 | 可選擇壓縮 (`--squash`) |
| 相依同步控制 | 精確（指向特定 commit） | 自動同步較困難 |
| 可否獨立 clone | 可獨立為 repo | 需手動拆分 |
