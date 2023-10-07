# 題目3 / 參考題解

## Reference
- [2020q3 第 1 週測驗題](https://hackmd.io/@sysprog/sysprog2020-quiz1)
- [2020q3 Homework1 (quiz1)](https://hackmd.io/@RinHizakura/BysgszHNw)

## 測驗 `1`

考慮一個單向 linked list，其結構定義為:
```cpp
typedef struct __node {                   
    int value;
    struct __node *next;
} node_t;
```

已知不存在 circular (環狀結構)，接下來將對該單向 linked list 進行下列操作:
* `add_entry`: 新增節點，當 linked list 沒有內容時，必須由開發者更新指向開頭的指標。因此實際得到 reference，而非 copy
* `remove_entry`: 移去指定節點，指向開頭的指標可能因此變更，所以需要用到 a pointer to a pointer (指標的指標)
* `swap_pair`: 交換一對相鄰的節點，取自 [LeetCode: Swap Nodes in Pairs](https://leetcode.com/problems/swap-nodes-in-pairs/)，給定 `1->2->3->4`，則該回傳 `2->1->4->3`
* `reverse`: 將給定的 linked list 其內節點予以反向，即 `1->2->3->4`，則該回傳 `4->3->2->1`

```{note}
"delete" 和 "remove" 看似都是「刪去某物」，在 Linux 核心的 [include/list.h](https://github.com/torvalds/linux/blob/master/include/linux/list.h) 中，這二個動作並存，但實際行為卻不同。[Difference between "delete" and "remove"](https://english.stackexchange.com/questions/52508/difference-between-delete-and-remove) 其中的解釋可知：
* "remove" 這動作對於 linked list 來說，是斷開節點和節點的關聯，也就是說原本若是 A $\to$ B $\to$ C，在 `remove(B)` 操作完成後，就會變成 A $\to$ C 的節點關係。特別注意到 B 這個節點其實還存在於記憶體中，只是我們無法從節點間的關係看出來。於是 "remove" 可解讀為 "take away" (將某物帶走)
* "delete" 則有 "erase" 的涵義，若用於 linked list，則指某個節點將被「抹除」，對應的記憶體就會有變化
```

對應的程式碼如下:
```cpp
#include <stdio.h>
#include <stdlib.h>

typedef struct __node {
    int value;
    struct __node *next;
} node_t;

void add_entry(node_t **head, int new_value)
{
    node_t **indirect = head;

    node_t *new_node = malloc(sizeof(node_t));
    new_node->value = new_value;
    new_node->next = NULL;

    AA1;
    while (*indirect)
        indirect = &(*indirect)->next;
    AA2;
}

node_t *find_entry(node_t *head, int value)
{
    node_t *current = head;
    for (; current && current->value != value; current = current->next)
        /* interate */;
    return current;
}

void remove_entry(node_t **head, node_t *entry)
{
    node_t **indirect = head;

    while ((*indirect) != entry)
        indirect = &(*indirect)->next;

    *indirect = entry->next;
    free(entry);
}

node_t *swap_pair(node_t *head)
{
    for (node_t **node = &head; *node && (*node)->next; BB1) {
        node_t *tmp = *node;
        BB2;
        tmp->next = (*node)->next;
        (*node)->next = tmp;
    }
    return head;
}

node_t *reverse(node_t *head)
{
    node_t *cursor = NULL;
    while (head) {
        node_t *next = head->next;
        CCC;
        head = next;
    }
    return cursor;
}

void print_list(node_t *head)
{
    for (node_t *current = head; current; current = current->next)
        printf("%d ", current->value);
    printf("\n");
}

int main(int argc, char const *argv[])
{
    node_t *head = NULL;

    print_list(head);

    add_entry(&head, 72);
    add_entry(&head, 101);
    add_entry(&head, 108);
    add_entry(&head, 109);
    add_entry(&head, 110);
    add_entry(&head, 111);

    print_list(head);

    node_t *entry = find_entry(head, 101);
    remove_entry(&head, entry);

    entry = find_entry(head, 111);
    remove_entry(&head, entry);

    print_list(head);

    /* swap pair.
     * See https://leetcode.com/problems/swap-nodes-in-pairs/
     */
    head = swap_pair(head);
    print_list(head);

    head = reverse(head);
    print_list(head);

    return 0;
}
```

參考執行輸出: (第 1 行是換行符號)
```

72 101 108 109 110 111 
72 108 109 110 
108 72 110 109
109 110 72 108
```

請補完程式碼。

<mark>作答區</mark>

AA1 = ?
* `(a)` `assert(new_node)`
* `(b)` `*indirect = new_node`

> `Ans` : (a)

AA2 = ?
* `(a)` `assert(new_node)`
* `(b)` `*indirect = new_node`

> `Ans` : (b)

BB1 = ?
* `(a)` `node = (*node)->next->next`
* `(b)` `*node = (*node)->next->next`
* `(c)` `*node = ((*node)->next)->next`
* `(d)` `*node = &((*node)->next)->next`
* `(e)` `node = &(*node)->next->next`
* `(f)` `*node = &(*node)->next->next`

> `Ans` : (e)


BB2 = ?
* `(a)` `node = (*node)->next`
* `(b)` `node = &(*node)->next`
* `(c)` `*node = (*node)->next`
* `(d)` `*node = &(*node)->next`
* `(e)` `*node = &((*node)->next)`

> `Ans` : (c)

CCC = ?
* `(a)` `cursor = head; head->next = cursor`
* `(b)` `head->next = cursor; cursor = head`
* `(c)` `cursor = head`
* `(d)` `head->next = cursor`
* `(e)` `head->next->next = cursor; cursor->next = head`
* `(f)` `cursor->next = head; head->next->next = cursor`

> `Ans` : (b)

```{seealso}
延伸問題:
1. 解釋上述程式運作原理，搭配 [Graphviz](https://graphviz.org/)，比照 [Linked List 練習題](https://hackmd.io/@sysprog/linked-list-quiz) 在 HackMD 筆記上視覺化展現;
2. 函式 `swap_pair` 和 `reverse` 對於指標的操作方式顯然異於 `add_entry` 及 `remove_entry`，需要額外做 `head = ...` 的更新，請用指標的指標來改寫，並避免回傳指標;
3. 以遞迴改寫上述的 `reverse`，注意，你可能因此需要建立新的函式，如 `rev_recursive`，隨後在 `reverse` 函式中呼叫 `rev_recursive`;
4. 針對 singly-linked list 的節點，實作 [Fisher–Yates shuffle](https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle)，你應該儘量降低記憶體的使用量;
```