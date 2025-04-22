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

### Static Linking 特點

1. 通常是以`.a` **(Unix-like)** 或`.lib` **(Windows)** 為`副檔名`
2. `編譯期` 將 `library` 的 `程式碼` 加入 `執行檔` ，因此執行檔size會 `較大`
3. 與`library`的`source file`之間的`dependency`相對較`高`，引用的**library**有更新時需要將程式重編譯才能得到更新過後的內容
4. `Deployment`不需要處理其他程式，相對**簡單**
5. **library**的程式會被放到同一個`address space`，所以執行速度會會稍微`快`一點。

### 建立 static library

1. 寫一個`header file (.h)`作為library的`API`讓**library使用**者可以正確的呼叫屬於library的function
1. 將`source file`編譯成`object files`
1. 將`object files`打包成 `static library file`

   ```{note}
   `static library`檔名的固定格式為`lib{library name}.a`
   ```

### Example: 建立 static library

```bash
# 編譯指令
gcc src/prog1.c -c -o src/prog1.o
gcc src/prog2.c -c -o src/prog2.o
gcc src/prog3.c -c -o src/prog3.o
# 打包指令, 打包出一個名為 staticlink 的 static library
ar rcs libstaticlink.a src/prog1.o src/prog2.o src/prog3.o
```

### 使用static library

#### 佈署 static library

1. 將`static library`檔案複製到佈署資料夾

#### 使用 static library 編譯程式

1. `include` library的**header file**後呼叫要使用的**function**(通常會將`.h`放到`include`資料夾下)
1. 將程式編譯成執行檔時加上相關的參數

   ```{note}
   - `-static`用來指示若有同名的`static library`與`shared library`的話會優先使用**static library** (預設為優先使用**shared library**)
   - `-I {path}`用來指示`header file`放置的**路徑**，`-I`與`{path}`中間可以不需要空格隔開
   - `-L {path}`用來指示`static library file`放置的**路徑**，`-L`與`{path}`中間可以不需要空格隔開
   - `-l {library name}`用來指示 `library name`，`-l`與`{library name}`中間可以不需要空格隔開
   ```

### Example: 使用 static library

```bash
# 佈署指令
cp -r ../Project_StaticLib/include .
cp ../Project_StaticLib/libstaticlink.a lib
# 編譯指令
gcc src/main.c -static -I include -L lib -l staticlink -o main
```

## Dynamic Linking

### Dynamic Linking 特點

1. 通常是以`.so` **(Unix-like)** 或`.dll` **(Windows)** 為`副檔名`
1. `編譯期`並不將`library`的`程式碼`加入`執行檔`而是只留下一個`stub`，因此執行檔會比`較小`
1. 與**library**的`source file`之間的`dependency`相對較 `低`，引用的**library**有更新時只需要**更新library**即可得到更新過後的內容
1. `Deployment`需要處理另外的設定，相對教**複雜**
1. 程式在啟動之前`dynamic linker`會介入去把**stub**綁定到**library function**實際的位址。
1. 因為綁定的位址是受到**OS**管控的，因此會稍微`慢`一點。
1. **library**的程式由**OS**管控，只會載入一次。如果有多個程式會共用這個library的話則是透過OS間接取得這些`library function`的`reference`。因此可節省系統資源。

### 建立 shared library

1. 寫一個`header file`作為**library**的`API`讓**library**使用者可以正確的呼叫屬於**library**的**function**
1. 將`source file`編譯成`object files`
1. 將`object files`打包成`shared library file`

   ```{note}
   - `version code`: 代表大版本更動，可能造成與前面的版本不相容
   - `minor code`: 代表有新增功能，但library有向前相容 
   - `release code`: 代表功能有變更，通常是**bug修正**或者是針對**程式重構** 
   - `real name`: 實際的檔案名稱，慣用格式為`lib{library name}.so.{version code}.{minor code}.{release code}`
   - `linker name`: 要編譯執行檔時`linker`尋找**library**的檔案名稱，慣用格式為`lib{library name}.so`
   - `so name`: 執行檔要啟動時`linker`尋找**library**的檔案名稱，慣用格式為`lib{library name}.so.{version code}`
   ```

1. 指令講解

   ```{note}
   - `-fPIC`是用來提示`compiler`要將檔案編譯成`position-independent code`
   - `-shared`是用來提示`compiler`要將檔案編譯成`shared object`
   - `-Wl,{option}`是用來將**option**傳給 `linker` 的指令，要傳給**linker**的指令用逗點隔開
   - `-soname`是`linker`的指令，用來提示當編譯好的執行檔啟動時，要用`soname`去找到`shared library`而不是使用`real name`去找，設定`so name`可以讓編譯與執行不使用**同一個library**進而增加程式的彈性
   ```

### Example: 建立 shared library

