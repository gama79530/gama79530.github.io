# 題目 2 + 參考題解1, 參考題解2

## Reference
- [2020q1 第 1 週測驗題](https://hackmd.io/@sysprog/linux2020-quiz1)
- [2020q1 第 1 週隨堂測驗解題思路](https://hackmd.io/@Ryspon/HJVH8B0XU)
- [2020q1 第一週測驗題 解題思路](https://hackmd.io/@chses9440611/Sy5gwE37I)

## 測驗 `1`

考慮一個單向 linked list:
```cpp
typedef struct __list {
    int data;
    struct __list *next;
} list;
```

在不存在環狀結構的狀況下，以下函式能夠對 linked list 元素從小到大排序:
```cpp
list *sort(list *start) {
    if (!start || !start->next)
        return start;
    list *left = start;
    list *right = left->next;
    LL0;

    left = sort(left);
    right = sort(right);

    for (list *merge = NULL; left || right; ) {
        if (!right || (left && left->data < right->data)) {
            if (!merge) {
                LL1;
            } else {
                LL2;
                merge = merge->next;
            }
            LL3;
        } else {
            if (!merge) {
                LL4;
            } else {
                LL5;
                merge = merge->next;
            }
            LL6;
        }
    }
    return start;
}
```

請補完程式碼。

==作答區==

LL0 = ?
* `(a)` `left->next = NULL`
* `(b)` `right->next = NULL`
* `(c)` `left = left->next`
* `(d)` `left = right->next`

> `Ans` : (a)

LL1 = ?
* `(a)` `start = left`
* `(b)` `start = right`
* `(c)` `merge = left`
* `(d)` `merge = right`
* `(e)` `start = merge = left`
* `(f)` `start = merge = right`

> `Ans` : (c)

LL2 = ?
* `(a)` `merge->next = left`
* `(b)` `merge->next = right`

> `Ans` : (a)

LL3 = ?
* `(a)` `left = left->next`
* `(b)` `right = right->next`
* `(c)` `left = right->next`
* `(d)` `right = left->next`

> `Ans` : (a)

LL4 = ?
* `(a)` `start = left`
* `(b)` `start = right`
* `(c)` `merge = left`
* `(d)` `merge = right`
* `(e)` `start = merge = left`
* `(f)` `start = merge = right`

> `Ans` : (d)

LL5 = ?
* `(a)` `merge->next = left`
* `(b)` `merge->next = right`

> `Ans` : (b)

LL6 = ?
* `(a)` `left = left->next`
* `(b)` `right = right->next`
* `(c)` `left = right->next`
* `(d)` `right = left->next`

> `Ans` : (b)

```
延伸問題:
1. 解釋上述程式運作原理;
2. 指出程式改進空間，特別是考慮到 [Optimizing merge sort](https://en.wikipedia.org/wiki/Merge_sort#Optimizing_merge_sort);
3. 將上述 singly-linked list 擴充為 circular doubly-linked list 並重新實作對應的 `sort`;
4. 依循 Linux 核心 [include/linux/list.h](https://github.com/torvalds/linux/blob/master/include/linux/list.h) 程式碼的方式，改寫上述排序程式;
5. 嘗試將原本遞迴的程式改寫為 iterative 版本;
```