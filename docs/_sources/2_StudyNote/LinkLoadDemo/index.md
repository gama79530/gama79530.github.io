# (C/C++) 如何在Linux上編譯與使用 static /shared library

## Demo project
[LinkLoadDemo](https://github.com/gama79530/LinkLoadDemo)這個Project總共包含了6個projects以及一個資料夾
1. `Project_StaticLib` 模擬建立一個 `static library`
1. `Project_LinkStaticLib` 模擬使用 `static library`
1. `Project_SharedLib` 模擬建立一個 `shared library`
1. `Project_LinkSharedLib` 模擬使用 `shared library`
1. `Project_SharedLibForDynamicLoad` 模擬建立一個 `shared library`
1. `Project_LoadSharedLib` 模擬動態載入一個 `shared library`
1. `SharedLib` 為佈署 `shared library` 的路徑

## Static Linking
### 特點
1. 通常是以 `.a (Unix-like)` 或 `.lib (Windows)` 為 `副檔名`
1. `編譯期` 將 `library` 的 `程式碼` 加入 `執行檔` ，因此執行檔size會 `較大`
1. 與 `library` 的 `source file` 之間的 `dependency` 相對較 `高` ，引用的**library**有更新時需要重編譯才能得到更新過後的內容
1. `Deployment` 相對簡單
1. 程式在執行的時候不用另外去 `link` **library**的程式，因此會稍微 `快` 一點。

### 建立static library
1. 寫一個 `header file (.h)` 作為 `library` 的 `介面` 讓**library**使用者可以正確的呼叫屬於**library**的**function**
1. 將 `source file` 編譯成 `object files`
1. 將 `object files` 打包成 `static library file`
   - `static library` 檔名的固定格式為 `lib{library name}.a`

```bash
 # 編譯指令
 gcc src/prog1.c -c -o src/prog1.o
 gcc src/prog2.c -c -o src/prog2.o
 gcc src/prog3.c -c -o src/prog3.o

 # 打包指令
 ar rcs libstaticlink.a src/prog1.o src/prog2.o src/prog3.o
```

### 使用static library
1. `include` **library**的 `header file` 後呼叫要使用的**function** (通常會將 `.h` 放到 `include` 資料夾下)
1. 編譯成執行檔
   - `-static` 用來指示若有同名的 `static library` 與 `shared library` 的話會優先使用 `static library` (預設為優先使用**shared library**)
   - `-I {path}` 用來指示 `header file` 放置的**路徑**，`-I` 與 `{path}` 中間可以不需要空格隔開
   - `-L {path}` 用來指示 `static library file` 放置的**路徑** (通常會放到 `lib` 資料夾下)，`-L` 與 `{path}` 中間可以不需要空格隔開
   - `-l {library name}` 用來指示 `library name` (前綴的 `lib` 與 `附檔名` 要去掉)，`-l` 與 `{library name}` 中間可以不需要空格隔開

```bash
 # 複製lib指令
 cp -r ../Project_StaticLib/include .
 cp ../Project_StaticLib/libstaticlink.a lib

 # 編譯指令
 gcc src/main.c -static -I include -L lib -l staticlink -o main
```

## Dynamic Linking
### 特點
1. 通常是以 `.so (Unix-like)` 或 `.dll (Windows)` 為 `副檔名`
1. `編譯期` 並不將 `library` 的 `程式碼`加入 `執行檔` ，因此執行檔會比 `較小`
1. 與 `library` 的 `source file` 之間的 `dependency` 相對較 `低`，引用的**library**有更新時只需要**更新library**即可得到更新過後的內容
1. `Deployment` 相對簡單較難
1. 程式在執行的時候需要去 `link` **library** 的程式，因此會稍微 `慢` 一點。
1. `程式碼` 可以多個程式**共用**，可節省系統資源

### 建立shared library
1. 寫一個 `header file` 作為**library**的 `介面` 讓**library**使用者可以正確的呼叫屬於**library**的**function**
1. 將 `source file` 編譯成 `object files`
1. 將 `object files` 打包成 `shared library file`
   - `version code` : 代表大版本更動，可能造成與前面的版本不相容
   - `minor code` : 代表有新增功能，但library有向前相容 
   - `release code` : 代表功能有變更，通常是**bug修正**或者是針對**程式重構** 
   - `real name` : 實際的檔案名稱，慣用格式為 `lib{library name}.so.{version code}.{minor code}.{release code}`
   - `linker name` : 要編譯執行檔時 `linker` 尋找**library**的檔案名稱，慣用格式為 `lib{library name}.so`
   - `so name` : 執行檔要啟動時 `linker` 尋找**library**的檔案名稱，慣用格式為 `lib{library name}.so.{version code}`
1. 指令講解
   - `-fPIC` 是用來提示 `compiler` 要將檔案編譯成 `position-independent code`
   - `-shared` 是用來提示 `compiler` 要將檔案編譯成 `shared object`
   - `-Wl,{option}` 是用來將**option**傳給 `linker` 的指令，要傳給**linker**的指令用逗點隔開
      - `-soname` 是 `linker` 的指令，用來提示當編譯好的執行檔啟動時，要用 `soname` 去找到 `shared library` 而不是使用 `real name` 去找，設定 `soname` 可以增加程式的彈性   

```bash
 # 編譯指令
 gcc src/prog1.c -c -fPIC -o src/prog1.o
 gcc src/prog2.c -c -fPIC -o src/prog2.o
 gcc src/prog3.c -c -fPIC -o src/prog3.o

 # 打包指令
 gcc src/prog1.o src/prog2.o src/prog3.o -shared -Wl,-soname,libdynamiclink.so.1 -o libdynamiclink.so.1.0.0 
```

### 使用shared library
1. `include` **library**的 `header file` 後呼叫要使用的**function** (通常會將 `.h` 放到 `include` 資料夾下)
1. 佈署share library
   - 將 `shared library` 檔案複製到部署路徑資料夾下
   - 建立 `linker name` 的 `soft link`
   - 建立 `so name` 的 `soft link`
1. 編譯成執行檔: 會依據 `linker name` 去找**library**
1. 設定環境變數: 需要把佈署路徑加到環境變數 `LD_LIBRARY_PATH`，執行時執行檔才找的到**shared library**

```bash
 # 佈署指令
 cp -r ../Project_SharedLib/include .
 mkdir -p ../SharedLib
 cp ../Project_SharedLib/libdynamiclink.so.1.0.0 ../SharedLib
 ln -fs ../SharedLib/libdynamiclink.so.1.0.0 ../SharedLib/libdynamiclink.so.1
 ln -fs ../SharedLib/libdynamiclink.so.1.0.0 ../SharedLib/libdynamiclink.so

 # 編譯指令
 gcc src/main.c -I include -L ../SharedLib -l dynamiclink -o main

 # 環境變數設定
 LD_LIBRARY_PATH=$LD_LIBRARY_PATH:../SharedLib
```

## Dynamic Loading
### 特點
1. 編譯時並不將**library**的內容連結，在執行期動態將 `程式` 以 `plug-in` 的方式 `載入` 與 `釋放` ，更具彈性。
1. 因為系統需要處理的工作更多，因此執行速度 `更慢`
1. `Dynamic Loading` 載入的程式可以是 `static library` 、 `shared library` 或 `執行檔`。

### 重點
1. 透過 `libdl` 達成，用法參考檔案 `Project_LoadSharedLib/src/main.c`
1. 可以不需要 `include`**library**的 `header file` ，但是需要從 `header file` 或 `文件` 確定好要使用的**function**或**變數**的**type**
1. `dlopen`的檔名如果以 `'/'` 開頭則會用絕對路徑去找，若不是以的話會依照下面的順序尋找
   1. 環境變數 `LD_LIBRARY_PATH` 用 `':'` 隔開的那些路徑
   1. `/etc/ld.so.cache` 中指定的 `library列表` （從 /etc/ld.so.conf 產生）
   1. `/lib`
   1. `/usr/lib`
1. 編譯指令有 `-ldl` 的原因是因為需要用到 `libdl`

## Reference
1. [static link & Dynamic Link & Load](https://phchiu.pixnet.net/blog/post/39869035)
1. [Compile gcc 編譯 static link, dynamic link, dynamic load](https://medium.com/chris-place/compile-gcc-%E7%B7%A8%E8%AD%AF-static-link-dynamic-link-dynamic-load-17dfb4ef3cf1)
1. [How static linking works on Linux](https://opensource.com/article/22/6/static-linking-linux)
1. [How dynamic linking for modular libraries works on Linux](https://opensource.com/article/22/5/dynamic-linking-modular-libraries-linux#:~:text=Dynamic%20libraries%20are%20linked%20during,placed%20in%20the%20main%20memory.)
1. [4. Dynamically Loaded (DL) Libraries](https://tldp.org/HOWTO/Program-Library-HOWTO/dl-libraries.html)
1. [Shared Libraries: Understanding Dynamic Loading](https://amir.rachum.com/shared-libraries/#elf---executable-and-linkable-format)