```bash
# 編譯指令
gcc src/prog1.c -c -fPIC -o src/prog1.o
gcc src/prog2.c -c -fPIC -o src/prog2.o
gcc src/prog3.c -c -fPIC -o src/prog3.o
# 打包指令, 打包出一個名為 dynamiclink 的 dynamic library
gcc src/prog1.o src/prog2.o src/prog3.o -shared -Wl,-soname,libdynamiclink.so.1 -o libdynamiclink.so.1.0.0 
```

### 使用 shared library

#### 佈署 shared library

1. 將`shared library`檔案複製到部署路徑資料夾下
1. 建立`linker name`的`soft link`
1. 建立`so name`的`soft link`
1. 如果**佈署路徑**不是系統預設資料夾則須使用下面任一種方法完成設置
   1. (Optional) 使用環境變數

      ```bash
      export LD_LIBRARY_PATH=/path/to/shared/libs:$LD_LIBRARY_PATH
      ```

   1. (Optional) 使用`ldconfig`配置
      1. 將佈署路徑加入到下面兩個選項其中之一
         - 在`/etc/ld.so.conf.d/`資料夾下面增加新的配置檔案(Ex: `custom-libs.conf`)
         - 直接修改`/etc/ld.so.conf`檔
      1. 更新`ld.so.cache`

      ```bash
      sudo ldconfig
      ```

#### 啟動有使用 dynamic linking 的程式時尋找library路徑的順序

1. 環境變數`LD_LIBRARY_PATH`用`':'`隔開的那些路徑
1. `/etc/ld.so.cache`中指定的`library列表`
1. `/lib`
1. `/usr/lib`
1. `/usr/local/lib`

#### 使用 shared library 編譯程式

1. **include** library的**header file**後呼叫要使用的**function**(通常會將`.h`放到`include`資料夾下
1. 將程式編譯成執行檔時加上相關的參數

   ```{note}
   - `-I {path}`用來指示`header file`放置的**路徑**，`-I`與`{path}`中間可以不需要空格隔開
   - `-L {path}`用來指示`shared library file`放置的**路徑**`-L`與`{path}`中間可以不需要空格隔開
   - `-l {library name}`用來指示`library name`，`-l`與`{library name}`中間可以不需要空格隔開
   - 會依據`linker name`去找**library**
   ```

### Example: 使用 shared library

```bash
# 佈署指令, 將 dynamic library 佈署到 ../SharedLib 資料夾下並建立兩個對應的 soft link
cp -r ../Project_SharedLib/include .
mkdir -p ../SharedLib
cp ../Project_SharedLib/libdynamiclink.so.1.0.0 ../SharedLib
ln -fs ../SharedLib/libdynamiclink.so.1.0.0 ../SharedLib/libdynamiclink.so.1
ln -fs ../SharedLib/libdynamiclink.so.1.0.0 ../SharedLib/libdynamiclink.so
# 編譯程式
gcc src/main.c -I include -L ../SharedLib -l dynamiclink -o main
# 環境變數設定 & 執行編譯好的程式
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:../SharedLib
./main
```

## Dynamic Loading

### Dynamic Loading 特點

1. 編譯時並不將**library**的內容連結，在執行期動態將**library**以`plug-in`的方式`載入`與`釋放`，更具彈性。
1. 因為系統需要處理的工作更多，因此執行速度`更慢`
1. `Dynamic Loading`載入的程式可以是`static library`、`shared library`或`執行檔`。
1. 透過`dl`這個library達成，用法參考檔案`Project_LoadSharedLib/src/main.c`
1. 可以不需要**include**library的`header file`，但是需要從`header file`或`文件`確定好要使用的**function**或**變數**的**type**
1. `dlopen`的檔名如果以`'/'`開頭則會用絕對路徑去找，若不是以的話會依照[啟動有使用 dynamic linking 的程式時尋找library路徑的順序](#啟動有使用-dynamic-linking-的程式時尋找library路徑的順序)的規則去尋找
1. 編譯指令有`-ldl`的原因是因為需要用到`dl`這個library

## Reference

1. [static link & Dynamic Link & Load](https://phchiu.pixnet.net/blog/post/39869035)
1. [Compile gcc 編譯 static link, dynamic link, dynamic load](https://medium.com/chris-place/compile-gcc-%E7%B7%A8%E8%AD%AF-static-link-dynamic-link-dynamic-load-17dfb4ef3cf1)
1. [How static linking works on Linux](https://opensource.com/article/22/6/static-linking-linux)
1. [How dynamic linking for modular libraries works on Linux](https://opensource.com/article/22/5/dynamic-linking-modular-libraries-linux#:~:text=Dynamic%20libraries%20are%20linked%20during,placed%20in%20the%20main%20memory.)
1. [4. Dynamically Loaded (DL) Libraries](https://tldp.org/HOWTO/Program-Library-HOWTO/dl-libraries.html)
1. [Shared Libraries: Understanding Dynamic Loading](https://amir.rachum.com/shared-libraries/#elf---executable-and-linkable-format)
