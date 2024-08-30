# Lab 0

## 搭配材料

1. [Specification](https://nycu-caslab.github.io/OSC2024/labs/lab0.html)
2. [Code](https://github.com/gama79530/NYCU_2024_Operating_System_Capstone/tree/main/Lab0)

## 設定好環境

### Cross Compiler

因為Rpi3的CPU是[ARM Cortex-A53](https://en.wikipedia.org/wiki/ARM_Cortex-A53)，該CPU使用的[ISA](https://en.wikipedia.org/wiki/Instruction_set_architecture)是[Armv8-A](https://en.wikipedia.org/wiki/ARMv8-A)。而大部分的桌電不管使用AMD或是Intel都不是使用這個指令集，因此需要有一個cross compiler來把code編譯成可以在ARM Cortex-A53執行的程式。

### Linker

在[bare-metal programming](https://www.liquidweb.com/blog/what-is-bare-metal-programming/)的環境下，programmer需要主動管理memory layout。因此需要寫linker script去實現。

### QEMU

因為在跨平台的開發環境下，需要有一個模擬器來執行編譯過後的程式。因此需要安裝 [QEMU](https://en.wikipedia.org/wiki/QEMU)

```=bash
sudo apt install -y qemu-system-aarch64
```

### From Source Code to Kernel Image

把source code編譯成機器可執行的程式會經過下面階段

1. source code
2. [object files](https://en.wikipedia.org/wiki/Object_file)
3. [Executable and Linkable Format (ELF)](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format)
4. kernel image

### Deploy to REAL Rpi3

1. 要先準備一張 `micro SD` 並使用 `FAT32` 格式化出一個 `boot` 磁碟區  
   (不確定有沒有大小限制。實際使用的大小大概不會超過10MB，但我自己是切出4G大小)
2. 參考spec裡面的 [Flash Bootable Image to SD Card](https://nycu-caslab.github.io/OSC2024/labs/lab0.html#flash-bootable-image-to-sd-card) 的第2點來準備 `firmware`  
   (第1點的方法不能使用)
3. 使用 [Universal asynchronous receiver-transmitter (UART)](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter) 來連接板子與PC。
4. 參考spec的 [Interact with Rpi3](https://nycu-caslab.github.io/OSC2024/labs/lab0.html#interact-with-rpi3) 來設定UART。

### Debugging

1. 如果要直接在板子上debug的話需要在另外買一條線，所以這裡主要使用的方式是使用 `GDB` + `QEMU`
2. debugging 之前需要在編一時加入 `-g` flag，
3. 操作時要同時開兩個terminal，一個是負責用QEMU開啟 `kernel image` ，另外一個使用 GDB 開啟 `ELF`
4. 可以參考spec裡面的 [Debug on QEMU](https://nycu-caslab.github.io/OSC2024/labs/lab0.html#debug-on-qemu) ，或者是可以參考我在後續Lab的 `makefile` 裡面的 `debug-qemu` 與 `debug-gdb`

## 補充資料

1. [linker script 簡單教學](https://evshary.com/2018/06/02/linker-script-%E7%B0%A1%E5%96%AE%E6%95%99%E5%AD%B8/)
2. [10分鐘讀懂 linker scripts](https://blog.louie.lu/2016/11/06/10%E5%88%86%E9%90%98%E8%AE%80%E6%87%82-linker-scripts/)
