# Lab 3: Exception and Interrupt

## 搭配材料

1. [Specification](https://nycu-caslab.github.io/OSC2024/labs/lab3.html)
2. [Code](https://github.com/gama79530/NYCU_2024_Operating_System_Capstone/tree/main/Lab3)

## Lab 內容

這個Lab主要的目的是要了解`ARM`的`Exception`的機制。首先需要了解什麼是`Exception Level`以及如何切換。接著是要利用Exception的機制來完成一些非同步的功能。

### Basic Exercise 1 - Exception

在這個部份需要了解以下內容。

1. 什麼是`Exception Level`
2. 如何切換`Exception Level`
3. 如何處理`Exception`

關於`exception level`的解釋可以看[Spec: Exception Levels](https://nycu-caslab.github.io/OSC2024/labs/lab3.html#exception-levels)或者是[ARM Architecture Reference Manual ARMv8, for ARMv8-A architecture profile](https://developer.arm.com/documentation/ddi0487/aa/?lang=en)的Chap D1。程式碼相關的部份可以參考`boot.S`,`vtable_el1.S`,`exception.h`以及`exception.c`。

#### 如何切換 Exception Level (EL)

`EL`的切換首先需要先看是由那一個指令觸發的。有些指令可能只能用在特定的EL之間的切換。而另外也有指令是需要接著再去看對應的register的狀態來決定。

在這個部份我們使用到的其中一個指令是`eret`。這個指令與ret有點類似，但主要的區別如下

1. 當呼叫eret之後會區看對應的`SPSR_ELx`的狀態決定之後會切換到那一個EL。
2. 是去看對應的`ELR_ELx`來處理return的位址而不是看`LR`

在關於`SPSR_ELx`的設定中的設定可以直接在[ARM Architecture Reference Manual ARMv8, for ARMv8-A architecture profile](https://developer.arm.com/documentation/ddi0487/aa/?lang=en)裡面用關鍵字搜尋。

#### 如何處理 Exception

這個部份需要設定好對應的`vbar_el1`用來指定EL對應的`vector table`。這個table每一個`entry`會在對應的exception發生時自動被呼叫來處理exception。對於這個table的格式`ARM`是有一些規範在，可以參考[Vector Table](https://nycu-caslab.github.io/OSC2024/labs/lab3.html#vector-table)。此外在進入處理邏輯之前我們必須先做兩件事

1. 將`DAIF`這4種`Interrupt`先`masked`
2. 將`general-purpose registers`的值先儲存起來

另外因為我的exception處理邏輯是使用C語言實做，所以在`vtable_el1.S`裡面才會使用一些技巧去包裝。

#### Demo

在這個部份裡有一個`Demo`是要模擬執行另外一個程式。因此首先要利用前面Lab提供的`initramfs`來讓這個程式被載入記憶體。這個程式會使用到一個會切換`EL`的指令[SVC](https://developer.arm.com/documentation/dui0473/m/arm-and-thumb-instructions/svc)。這個指令其中一個常見的作法是用來產生`system call`。該指令會主動產生`Exception`，並且將EL從`EL0`切換到`EL1`。因此在執行這個程式之前需要先將EL切換到`EL0`。相關的程式碼要參考`shell.c`裡面的`command_exec`以及`exception.c`的`handler_sync_lower_aarch64_el1`。

### Basic Exercise 2 - Interrupt

這個部份因為很難與後面的部份切割，所以集中到[Advanced Exercise 2](https://gama79530.github.io/Course/OperatingSystemCapstone/Lab3/index.html#advanced-exercise-2-concurrent-i-o-devices-handling)解釋。

### Basic Exercise 3 - Rpi3’s Peripheral Interrupt

這個部份因為很難與後面的部份切割，所以集中到[Advanced Exercise 2](https://gama79530.github.io/Course/OperatingSystemCapstone/Lab3/index.html#advanced-exercise-2-concurrent-i-o-devices-handling)解釋。

### Advanced Exercise 1 - Timer Multiplexing

這個部份因為很難與後面的部份切割，所以集中到[Advanced Exercise 2](https://gama79530.github.io/Course/OperatingSystemCapstone/Lab3/index.html#advanced-exercise-2-concurrent-i-o-devices-handling)解釋。

### Advanced Exercise 2 - Concurrent I/O Devices Handling

#### Interrupt

關於`interrupt`的處理首先需要知道的是`來源`。不同的`exception`種類會有不同的方式去辨別exception的來源。可以直接參考`exception.c`裡面的程式。

對於`exception`的處理我採取的作法是建立一個`task queue`。當接受到一個exception時會依照下面的流程去處理

1. 根據exception來源建立一個對應的`task`
2. 試著執行這個`task`

之所以會拆開成這兩個步驟的原因是因為要實現`nested interrupt`。在建立`task`以及操作`task queue`的過程中會把`DAIF`給`masked`。而執行`task`的過程中必須把`DAIF`給`unmasked`。

#### Timer

Rpi3提供的`timer`實際上就是個`倒數計時器`。這個部份的設計要分成兩部份

1. 如何操作定時器
2. 如何處理同時有多個定時器

關於第1個部份的程式碼可以參考`timer.c`裡面的`core_timer_enable`以及`set_period`。而第二個部份則是設計了一個`event queue`，這個queue的排序是依照event的`expired time`來排序。當要建立一個timer的時候實際上是在event queue裡面新增一個event。而當timer的`interrupt`發生時會先依照前面講的建立一個對應的`task`。這個task會再接著去處理event queue。把expired time最早的event處理掉。相關的程式碼主要是在`timer.h`與`timer.c`。

#### Async IO

要實現`async io`的方式是使用`read buffer`與`write buffer`。主要的程式碼在`mini_uart.h`, `mini_uart.c`以及`exception.c`。

對於`write`的時候就先將要寫入的字元寫入write buffer。接著在觸發一個interrupt，而對這個interrupt的處理則是主動去把write buffer裡面的字元撈出來並用mini uart寫出去。

對於`read`的話則是要反過來看。當interrupt發生的時候就先將字元寫入read buffer。而當我們需要read的時候就去buffer裡面把沒被讀出的字元讀出來。如果沒有字元就是一直等到有interrupt發生把字元寫到buffer後再把它讀出來。

## 參考 & 補充資料

1. [ARM Architecture Reference Manual ARMv8, for ARMv8-A architecture profile](https://developer.arm.com/documentation/ddi0487/aa/?lang=en)
2. [DAIF, Interrupt Mask Bits](https://developer.arm.com/documentation/ddi0595/2021-06/AArch64-Registers/DAIF--Interrupt-Mask-Bits)
3. [ARM64的启动过程之（六）：异常向量表的设定](http://www.wowotech.net/armv8a_arch/238.html)
4. [基础篇(二).ARMv8寄存器（2）](https://blog.csdn.net/heshuangzong/article/details/127695422)
5. [uboot下开启ARMv8的定时器中断](https://wzhchen.github.io/uboot/uboot%E4%B8%8B%E5%BC%80%E5%90%AFARMv8%E7%9A%84%E5%AE%9A%E6%97%B6%E5%99%A8%E4%B8%AD%E6%96%AD/)
