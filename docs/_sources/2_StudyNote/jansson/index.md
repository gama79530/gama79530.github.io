# Jansson (a C library for JSON data) 使用教學

## Prerequisite
1. 了解什麼是JSON，可參考[連結](https://www.json.org/json-en.html)
2. 從官方的[github repository](https://github.com/akheron/jansson/releases)下載原始檔案。
```{tip}
:class: dropdown
我個人是使用[v2.14](https://github.com/akheron/jansson/releases/download/v2.14/jansson-2.14.tar.bz2)
```

3. 參考官方的[安裝方式](https://jansson.readthedocs.io/en/latest/gettingstarted.html#compiling-and-installing-jansson)
```{tip}
:class: dropdown
我個人是使用Ubuntu 22.04做為開發環境，依照我的使用經驗來說使用CMake安裝比較不會出問題,至於要要不要使用shared library可以按個人喜好決定。
```
4. 在 `source file` 裡面include `<jansson.h>` 即可使用
5. 編譯時要記得加上 `-ljansson` 來link library
```{tip}
:class: dropdown
建議還是要理解編譯時如何link第3方的library，若不清楚的話可以參考[連結](https://gama79530.github.io/2_StudyNote/LinkLoadDemo/index.html#)
```

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
| `real number` | `json_real` | `double` | |
| `array` | `json_array` | X | |
| `map` | `json_object` | X | The key is a Unicode string and the value is any JSON value. |

1. 所有種類的json object都使用 `json_t` 作為在c語言程式裡的type
2. 所有關於json object的操作都必須透過 `pointer` 來間接操作。
3. 可以使用function `json_is_XXX(json_t*)` 來檢查 `json_t` 實際到底是不是某種type。  
   例如：檢查是否為integer可以使用function `json_is_integer(ptr)`
4. 最簡單的產生物件方式之一是直接使用function `json_XXX(value)`去產生  
   例如：使用 ``json_real(1.0)`` 產生一個內容值為1.0的 `real` 物件 
5. 除了 `singleton` 的3種type之外的非 `container` type都可以使用 `json_XXX_set(ptr, value) / json_XXX_value(ptr)`分別去 `更改 / 取得` json object的值  
   例如：使用 `json_real_set(ptr, 3.0) / double d = json_real_value(ptr)`去 `更改 / 取得` ptr 的值
6. 所有對 `array` 的操作都是 `json_array_XXX` 。XXX為常見的對array的動作，例如： `size` 、`set` 、`get` 、`insert` 、`append` 、`del` 、`clear` 等等。
7. 所有對 `map` 的操作都是 `json_object_XXX`。XXX為常見的對map的動作，例如： `size` 、`set` 、`get` 、`update` 、`append` 、`del` 、`clear` 等等。
8. 針對 `array` 與 `map`，library有提供 macro `json_XXX_foreach(ptr, ...)` 來執行loop

#### Reference Count
**jansson**會半自動管理**json object**的記憶體使用，其管理方式為對於**json object** 增加一個 `refcount` 來做管理。 `refcount` 在**json object**被配置記憶體時會被設定為 `1` 。一旦**json object**的 `refcount` 變成 `0` 的瞬間，該**json object**所佔用的記憶體空間會被釋放。Programmer必須自己管理 `refcount` 。

`refcount` 只有2種狀況會受影響
1. 使用非 `steal` 版本的function將 `json object` 裝入其它`array`或`map`時
2. 使用`json_t *json_incref(json_t *json)`或者`void json_decref(json_t *json)`直接操作。

##### Thread-safty
**jansson library**不保證 `object content` 是thread-safe。但只要compiler支援便會保證 `refcount` 是thread-safe的。可以通過**preprocessor constant** `JANSSON_THREAD_SAFE_REFCOUNT` 是否有定義去檢查。

##### Steal function
用來增加 `container` 內容的function多數都有對應的 `steal function` ，其名稱為 `json_XXX_XXX_new()`。`Steal function` 的作用與其對應的普通function一樣，唯一的差別是不會去增加 `refcount` 。

**jansson**會提供**steal function**是因為下面這個關於 `container` 的使用場景非常常見
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

在這個使用場景之下， `i` 這個pointer只是單純用來新增一個物件，之後要將這個物件統一由 `conainer` 管理，但因為 `json_array_append` 會增加 `refcount` 所以在這個使用場景之下必須使用 `json_decref` 去主動管理 `refcount` 。通過steal function的提供，上面的範例可以更改成
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
### Object Parsing
**json**的本質就是一個 `notation`，因此 `json object` 可以與 `string` 之間天生就可以互相轉換。 將 `json object` 轉換成 `string` 的過程稱之為 `Encoding` ，而反過來將 `string` 轉換成 `json object` 的過程稱之為 `Decoding` 。

#### Flag
`Encoding` 與 `Decoding` 都有一些關於 `string format`的 `flag` 可以去控制 `Encoding` 與 `Decoding` 之間的轉換。 `flag` 的預設值為 `0` 。 比較常用的 `flag` 為 `Encoding` 的 `JSON_INDENT(n)`。 其他的 `flag` 可以參考官方[Encoding](https://jansson.readthedocs.io/en/latest/apiref.html#encoding)以及[Decoding](https://jansson.readthedocs.io/en/latest/apiref.html#decoding)的API文件。

#### Encoding
`Encoding` 提供的function主要的差異是輸出的載體做區分。
1. 輸出 `char * 字串` 的 `json_dumps` (字串要自行 `free` ) 
2. 輸出到 `buffer` 的 `json_dumpb`
3. 輸出到 `file` 的 `json_dumpf`
4. 輸出到 `stream output` 的 `json_dumpfd`
5. 輸出到 `指定路徑` 的 `json_dump_file`

#### Decoding
##### Error reporting
有很多原因可能會造成**jansson**發生錯誤，但最常見的原因是 `json string` 的格式不正確。**jansson** 處理 `error` 的方式是將所有與 `error` 相關的資訊都封裝在一個 `json_error_t` 變數裡。 若在 `Decoding` 時有把 `json_error_t` 的 `address` 作為參數傳入，則當發生錯誤時對應的錯誤資訊都會被自動紀錄到該變數。接著再針對錯誤做後續處理即可。若不想處理錯誤訊息的話提供 `NULL` 即可。 `json_error_t` 的詳細內容可以參考官網的[API 文件](https://jansson.readthedocs.io/en/latest/apiref.html#error-reporting)。

##### Decoding function
`Decoding` 提供的function與 `Encoding` 有對應關係。
1. 輸入 `char * 字串` 的 `json_loads`
2. 從 `buffer` 輸入的 `json_loadb`
3. 從 `file` 輸入的 `json_loadf`
4. 從 `stream input` 輸入的 `json_loadfd`
5. 從 `指定路徑` 的檔案輸入的 `json_load_file`

##### Decoding by format string
**jansson**提供了3個通過 `formatted string` 來做 `Decoding` 的function。 分別是 `json_pack` 、 `json_pack_ex` 、 `json_vpack_ex` 。這3個function的主要功能有點類似 `printf` 的使用方式。提供含有 `format specifier` 的**string**以及對應的值作為參數即可得到完整的 `json object` (若`formatted string`代表的是有內容的 `container` 的話會連內容都一併配置好)。 而他們之間的差異主要是在於 `Decoding 細節控制` 、 `error 處理` 、 `呼叫方式` 等方面。 關於**細節**以及 `format specifier` 可以參考官網[API 文件](https://jansson.readthedocs.io/en/latest/apiref.html#building-values)。

### Equality
要比較兩個 `json object` 要使用 `json_equal` 這個function。 若是 `container` 類型的 `json object` ，則要所有內容都相等才會得到 `true` 。其他類型的 `json object` 則是很單純的先比對 `type` 後比對 `value` 。

### Copying
`copy function` 主要的功能是複製一個擁有相同的 `value` 的 `json object` 。但複製出來的 `json object` 會有自己全新的 `refCount` 。  

**jansson**提供了兩個 `copy function` : `json_copy` 與 `json_deep_copy` 。 這兩個function的差別在於若複製的 `json object` 是 `container` 的話內容物是否要另外複製。若是使用在普通的 `json object` 上其作用沒有差異。

## Reference
1. [Introducing JSON](https://www.json.org/json-en.html)
2. [Jansson Documentation](https://jansson.readthedocs.io/en/latest/index.html)