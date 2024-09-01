# 交通大學2024春季作業系統統整與實作 (Operating System Capstone, Spring 2024)

## 說明

1. 這是個紀錄關於這門課的Lab實做紀錄，要搭配 [課程網頁](https://nycu-caslab.github.io/OSC2024/index.html) 以及 [我的repository](https://github.com/gama79530/NYCU_2024_Operating_System_Capstone)
2. 課程使用的板子是 [raspberry 3b+](https://piepie.com.tw/19429/raspberry-pi-3-model-b-plus) ， 而我使用的是舊版的 [raspberry 3b](https://piepie.com.tw/10684/raspberry-pi-3-model-b)
3. 我每次在寫新的Lab時會先把前一個Lab稍微整理並視情況重構，所以有可能同樣的功能在後面的Lab的程式碼會有些許不同。但關於實做方式的核心實際上是一樣的。
4. 我在Ubuntu環境下開發，如果要在其他Linux平台上開發的話需要自行找到如何安裝對應的工具。而如果要在Windows環境開發需要安裝WSL。

## 重要文件 & 參考資料

### Doc

1. [Arm Architecture Reference Manual for A-profile architecture](https://developer.arm.com/documentation/ddi0487/latest/)
2. [BCM2837 ARM Peripherals](https://cs140e.sergio.bz/docs/BCM2837-ARM-Peripherals.pdf)

### github repository

1. [Learning operating system development using Linux kernel and Raspberry Pi](https://github.com/s-matyukevich/raspberry-pi-os)
2. [Bare Metal Programming on Raspberry Pi 3](https://github.com/bztsrc/raspi3-tutorial)

## Lab

1. [Lab 0: Environment Setup](Lab0/index.md)
2. [Lab 1: Hello World](Lab1/index.md)
3. [Lab 2: Booting](Lab2/index.md)

```{toctree}
:hidden:
:maxdepth: 2

Lab0/index
Lab1/index
Lab2/index
```
