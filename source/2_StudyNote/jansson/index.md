# Jansson (a C library for JSON data) 使用教學

## Prerequisite
1. 了解如何使用gcc將第3方的library檔案link到自己的project，可參考[連結](https://gama79530.github.io/2_StudyNote/LinkLoadDemo/index.html)
2. 了解什麼是JSON，可參考[連結](https://www.json.org/json-en.html)
3. 從[v2.14](https://github.com/akheron/jansson/releases/download/v2.14/jansson-2.14.tar.bz2)下載source檔案
4. 參考官方的[安裝方式](https://jansson.readthedocs.io/en/latest/gettingstarted.html#compiling-and-installing-jansson)
```{tip}
:class: dropdown
我個人是使用Ubuntu 22.04做為開發環境，依照我的使用經驗來說使用CMake安裝比較不會出問題,至於要要不要使用shared library可以按個人喜好決定。
```
5. 在source裡面只要include `<jansson.h>` 即可使用
6. 編譯時要記得加上 `-ljansson` 來link library

## 使用教學
接下來的內容都可以從官網的[API Reference](https://jansson.readthedocs.io/en/latest/apiref.html#api-reference)找到，主要是希望按照個人認為的重要順序去重新編排順序，並且將內容濃縮。

### 基本觀念 & 操作
#### Type system
| Data type | json type | c type | description |
|:--|:--:|:--:|:--| 
| `true` | `json_true` | X | singleton |
| `false` | `json_false` | X | singleton |
| `null` | `json_null` | X | singleton |
| `string` | `json_string` | char* | JSON strings are mapped to C-style null-terminated character arrays, and UTF-8 encoding is used internally.|
| `integer` | `json_integer`| `json_int_t` |`json_int_t` represents the widest integer type available on your system. |
| `real` | `json_real` | `double` | |
| `array` | `json_array` | X | |
| `map` | `json_object` | X | The key is a Unicode string and the value is any JSON value. |

1. 所有種類的json object都使用 `json_t` 作為在c語言程式裡的type
2. 所有關於json object的操作都必須透過pointer來間接操作。
3. 可以使用function `json_is_XXX(json_t*)` 來檢查 `json_t` 實際到底是不是某種type。  
   例如：檢查是否為integer可以使用function `json_is_integer(ptr)`
4. 最簡單的產生物件方式之一是直接使用function `json_XXX(value)`去產生
   例如：使用 ``json_real(1.0)`` 產生一個內容值為1.0的 `real` 物件 
5. 除了 `singleton` 的3種type之外的非 `container` type都可以使用 `json_XXX_set(ptr, value) / json_XXX_value(ptr)`分別去 `更改 / 取得` json object的值  
   例如：使用 `json_real_set(ptr, 3.0) / double d = json_real_value(ptr)`去 `更改 / 取得` ptr 的值
6. 對於 `array` 的動作都是 `json_array_XXX` 。XXX為常見的對array的動作，例如： `size` 、`set` 、`get` 、`insert` 、`append` 、`del` 、`clear` 等等。
7. 對於 `map` 的動作都是 `json_object_XXX`。XXX為常見的對map的動作，例如： `size` 、`set` 、`get` 、`update` 、`append` 、`del` 、`clear` 等等。
8. 針對 `array` 與 `map`，library有提供 macro `json_XXX_foreach(ptr, ...)` 來執行loop

#### Reference Count
`jansson` 會半自動管理 `json object` 的記憶體使用，其管理方式為對於 `json_t` 增加一個 `refcount` 來做管理。 `refcount` 在 `json object` 被配置記憶體時會被設定為 `1` 。一旦 `json object` 的 `refcount` 變成 `0` 的瞬間該 `json object` 會被釋放。Programmer必司自己管理 `refcount` 。

`refcount` 只有2種狀況會受影響
1. 使用非 `steal` 版本的function將 `json object` 裝入其它`array`或`map`時
2. 使用`json_t *json_incref(json_t *json)`或者`void json_decref(json_t *json)`直接操作。

##### steal function
有一種關於 `container` 很常見的場景如下
```c
{
   ...
   
   json_t *arr = json_array();
   json_t *i = json_integer(0);
   json_array_append(arr, i);
   json_decref(i);
   
   ...
   
   return;
}
```

在這個使用場景之下， `i` 這個pointer只是單純用來新增一個物件，之後要將這個物件統一由 `conainer` 管理，但因為 `json_array_append` 會增加 `refcount` 所以在這個使用場景之下必須使用 `json_decref` 去主動管理 `refcount` 。library有針對這種使用場景推出對應的steal function `json_XXX_XXX_new()`。 steal function的作用與其對應的普通function一樣，唯一的差別是不會去增加 `refcount` 。 因此上面的範裡可以更改成
```c
{
   ...
   
   json_t *arr = json_array();
   json_t *i = json_integer(0);
   json_array_append_new(arr, i);
   
   ...
   
   return;
}
```

### Equality
### Copying
### Object Parsing
### Error reporting

## Reference
1. [Introducing JSON](https://www.json.org/json-en.html)
2. [Jansson Documentation](https://jansson.readthedocs.io/en/latest/index.html)