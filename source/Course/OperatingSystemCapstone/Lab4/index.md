# Lab 4: Allocator

## 搭配材料

1. [Specification](https://nycu-caslab.github.io/OSC2024/labs/lab4.html)
2. [Code](https://github.com/gama79530/NYCU_2024_Operating_System_Capstone/tree/main/Lab4)

## Lab 內容

這個Lab主要的工作是要建立一個記憶體空間的管理系統。在管理記憶體空間的時候，首先是先將整個空間依照一個比較大的大小去切割成很多的`frame`。但實際上的分配並不會只能以frame為單位去分配，所以還會有一個基於frame管理系統之上的memory管理系統。

### Basic Exercise 1 - Buddy System

`Buddy system`是個適合用來用來管理大容量記憶體的方法。演算法在[Spec](https://nycu-caslab.github.io/OSC2024/labs/lab4.html#basic-exercise-1-buddy-system-40)上面都有講解。這裡只挑幾個細協補充說明。詳細的程式碼可以參考`frame.h`以及`frame.c`。

#### Find buddy frame index

1. 可以使用歸納法簡單的證明若`frame i`的`order=x`，則`i % (1 << x) == 0`
2. 接著可以利用這個性質證明在這個情況下可以再組成下一個buddy group的index是 `i ^ (1 << x)`

#### buddy group

在這個部份的處理要注意的事情是有可能會觸發鏈鎖反應。因此我在實做的`buddy_group`這個function會回傳這個回合有沒有實際做group，如果有的話就需要再繼續往上檢查。

#### array

在這部份只需要使用一個`array`紀錄每個`frame`的`order`或者`狀態`即可。但只使用這個資料結構的話當要找到一個`order = t`的`buddy group`可能會需要整個掃描一次。因此時間複雜度不會是$O(\log n)$

### Basic Exercise 2 - Dynamic Memory Allocator

在這個部份我的作法建築在`buddy system`之上引進`chunk pool`的概念。首先是將可被分配的大小用`chunk size`來分類，要求的大小要從這些大小裡面找足夠大且最小的。這些`chunks`則是使用`chunk pools`來管理。當夭某個特定大小時就去對應的pool找。相關的程式碼可以在`memory.h`與`memory.c`。

#### chunk size

我的作法是從`8 bytes`開始一直往上增長兩倍，直到`1024 bytes`。超過的都歸類到`large size`。之所以會使用`8 bytes`作為最小單位是因為如果使用到的程式碼在底層會使用到`str`時必須要`align 0x8`。所以直接使用這個size作為最小size。超過1024都歸類為`large size`與我管理`chunk pools`的方法有關。

#### chunk pools

我管理pools的作法是維護多個`linked list`。每個linked list負責管理一種size。除了`head`之外的每個`list node`實際大小都是1個`frame`，並且會包含以下內容

1. `header`: 用來紀錄管理`list_node`所需要的資料
2. `chunk states`: 用來紀錄`chunk`是否有沒有分配出去的狀態
3. `chunks`: 將空間切割成`chunks`以供分配

### Advanced Exercise 1 - Efficient Page Allocation

為了加速，所以在`buddy system`裡面多維護了多個`linked list`。每一個list都是紀錄了特定的`buddy order`之下有哪些`buddy group`。之後需要某個特定的`order`的group時只要去找對應的`linked list`就可以快速取得。

關於這個`linked list`會有一個問題是儲存`node`的空間要如何取得。我的作法是利用了這個linked list只會紀錄free的frame的性質，直接把node的資料寫在對應的frame的開頭。

### Advanced Exercise 2 - Reserved Memory

在這一塊我的做法是提供一個`callback function`的方式讓別的程式可以去保留自己使用的記憶體。這個function會在建立`buddy system`中間過程中被呼叫。這個callback function要負責統整所有需要保護的記憶體區段。出於簡單所以我是使用`hard coding`的方式處理。理想的方式可能是需要再另外設計一個註冊系統給其他程式片段使用。或者要把初始化拆開成`分配好metadata使用空間 & 初步初始化`以及`建立buddy system的初始化`的步驟。

### Advanced Exercise 3 - Startup Allocation

在建立`buddy system`與`memory system`的時候總會有一些用來管理所建立的`metadata`。要如何存放這些metadata本身也是個問題。所以需要一個把`Lab2`建立的`allocator`拿來使用。用來分配這些metadata放置的區域。
