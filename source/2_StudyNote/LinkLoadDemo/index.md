# (C/C++) 如何編譯與使用 static /shared library

## Demo project
[LinkLoadDemo](https://github.com/gama79530/LinkLoadDemo)這個Project總共包含了6個projects以及一個資料夾
1. Project_StaticLib 模擬建立一個static library
1. Project_LinkStaticLib 模擬使用static library
1. Project_SharedLib 模擬建立一個shared library
1. Project_LinkSharedLib 模擬使用shared library
1. Project_SharedLibForDynamicLoad 模擬建立一個shared library
1. Project_LoadSharedLib 模擬動態載入一個shared library
1. SharedLib 為放置shared library的路徑

## Static Linking
### 特點
1. 編譯時期將library的程式碼加入executable，因此執行檔的體積會變大
1. 程式執行速度較快

### 建立static library
1. 寫一個header檔作為library的介面讓library使用者可以正確的呼叫屬於library的function
1. 將source檔案編譯成object files & 將object files打包成static library file(副檔名為 .a)
1. static library檔名的固定格式為 lib{name}.a
   - 在本範例中的name 由 library name (staticlink) 與 版本編號組成
   - 版本編號的第1個編碼代表大版本更動，會與前面的版本不相容
   - 版本編號的第2個編碼代表有新增功能，但library有向前相容
   - 版本編號的第3個編碼代表功能有變更，通常是bug修正或者是針對程式效能的程式重構

```bash
 # 編譯指令
 gcc src/prog1.c -c -o src/prog1.o
 gcc src/prog2.c -c -o src/prog2.o
 gcc src/prog3.c -c -o src/prog3.o

 # 打包指令
 ar rs libstaticlink.1.0.0.a  src/prog1.o  src/prog2.o  src/prog3.o
```

### 使用static library
1. 將library的header檔include後呼叫要使用的function (通常會放到 include 資料夾下)
1. 編譯成執行檔
   - -I {path}用來指示header檔放置的位置
   - -L {path}用來指示static library file放置的路徑 (通常會放到 lib 資料夾下)
   - -l {name}用來指示static library的name (前綴的 lib 與附檔名 要去掉)
   - -static 是用來提示compiler若有同名的static library與shared library的話要優先使用static library

```bash
 # 編譯指令
 gcc src/main.c -static -I include -L lib -l staticlink.1.0.0 -o main
```

## Reference
1. [static link & Dynamic Link & Load](https://phchiu.pixnet.net/blog/post/39869035)
1. [Compile gcc 編譯 static link, dynamic link, dynamic load](https://medium.com/chris-place/compile-gcc-%E7%B7%A8%E8%AD%AF-static-link-dynamic-link-dynamic-load-17dfb4ef3cf1)
1. [How static linking works on Linux](https://opensource.com/article/22/6/static-linking-linux)