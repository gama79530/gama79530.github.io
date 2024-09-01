# Lab 1: Hello World

## 搭配材料

1. [Specification](https://nycu-caslab.github.io/OSC2024/labs/lab1.html)
2. [Code](https://github.com/gama79530/NYCU_2024_Operating_System_Capstone/tree/main/Lab1)

## Lab 內容

這個lab的主要目的是要實做一個bare-metal programming版本的hello world程式。關於Assambly的語法只需要學習基礎的語法即可，可以看[Assembly language basics](https://developer.arm.com/documentation/107829/0200/Assembly-language-basics)或者直接問chatGPT

### Basic Exercise 1 - Basic Initialization

這個部份需要把`bootloader`給完成。因此需要把`linker.ld`與`boot.S`完成。

linker.ld的用途是要用來分配 kernel 程式的各個區段要如何佈局。裡面主要的語法有

```bash
# 指定當前的memory address為 0x80000
. = 0x80000

# 指定 ".text.boot" 這個區段的machine code要從assambly裡面定義的section ".text.boot" 取得
.text.boot : { *(.text.boot) }

# 指定當前的address必須以 0x8 為單位對齊， 這個對齊的動作主要與 str 指令會受到硬體限制有關。
. = ALIGN(0x8);

# 定義一個變數 bss_begin 並指定該變數的值為當前的address，定義這個變數是為了 "bss區段初始化" 時所需
bss_begin = .;

# 這個指令與上一個指令大部分狀況下是等價的，區別是這個變數在別的地方有定義過的話就不會覆蓋已經定義過的值
PROVIDE(bss_begin = .);
```

boot.S主要的工作是在進入主要的`main`function之前先行把必要的初始化完成。內容包括

1. 讓多餘的core做`busy waiting`  
   目前的Lab只需要使用到單核心，多餘的核心可能會造成錯誤
2. 將bss區段初始化成`'0'`
3. 設定stack pointer  
   基本上可以設定在任何位置，但設定在`_start`之前比較容易避免`stack`增長時會去錯誤的修改到已經在別的程式區段使用到的區域。
4. 呼叫`main`

### Basic Exercise 2 - Mini UART

我們要使用的是[BCM2837 ARM Peripherals](https://cs140e.sergio.bz/docs/BCM2837-ARM-Peripherals.pdf)提供的`mini UART`。這個部份需要將mini uart相關的[General-purpose input/output (GPIO)](https://en.wikipedia.org/wiki/General-purpose_input/output)做好初始化以及提供對應的服務。可以參考[Raspberry Pi devices](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/docs/lesson01/rpi-os.md#raspberry-pi-devices)或[Tutorial 03 - UART1, Auxilary mini UART](https://github.com/bztsrc/raspi3-tutorial/tree/master/03_uart1)這兩個教學文。我的程式是參考這兩個示範整理出來的，相關的程式在`mini_uart.h`與`mini_uart.c`裡面。

#### uart_init

mini UART與CPU溝通的方式是透過[Memory-mapped I/O](https://en.wikipedia.org/wiki/Memory-mapped_I/O_and_port-mapped_I/O)的方式來進行，初始化的實做就是透過MMIO將設定傳入對應的設備。詳細的設定可以參考[BCM2837 ARM Peripherals](https://cs140e.sergio.bz/docs/BCM2837-ARM-Peripherals.pdf)裡面的 `Chap 2` 與 `Chap 6`。

根據`The Raspberry Pi GPIO pinout guide.`的資訊，mini UART使用的是`GPIO pin 14`與`GPIO pin 15`。從BCM2837 ARM Peripherals的`Table 6-3`又可以看到我們要設定的位置是`GPFSEL1`的`14-12`bits與`17-15`bits。另外`Sec 2.2`以及`Sec 6.2`可以看到我們需要設定成`ALT 5`。

`GPIO pull-up/down`是一種用來確保GPIO pin的電壓可以被正確解讀成'0'與'1'的機制。關於`GPPUD`的處理就是與這個機制相關。可以參考BCM2837 ARM Peripherals的p100。主要是要設定好mini UART使用到的pin 14與pin 15。

最後關於mini uart的設定可以參考[Initializing the Mini UART](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/docs/lesson01/rpi-os.md#initializing-the-mini-uart)的教學。以及查詢BCM2837 ARM Peripherals的Chap 2

#### uart_putc & uart_getc

目前的作法是使用`polling`的方法。先從`AUX_MU_LSR_REG`來確認是否已有可以`讀/寫`在從對應的`AUX_MU_IO_REG`去`讀/寫`值。

### Basic Exercise 3 - Simple Shell

這一段程式碼是要實做一個簡單的`shell`，相關的程式碼在`shell.h`與`shell.c`。

### Basic Exercise 4 - Mailbox

`Mailbox`是一個ARM CPU與GPU之間的溝通機制，該機制也屬於MMIO的一種。可以參考[Spec: Mailbox](https://nycu-caslab.github.io/OSC2024/labs/hardware/mailbox.html#mailbox)、[raspberrypi/firmware: Mailbox](https://github.com/raspberrypi/firmware/wiki/Mailboxes)與[Tutorial 04 - Mailboxes](https://github.com/bztsrc/raspi3-tutorial/tree/master/04_mailboxes)，相關的程式碼在`mailbox.h`與`mailbox.c`。

在這個Lab中提到的`tag`可以從[Mailbox property interface](https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface)這裡查到。

### Advanced Exercise 1 - Reboot

這個部份主要參考[Tutorial 08 - Power management](https://github.com/bztsrc/raspi3-tutorial/tree/master/08_power)，相關的程式碼在`power.h`與`power.c`。有一個網站有紀錄相關的MMIO位址，但是來源不是很清楚。實在找不到很明確的官方文件有寫有紀錄，所以基本上是照抄作法。

## 參考 & 補充資料

1. [1.1: Introducing RPi OS, or bare-metal "Hello, World!"](https://github.com/s-matyukevich/raspberry-pi-os/blob/master/docs/lesson01/rpi-os.md)
2. [Introduction to ARM Assembly Basics](https://azeria-labs.com/writing-arm-assembly-part-1/)
3. [Getting Started with Arm Assembly Language Version 2.0](https://developer.arm.com/documentation/107829/0200)
4. [Universal asynchronous receiver-transmitter (UART)](https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter)
5. [The Raspberry Pi GPIO pinout guide](https://pinout.xyz/)
6. [Using PullUp and PullDown Resistors on the Raspberry Pi](https://grantwinney.com/raspberry-pi-using-pullup-and-pulldown-resistors/)
7. [Mailboxes](https://github.com/raspberrypi/firmware/wiki/Mailboxes)
8. [Unit BCM2837](https://ultibo.org/wiki/Unit_BCM2837)
9. [浅谈ARM64汇编](https://leylfl.github.io/2018/05/15/%E6%B5%85%E8%B0%88ARM64%E6%B1%87%E7%BC%96/)
