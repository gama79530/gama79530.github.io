# Item 1: Understand template type deduction

一般常見的 `templete` 與`調用`

```cpp
template<typename T>
void f(ParamType param);

f(expr);                    // deduce T and ParamType from expr
```

## 類型推斷的 3 種分類

1. `ParamType` 是 `pointer` 或 `reference`, 但不是 `universal reference`
2. `ParamType` 是 `universal reference`
3. `ParamType` 不是 `pointer` 也不是 `reference`

```{note}
`universal reference` 不是個正式的術語，正式的術語是 `forwarding reference` (從 C++17 之後被確認)
```

### Case 1

```cpp
template<typename T>
void f(T& param);          // param is a reference

template<typename T>
void f(T* param);          // param is now a pointer
```

如果 `expr` 是 `reference`，先忽略 `reference` 的部份。  
接著再依照 `expr` 的類型與 `ParamType` 做比對以確定 `T` 。

```{tip}
簡而言之，跟著推理的直覺做推理就行。
```

### Case 2

```cpp
template<typename T>
void f(T&& param);         // param is now a universal reference
```

如果 `expr` 是個 `lvalue` ， `T` 與 `ParamType` 都會是個 `lvalue references` 。  
否則就是依照 `Case 1` 的方式做推理。

### Case 3

```cpp
template<typename T>
void f(T param);           // param is now passed by value
```

如果 `expr` 的類型是個 `reference` ，那就與 Case 1 一樣先忽略這部份。  
接著在繼續做推論，如果 `expr` 是 `const` 或 `volatile` 的話也要忽略這部份。  

**範例**

```cpp
template<typename T>
void f(T param);           // param is still passed by value
const char* const ptr =    // ptr is const pointer to const object
    "Fun with pointers";
f(ptr);                    // pass arg of type const char * const
```

`T` 會被推論為 `const char*` 。

```{tip}
用 chatgpt 給的整理，不管是 `reference` 或是 `pointer` ， `top-level const (也就是綁在變數上的 const)` 會被忽略，但綁在`類型`上的不會。
```

## Array Arguments and Function Arguments

- 若 `array / function parameter` 是 `reference` ，在做類型推導時不需要做 C 語言的`型別退化`。  
- 若 `array / function parameter` 不是 `reference` ，在做類型推導時就會先做 C 語言的`型別退化`，同時限定符 `const / volatile` 會被忽略。

**特殊範例**

使用 `references to arrays` 可以做出直接推論 `array` 裡面有多少成員的 template 範例。

```cpp
// return size of an array as a compile-time constant. (The
// array parameter has no name, because we care only about
// the number of elements it contains.)
template<typename T, std::size_t N>                  // see info
constexpr std::size_t arraySize(T (&)[N]) noexcept   // below on
{                                                    // constexpr
    return N;                                        // and
}                                                    // noexcept
```

```{note}
`constexpr` 讓`編譯器`可以在`編譯期`就得到 `arraySize` 的回傳值。
```

## Things to Remember

- 在模板型別推導中，作為參數的參照（reference）會被視為非參照，也就是其「參照性」會被忽略。
- 在為通用參照（universal reference）參數進行型別推導時，lvalue 實參會被特別處理。
- 在為按值（by-value）參數進行型別推導時，const 和/或 volatile 的實參會被視為非 const、非 volatile。
- 在模板型別推導中，作為參數的陣列或函式名稱會退化為指標，除非它們被用來初始化參照。
