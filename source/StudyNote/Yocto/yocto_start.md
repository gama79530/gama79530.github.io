# 如何開始一個 Yocto 專案

### 安裝相依的套件

首先需要先安裝好相依的套件，詳細內容可以參考
[Yocto Project Quick Build - Build Host Packages](https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html#build-host-packages) 。

如果想使用其他版本的 Yocto 可以先從 [Yocto - Releases](https://www.yoctoproject.org/development/releases/) 去找到版本編號，接著將下方網址中的`版本編號`替換即可
接著把下面的網址的版本編號部份填上即可。

```{note}
https://docs.yoctoproject.org/<版本編號>/brief-yoctoprojectqs/index.html#build-host-packages

版本編號要完整到包含 `patch` 編號，所以像是 `Kirkstone` 的最後版本就要代入 `4.0.26`
```

### 新建一個 Yocto 專案

建立 Yocto 專案時，通常以 Yocto 的 `Poky` 專案作為基礎。  
這是 Yocto 的示範專案，也包含 BitBake、Devtool 等 Yocto 所需的自動化工具。

Poky 可以從兩個網站取得:
- [Yocto Project - source repositories](https://git.yoctoproject.org/) 裡面的 `index - Poky` : 官方的 repository
- [GitHub - poky](https://github.com/yoctoproject/poky) : 上述網站的鏡像，因此更新可能會略慢。

最簡單的方法是透過 `git clone` 將 Poky 複製下來後開始修改，  
但這樣會將 Yocto 的 commit 歷史一併納入，可能會讓自己專案的版本管理變得複雜。

因此，建議直接下載 source code 使用會更單純。  
這兩個網站上每個主要版本都有對應的 branch，也可以透過 tag 來選擇特定版本。

### 補充 - 如何在 WSL 上使用

只要確定你使用的是 `WSL2`，  
接著參考官方文件：[2.2.3 Setting Up to Use Windows Subsystem For Linux (WSL 2)](https://docs.yoctoproject.org/dev-manual/start.html#setting-up-to-use-windows-subsystem-for-linux-wsl-2) 

```{note}
請特別注意第 2.6 節的說明，用於設定 `VHDX` 檔案位置與儲存空間大小。
```
