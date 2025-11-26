# Introduction

在這一段主要整理以下基本概念。

## lvalue v.s. rvalue

一般來說 `lvalue` 對應的是「物件本體」，而 `rvalue` 則是由`程式碼賦值`或`函式回傳`取得的暫時性物件。  
最粗略的分辨方式是用`「是否可以做 & 運算取得 address」`來判斷是否為 lvalue。

```cpp
int x = 27;             // x is lvalue and 27 is rvalue

class Widget {
public:
Widget(Widget&& rhs);   // rhs is an lvalue, though it has
...                     // an rvalue reference type
};
```

## copy constructor v.s. move constructor

下面的程式碼示範了標準的 `copy constructor` 與 `move constructor` 寫法。  
這兩種 constructor 最大的區別在於：如果把物件當作是收集資源的容器，copy constructor 需要複製持有的資源（可以是 deep copy 或 shallow copy，如何實作取決於程式設計師）。  
而 move constructor 則是將資源轉移到新建立的物件容器內，並將來源物件設為有效但未定義狀態（如指標設為 nullptr）。


```cpp
class Widget {
public:
Widget(const Widget& lhs);  // this is a copy constructor
Widget(Widget&& rhs);       // this is a move constructor
...
};
```

## Exception Safety

依照保證層級常見區分成三種：

- `basic guarantee`: 失敗時物件維持有效狀態與類別不變量（invariants），不發生資源洩漏，但資料內容可能改變（部分操作已執行）。
- `strong guarantee`: 提供「commit 或 rollback」語意；若拋出例外，程式可觀察狀態回到呼叫前。
- `no-throw guarantee`: 承諾不會拋出例外（通常用於 move, destructor。, swap）。

實作上常透過下面方式達成：
- 建立暫時物件（copy / move），成功後再 commit（如使用 copy-and-swap）。
- RAII 確保資源自動回收。
- 盡量保持函式 exception-neutral（不吞例外，只轉交）。
- 在可行時將可失敗部分與不可失敗部分拆分。

## Function Object and Closure

標準的 `function object` 定義是支援 `operator()` 的 object 。  
但可以擴充成更廣義的定義是只要能用類似 function 的調用方式，也就是 `function Name(arguments)` ，就可以當作是 function object (或者稱作 callable object)。

在這種定義下的 function object 有:
- 支援 `operator()` 的 class
- function
- function pointer
- labmda function 

```{note}
由 `lambda expression` 產生的 function object 也可以稱之為 `closure`
```

## Declarations v.s. Definitions

`Declarations` 只定義 `type` 與 `name` 的資訊不提供細節。

```cpp
extern int x;               // object declaration

class Widget;               // class declaration

bool func(const Widget& w); // function declaration

enum class Color;           // scoped enum declaration
```

`Definitions` 則是提供了`存放的位置`以及`實做方式`的資訊。

```cpp
int x;                      // object definition

class Widget {
...
};                          // class definition

bool func(const Widget& w)
{ return w.size() < 10; }   // function definition

enum class Color
{ Yellow, Red, Blue };      // scoped enum definition
```

```{note}
Definitions 同時也是 Declarations，反之不成立。  
一個實體可以有多個 `Declarations` 但只能有一個 `Definitions` 。
```

### function's signature

`function's signature` 定義為 `declaration` 裡面描述 `parameter` 與 `return` 的 `types` 的部份。

```cpp
bool(const Widget&)
```
