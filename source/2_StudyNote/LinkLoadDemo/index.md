# (C/C++) 如何編譯與使用 static /shared library

## Demo project
[LinkLoadDemo](https://github.com/gama79530/LinkLoadDemo)這個Project總共包含了6個projects以及一個資料夾
1. Project_StaticLib 模擬建立一個static library
1. Project_LinkStaticLib 模擬使用static library
1. Project_SharedLib 模擬建立一個shared library
1. Project_LinkSharedLib 模擬使用shared library
1. Project_SharedLibForDynamicLoad 模擬建立一個shared library
1. Project_LoadSharedLib 模擬動態載入一個shared library
1. SharedLib 為佈署shared library的路徑

## Static Linking
### 特點
1. 編譯時期將library的程式碼加入executable，因此執行檔的體積會變大
1. 程式執行速度較快

### 建立static library
1. 寫一個header檔作為library的介面讓library使用者可以正確的呼叫屬於library的function
1. 將source檔案編譯成object files
1. 將object files打包成static library file
   - static library檔名的固定格式為 lib{library name}.a

```bash
 # 編譯指令
 gcc src/prog1.c -c -o src/prog1.o
 gcc src/prog2.c -c -o src/prog2.o
 gcc src/prog3.c -c -o src/prog3.o

 # 打包指令
 ar rcs libstaticlink.a src/prog1.o src/prog2.o src/prog3.o
```

### 使用static library
1. 將library的header檔include後呼叫要使用的function (通常會放到 include 資料夾下)
1. 編譯成執行檔
   - -static 用來指示若有同名的static library與shared library的話會優先使用static library (預設為優先使用shared library)
   - -I {path}用來指示header檔放置的路徑，-I與{path}中間可以不需要空格隔開
   - -L {path}用來指示static library file放置的路徑 (通常會放到 lib 資料夾下)，-L與{path}中間可以不需要空格隔開
   - -l {library name}用來指示library name (前綴的 lib 與附檔名 要去掉)，-l與{library name}中間可以不需要空格隔開

```bash
 # 複製lib指令
 cp -r ../Project_StaticLib/include .
 cp ../Project_StaticLib/libstaticlink.a lib

 # 編譯指令
 gcc src/main.c -static -I include -L lib -l staticlink -o main
```

## Dynamic Linking
### 特點
1. 編譯時期並不將library的程式碼加入executable，因此執行檔會比較小
1. 程式啟動啟動時會再依照環境變數或預設路徑去把library的內容link到程式中，因此執行較慢
1. 因為是執行時才會去link，因此多個程式共用一個library時只需載入到memory一次

### 建立shared library
1. 寫一個header檔作為library的介面讓library使用者可以正確的呼叫屬於library的function
1. 將source檔案編譯成object files
1. 將object files打包成shared library file
   - version code: 代表大版本更動，可能造成與前面的版本不相容
   - minor code: 代表有新增功能，但library有向前相容 
   - release code: 代表功能有變更，通常是bug修正或者是針對程式重構 
   - real name: 實際的檔案名稱，慣用格式為 **lib{library name}.so.{version code}.{minor code}.{release code}**
   - linker name: 要編譯執行檔時linker尋找library的檔案名稱，慣用格式為 **lib{library name}.so**
   - so name: 執行檔要啟動時linker尋找library的檔案名稱，慣用格式為 **lib{library name}.so.{version code}**
1. 指令講解
   - -fPIC 是用來提示compiler要將檔案編譯成 position-independent code
   - -shared 是用來提示compiler要將檔案編譯成shared object
   - -Wl,{option} 是用來將option傳給linker的指令，要傳給linker的指令用逗點隔開
   - -soname 是linker的指令，用來提示當編譯好的執行檔啟動時，要用soname去找到shared library而不是使用real name去找，設定soname可以增加程式的彈性   

```bash
 # 編譯指令
 gcc src/prog1.c -c -fPIC -o src/prog1.o
 gcc src/prog2.c -c -fPIC -o src/prog2.o
 gcc src/prog3.c -c -fPIC -o src/prog3.o

 # 打包指令
 gcc src/prog1.o src/prog2.o src/prog3.o -shared -Wl,-soname,libdynamiclink.so.1 -o libdynamiclink.so.1.0.0 
```

### 使用shared library
1. 將library的header檔include後呼叫要使用的function (通常會放到 include 資料夾下)
1. 佈署share library
   - 將shared library檔案複製到部署路徑資料夾下
   - 建立linker name的soft link
   - 建立so name的soft link
1. 編譯成執行檔: 會依據linker name去找library
1. 設定環境變數: 需要把佈署路徑加到環境變數 **LD_LIBRARY_PATH**，執行時執行檔才找的到shared library

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
1. 編譯時並不將library的內容連結，而是使用程式控制library的載入與釋放，更具彈性。
1. 通常以plug-in的方式使用
1. 執行速度更慢

## Reference
1. [static link & Dynamic Link & Load](https://phchiu.pixnet.net/blog/post/39869035)
1. [Compile gcc 編譯 static link, dynamic link, dynamic load](https://medium.com/chris-place/compile-gcc-%E7%B7%A8%E8%AD%AF-static-link-dynamic-link-dynamic-load-17dfb4ef3cf1)
1. [How static linking works on Linux](https://opensource.com/article/22/6/static-linking-linux)