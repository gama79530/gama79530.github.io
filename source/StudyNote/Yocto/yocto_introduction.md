# Yocto 基本介紹

## 如何開始一個 Yocto 專案

### 安裝相依的套件

首先需要先安裝好相依的套件，詳細內容可以參考
[Yocto Project Quick Build - Build Host Packages](https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html#build-host-packages) 。如果想要安裝其它版本的 Yocto 可以先從 [Yocto - Releases](https://www.yoctoproject.org/development/releases/) 去找到版本編號，接著把下面的網址的版本編號部份填上即可。

```{note}
https://docs.yoctoproject.org/<版本編號>/brief-yoctoprojectqs/index.html#build-host-packages

版本編號要完整到包含 `patch` 編號，所以像是 `Kirkstone` 的最後版本就要代入 `4.0.26`
```

### 新建一個 Yocto 專案
