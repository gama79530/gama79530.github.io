# Yocto 基本介紹

Yocto 是一個開源專案，提供了一個用於**製作以 Linux 為基礎的系統（通常是嵌入式系統）**的框架（framework）。在製作以 Linux 為基礎的系統時，常會遇到以下問題：

1. 需要安裝哪些軟體？這些軟體之間是否有相依性？
2. 要從哪裡取得相關資源？
3. 要如何安裝這些軟體？應該安裝到哪個位置？

Yocto 提供了一套規範與相關工具，用來更有效地管理這些問題。同時，Yocto 專案也提供了一套基礎模板，讓開發者在製作客製化系統時有良好的切入起點。Yocto 使用者應避免「重新造輪子」，而應該著重於如何善用既有的套件與元件。因此在使用 Yocto 時，非必要情況下不會去修改所使用的套件（package）。

```{tip}
:class: dropdown

在 Yocto 中修改套件原始碼（package source）通常出於以下原因：

1. 修補重大 bug，無法等待上游修復。
2. 配合專案需求進行客製化，例如：加入新功能、修改預設行為，或移除不必要的功能以精簡系統。
3. 處理授權相容性問題，或補充缺失的 license 宣告。
```

## Yocto 相關術語

以下是我根據官方術語介紹所精煉的描述：

### Metadata

Metadata 是 Yocto Project 中用來建構 Linux 發行版的所有建構資訊的總稱。這些資訊包含：

- 程式套件的 recipe
- 系統與建構的組態設定（Configuration files）
- 程式套件的來源、版本與相依性
- 套用於程式套件的修補（patch）或額外檔案
- 控制建構流程與行為的參數與命令

這些 Metadata 分散於不同的 Layer 中。OpenEmbedded-Core（oe-core）即為一組經過驗證的 Metadata。

### Packages

Packages 是 build system 的輸出結果，代表一個個可安裝的軟體單元（如 `.ipk`、`.deb`、`.rpm` 等格式）。這些套件會被用來：

- 製作最終的系統映像檔（Image）
- 安裝到目標系統中

### Extensible Software Development Kit (ESDK)

ESDK 是一組可擴充的開發工具組，提供給應用程式開發人員使用，讓他們能在不依賴完整 Yocto Build 系統的情況下，針對目標平台進行開發、建構與封裝。開發者也可以透過 ESDK 修改或擴充現有的套件，並將變更整合回原始映像檔。

### Image

Image 是以二進位格式產生的作業系統映像檔，通常會被燒錄到硬體裝置上，用來啟動目標系統。

### Configuration Files

Configuration files 為 Yocto 提供建構過程中的變數與設定。內容包含：

- 官方定義的變數（如 `MACHINE`, `DISTRO`, `IMAGE_FEATURES` 等）
- 使用者自定義的變數
- 與目標平台或硬體相關的組態設定

這些設定檔會告訴 Build System 要建構什麼、如何建構，以及要支援哪些功能。

### Layer

Layer 是 Yocto 用來組織 recipes 的單位。每個 Layer 包含一組功能相關的 recipes、設定與檔案。Layer 可用來：

- 客製化系統功能
- 支援多架構（如 x86, ARM）
- 分離開發與社群貢獻的 Metadata

Yocto 允許使用多個 Layer 並透過 Layer 優先權機制進行覆蓋與整合。

### Recipe

Recipe 是最基本的 Metadata 單元，用來描述如何建構單一套件。內容通常包含：

- 原始碼來源（如 Git、tarball）
- 套用的 patches
- 相依套件
- configure、compile、install 等建構步驟的指令
- 安裝路徑與檔案管理

Recipe 通常儲存在 Layer 中，並以 `.bb` 為副檔名。

### Build System – BitBake

BitBake 是 Yocto 的建構引擎，負責解析 recipes 與設定檔、建立相依樹、排程與執行建構流程。它類似 `make`，但更適合複雜的交叉編譯環境。特點如下：

- 分析所有 Metadata（recipes、class、設定）
- 執行交叉編譯流程
- 建構出完整的套件與映像檔
- 支援原生編譯與目標平台編譯工具鏈的建構

### OpenEmbedded-Core (oe-core)

OpenEmbedded-Core 是 OpenEmbedded 專案中被精選出來的一組核心 metadata，包含：

- 基本系統建構所需的 recipes、class 與設定檔
- 經過驗證與持續維護，品質穩定
- 被多數 Yocto-based 發行版所共用

在 Poky 中，oe-core 通常放在 `meta` 這個 Layer 之中。

### Poky

Poky 是 Yocto Project 提供的參考整合層（reference distribution），具備以下目的：

1. 提供可客製化的基礎發行版本
2. 驗證 Yocto 各元件的功能與整合性
3. 作為使用者下載與學習 Yocto 的入門範例

Poky 包含 BitBake、oe-core、meta-poky 等多個 Layer，是 Yocto 官方維護的整合範例。
