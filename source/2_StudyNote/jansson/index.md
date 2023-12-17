# Jansson - a C library for JSON data 使用教學

## Prerequisite
1. 了解如何使用gcc將第3方的library檔案link到自己的project，可參考[連結](https://gama79530.github.io/2_StudyNote/LinkLoadDemo/index.html)
2. 了解什麼是JSON，可參考[連結](https://www.json.org/json-en.html)
3. 從[v2.14](https://github.com/akheron/jansson/releases/download/v2.14/jansson-2.14.tar.bz2)下載source檔案
4. 參考官方的[安裝方式](https://jansson.readthedocs.io/en/latest/gettingstarted.html#compiling-and-installing-jansson)
```{tip}
:class: dropdown
我是使用使用Ubuntu 22.04做為開發環境，依照我個人的使用經驗來說使用CMake安裝比較不會出問題,至於要要不要使用shared library可以按個人喜好決定。
```
5. 在source裡面只要include `<jansson.h>`即可使用
6. 編譯時要記得加上`-ljansson`來link library

## 使用教學
接下來的內容都可以從官網的[API Reference](https://jansson.readthedocs.io/en/latest/apiref.html#api-reference)找到，主要是希望按照個人認為的重要順序去重新編排順序，並且將內容濃縮。

### Value Representation
### Error reporting
### Object Parsing
### Equality
### Copying

### Type system
1. 所有type都以 `json_t` 作為包裝
2. 所以 `json_t` 都是透過pointer的方式做reference操作
3. `json_t` 可以代表以下任何一種type中的其中一種

   | Data type | json type | c type | description |
   |:--|:--:|:--:|:--| 
   | `true` | `json_true` | X | singleton |
   | `false` | `json_false` | X | singleton |
   | `null` | `json_null` | X | singleton |
   | `string` | `json_string` | char* | JSON strings are mapped to C-style null-terminated character arrays, and UTF-8 encoding is used internally.|
   | `integer` | `json_integer`| `json_int_t` |`json_int_t` represents the widest integer type available on your system. |
   | `real` | `json_real` | `double` | |
   | `array` | `json_array` | X | |
   | `object` | `json_object` | X | The key is a Unicode string and the value is any JSON value. |

### 基本操作
1. 測試給定的 `json_t` 是否屬於某個data type
   > `json_is_{data type}`. ex: `json_is_integer(null)` 
2. 產生物件
   > `json_{data type}()`. ex: `json_real(1.0)`
3. 更改值
   > - `json_string_set`、`json_integer_set`、`json_real_set`
   > - `json_array_set`、`json_object_set`
4. 取值
   > - `json_string_value`、`json_integer_value`、`json_real_value`
   > - `json_array_get`、`json_object_get`

### Reference count

### Encoding & Decoding


### Others

## Reference
1. [Introducing JSON](https://www.json.org/json-en.html)
2. [Jansson Documentation](https://jansson.readthedocs.io/en/latest/index.html)