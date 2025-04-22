# 題目4 / 參考題解

## Reference
- [2021q1 第 1 週測驗題](https://hackmd.io/@sysprog/linux2021-quiz1)
- [2021q1 Homework1 (quiz1)](https://hackmd.io/@linD026/2021q1_quiz1)

## 測驗 `1`

考慮一個單向 linked list，其結構定義為:
```cpp
typedef struct __node {                   
    int value;
    struct __node *next;
} node_t;
```

已知不存在 circular (環狀結構)，下方程式碼嘗試對該單向 linked list 進行 Quick sort，預期依據遞增順序。
```cpp
static inline void list_add_node_t(node_t **list, node_t *node_t) {
    node_t->next = *list;
    *list = node_t;
}

static inline void list_concat(node_t **left, node_t *right) {
    while (*left)
        LLL;
    *left = right;
}

void quicksort(node_t **list)
{
    if (!*list)
        return;

    node_t *pivot = *list;
    int value = pivot->value;
    node_t *p = pivot->next;
    pivot->next = NULL;

    node_t *left = NULL, *right = NULL;
    while (p) {
        node_t *n = p;
        p = p->next;
        list_add_node_t(n->value > value ? AAA : BBB, n);
    }

    quicksort(&left);
    quicksort(&right);

    node_t *result = NULL;
    list_concat(&result, left);
    CCC;
    *list = result;
}
```

對應的測試程式如下:
```cpp
static bool list_is_ordered(node_t *list) {
    bool first = true;
    int value;
    while (list) {
        if (first) {
            value = list->value;
            first = false;
        } else {
            if (list->value < value)
                return false;
            value = list->value;
        }
        list = list->next;
    }
    return true;
}

static void list_display(node_t *list) {
    printf("%s IN ORDER : ", list_is_ordered(list) ? "   " : "NOT");
    while (list) {
        printf("%d ", list->value);
        list = list->next;
    }
    printf("\n");
}

int main(int argc, char **argv) {
    size_t count = 20;

    node_t *list = NULL;
    while (count--)
        list = list_make_node_t(list, random() % 1024);

    list_display(list);
    quicksort(&list);
    list_display(list);

    if (!list_is_ordered(list))
        return EXIT_FAILURE;

    list_free(&list);
    return EXIT_SUCCESS;
}
```

參考執行輸出:
```
NOT IN ORDER : 1016 84 706 124 326 483 763 498 939 186 205 809 236 74 255 81 115 105 966 359 
    IN ORDER : 74 81 84 105 115 124 186 205 236 255 326 359 483 498 706 763 809 939 966 1016 
```

請補完程式碼，使得執行符合預期。

==作答區==

LLL = ?
* `(a)` `left = left->next`
* `(b)` `left = (*left)->next`
* `(c)` `left = &((*left)->next)`
* `(d)` `*left = (*left)->next`

> `Ans` : (c)

AAA = ?
* `(a)` `&pivot`
* `(b)` `pivot`
* `(c)` `&left`
* `(d)` `left`
* `(e)` `&right`
* `(f)` `right`

> `Ans` : (e)

BBB = ?
* `(a)` `&pivot`
* `(b)` `pivot`
* `(c)` `&left`
* `(d)` `left`
* `(e)` `&right`
* `(f)` `right`

> `Ans` : (c)

CCC = ?
* `(a)` `llist_concat(&result, right)`
* `(b)` `list_concat(&result, pivot); list_concat(&result, right)`
* `(c)` `list_concat(&result, right); list_concat(&result, pivot)`

> `Ans` : (b)

```{seealso}
延伸問題:
1. 解釋上述程式運作原理，搭配 [Graphviz](https://graphviz.org/)，比照 [Linked List 練習題](https://hackmd.io/@sysprog/linked-list-quiz) 在 HackMD 筆記上視覺化展現;
    * 測試程式使用到 [random](https://linux.die.net/man/3/random)，多執行幾次可發現輸出結果相仿，請修正，並引入其他 [Pseudorandom number generator
](https://en.wikipedia.org/wiki/Pseudorandom_number_generator)
2. 參考 [Optimized QuickSort — C Implementation (Non-Recursive)](https://alienryderflex.com/quicksort/) 並重寫上述 quick sort 程式碼，避免使用遞迴呼叫
3. Linux 核心內部也有 linked list 實作，但是 circular doubly-linked list，[linux-list](https://github.com/sysprog21/linux-list) 仿效 Linux 核心的實作並予以簡化，在 `examples/` 目錄提供 quick sort 實作，請探討 Linux 的 linked list 和上述程式碼的落差，並改寫 [linux-list](https://github.com/sysprog21/linux-list) 的 quick sort 範例，避免使用遞迴呼叫
    * 參考資料: [The Linux Kernel API - List Management Functions](https://www.kernel.org/doc/html/latest/core-api/kernel-api.html)
4. 研讀 Ching-Kuang Shene ([冼鏡光](https://zh.wikipedia.org/zh-tw/%E5%86%BC%E9%8F%A1%E5%85%89)) 教授撰寫的 [A Comparative Study of Linked List Sorting Algorithms](https://pages.mtu.edu/~shene/PUBLICATIONS/1996/3Conline.pdf)，思考高效率的 linked list 排序演算法，並落實於上述 (3) 的程式碼中
```