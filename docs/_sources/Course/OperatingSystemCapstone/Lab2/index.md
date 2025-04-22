# Lab 2: Booting

## 搭配材料

1. [Specification](https://nycu-caslab.github.io/OSC2024/labs/lab2.html)
2. [Code](https://github.com/gama79530/NYCU_2024_Operating_System_Capstone/tree/main/Lab2)

## Lab 內容

這個Lab的主要目的有幾個

1. 將`bootloader`與`kernel`分離。
2. 提供kernel一個`Initial Ramdisk`
3. 實做一個簡單的記憶體空間分配器
4. 使用`Devicetree`

### Basic Exercise 1 - UART Bootloader

這個部份主要的工作是要將`bootloader`與`kernel`分離，這麼做的最大好處是以後要在板子上跑剛寫好的程式的時候只需要插著uart把新的image file傳入後再載入即可。要達到這個目的，需要3個程式如下:

1. `uploader`: 負責通過uart "與`bootloader`溝通" 以及 "將`kernel image`傳輸到Rpi3"。相關的程式都在`uploader`資料夾下。
2. `bootloader` (之後都用`loader`簡稱): 負責作為最初開機後執行的程式，提供最基礎的利用uart "與`uploader`溝通" 以及 "將`uploader`上傳的 `kernel image` 載入記憶體並執行"。相關的程式都在`loader`資料夾下。因為我後續Lab主要會使用[Advanced Exercise 1](https://gama79530.github.io/Course/OperatingSystemCapstone/Lab2/index.html#advanced-exercise-1-bootloader-self-relocation)的方法，所以`basic`只點到為止。可以直接參考`Advanced`的作法。
3. `kernel image`: 實際要執行的程式。相關的程式都在`kernel`資料夾下。

#### uploader

`uploader`是利用`pySerial`這個package來實做。只要先把serial的`port`與`baudrate`設定好之後就可以開始與`loader`溝通傳輸資料。關於port的設定因為我是使用Ubuntu所以是`/dev/ttyUSBX`，如果是其他平台需要去找USB對應的port。而`baudrate`可以參考[Mini UART](https://nycu-caslab.github.io/OSC2024/labs/hardware/uart.html#mini-uart)。因為pySerial這個傳輸資料的工具並沒有interrupt的機制，所以當程式開始傳輸一段資料時就只能等整段資料都傳輸完。因此我搭配了`Linux`的`select`這個`multiplexing`機制來完成互動溝通。

#### bootloader

`loader`也是一個小型的kernel程式。loader只需要提供基本的mini_uart IO功能，之後透過mini_uart 去與uploader溝通以取得真正的kernel程式並啟動執行。相關的程式可以從`shell.c`裡面的`command_download`與`command_boot`這兩個function作為起點去參考。

在這個部份我們需要通過`config.txt`去告訴`Rpi3` loader要載入到記憶體的哪個位址。以及`kernel image`的檔案名稱，因為Rpi3預設是在`0x80000`開始執行kernel且預設檔名為`kernel8.img`，所以必須用這個檔案告訴Rpi3我們的loader是在`0x60000`以及loader的檔案名稱。之後會將kernel image下載到 0x80000 後跳到該處開始執行真正的kernel。

#### 溝通機制

這個部份可以自由設計`uploader`與`loader`之間傳輸`kernel image`的機制。我設計的溝通方式如下

1. `uploader`發送字串`"download\n"`給`loader`。
2. `loader`通過發送`"$upload_kernel$\n"`給`uploader`來啟動下載`kernel image`的流程。
3. `uploader`接收到`"$upload_kernel$\n"`字串後將`kernel image`的檔案大小用1個`4 bytes, little-endian`的整數發送給`loader`。
4. `loader`接受到**檔案大小**後回傳一個`"start_upload$"`字串作為回應。
5. `uploader`接收到`"start_upload$"`字串後開始上傳`kernel image`。
6. `loader`接收完完整的`kernel image`後回傳一個字串`"done$"`作為回應。
7. `uploader`接收到`"done$"`後整個下載流程結束。

### Basic Exercise 2 - Initial Ramdisk

`kernel`在啟動檔案系統之前，可能會有一些檔案已經需要先載入記憶體中。因此需要有一個簡易的機制來將檔案載入。Rpi3可以在`config.txt`中設定`initramfs`的`檔案名稱`與`記憶體位址`，用來指定要將SD卡的那一個檔案預先載入記憶體。在這個部份裡我們是使用`CPIO - New ASCII Format`來打包檔案。要如何去讀檔案內容可以參考`cpio.h`與`cpio.c`裡面的程式。

在這個Lab裡`initramfs`的檔案我們是使用`cpio`這個工具來打包檔案。這個檔案必須與`loader`一起放到micro SD卡裡面。我的做法是先將要開啟的檔案放到`loader/advanced/rootfs`資料夾之下。在編譯loader的時候同時也會使用指令打包成`initramfs.cpio`這個檔案。這個檔案必須跟著loader的image一起放到micro SD卡裡。關於打包的指令可以參考`loader/advanced/makefile`。

### Basic Exercise 3 - Simple Allocator

這個部份需要一個簡易的`malloc`，只需要找到一塊沒有被使用的記憶體區段做分配就可以。可以參考`memory.h`與`memory.c`。

### Advanced Exercise 1 - Bootloader Self Relocation

在這個部份與basic的不同之處只在於一開始的loader也不透過'config.txt'指定`loader`的位址。因此loader會被載入到預設的`0x80000`。因此在進入'loader'的`main`之前需要先把loader的內容複製到`0x60000`。之後在執行複製過後的程式碼。與原本的作法相比主要變動的部份在`linker.ld`與`boot.S`。

### Advanced Exercise 2 - Devicetree

`Device tree`是一個用來描述電腦系統有哪些週邊設備以及其性質的檔案。`dts`是compile之前的source檔案，可以從[這裡](https://github.com/raspberrypi/linux/tree/rpi-5.10.y/arch/arm64/boot/dts/broadcom)找到Rpi各個系列的檔案。`dtb`則是已經compile之後的檔案，可以從[這裡](https://github.com/raspberrypi/firmware/tree/master/boot)找到對應的檔案。我使用的板子是Rpi3b，所以要下載的檔案是`bcm2710-rpi-3-b.dtb`這個檔案。這個檔案也必須放入micro SD裡面。關於讀取device tree的程式可以參考`dtb.h`以及`dtb.c`。

Rpi3b在啟動時會自動把device tree所在的記憶體位址放在`x0`這個register。因此在loader或者kernel進入`main function`之前如果會需要使用該register的話要先將的值先存到別的register，並且在呼叫之前把值還原回去。因為ARM會把`x0`用在function call，所以`main`需要新增一個傳入參數讓後去用C語言寫的DTB處理程式可以收到這個位址。

## 參考 & 補充資料

1. [Welcome to pySerial’s documentation](https://pyserial.readthedocs.io/en/latest/)
2. [FreeBSD Manual Pages](https://man.freebsd.org/cgi/man.cgi?query=cpio&sektion=5)
3. [article: Device Tree](https://hackmd.io/@0xff07/r1cJFN4QD)
4. [arm community: Device Tree](https://community.arm.com/oss-platforms/w/docs/525/device-tree)
5. [ARM Parameters in general-purpose registers](https://blog.csdn.net/u014100559/article/details/113105083)
