# Memo

這裡只先記錄已經讀過哪些部份以及重點大項，之後再看閱讀的進度慢慢把重點納入。

## What I wish I’d known about Yocto Project

[reference](https://docs.yoctoproject.org/what-i-wish-id-known.html)

1. 使用 Git，而不是 tarball
2. 多了解 layer index，可以看看哪裡有現成的資源可以使用 
3. 盡量使用供應商提供的 BSP layer
4. 不要把全部東西放到單一 layer ，要盡量依照功能模組拆開成多個 layer
5. 不要去動 Poky
6. 不要過度依賴 google 文件搜尋的結果，有可能會搜到舊版本
7. 了解基本的工作流程
   - Fetch – get the source code
   - Extract – unpack the sources
   - Patch – apply patches for bug fixes and new capability
   - Configure – set up your environment specifications
   - Build – compile and link
   - Install – copy files to target directories
   - Package – bundle files for installation
8. 知道要如何產生 dependency graph
9. 了解 tmp 與 work 這兩個目錄
10. 不只能 build image ， 也可以 build 單一 package
11. 了解 recipe 與 package 的差異
12. 知道被打包之後的檔案系統結構
13. 客製化自己的 image 與 recipe
14. 列出了應該要學會的技能
    - deal with corporate proxies
    - add a package to an image
    - understand the difference between a recipe and package
    - build a package by itself and why that’s useful
    - find out what packages are created by a recipe
    - find out what files are in a package
    - find out what files are in an image
    - add an ssh server to an image (enable transferring of files to target)
    - know the anatomy of a recipe
    - know how to create and use layers
    - find recipes (with the OpenEmbedded Layer index)
    - understand difference between machine and distro settings
    - find and use the right BSP (machine) for your hardware
    - find examples of distro features and know where to set them
    - understanding the task pipeline and executing individual tasks
    - understand devtool and how it simplifies your workflow
    - improve build speeds with shared downloads and shared state cache
    - generate and understand a dependency graph
    - generate and understand BitBake environment
    - build an Extensible SDK for applications development
15. 介紹後面文章主要針對的主題
    - Look Through the Yocto Project Development Tasks Manual
    - Look Through the Yocto Project Application Development and the Extensible Software Development Kit (eSDK) manual
    - Learn About Kernel Development
    - Learn About Board Support Packages (BSPs)
    - Learn About Toaster
    - Discover the VSCode extension
    - Have Available the Yocto Project Reference Manual

## Transitioning to a custom environment for systems development

[reference](https://docs.yoctoproject.org/transitioning-to-a-custom-environment.html)

1. Make a list of the processor, target board, technologies, and capabilities that will be part of your project.
2. Set up your board support.
3. Find and acquire the best BSP for your target.
4. Based on the layers you’ve chosen, make needed changes in your configuration.
5. Add a new layer for any custom recipes and metadata you create.
6. Create your own layer for the BSP you’re going to use.
7. Write your own recipe to build additional software support that isn’t already available in the form of a recipe.
8. Now you’re ready to create an image recipe.
9. Build your image and refine it.
10. Consider creating your own distribution.

## What is the Yocto Project

### Features

- Widely Adopted Across the Industry
- Architecture Agnostic
- Images and Code Transfer Easily
- Flexibility
- Ideal for Constrained Embedded and IoT devices
- Comprehensive Toolchain Capabilities
- Mechanism Rules Over Policy
- Uses a Layer Model
- Supports Partial Builds
- Releases According to a Strict Schedule
- Rich Ecosystem of Individuals and Organizations
- Binary Reproducibility
- License Manifest

### Challenges

- Steep Learning Curve
- Understanding What Changes You Need to Make For Your Design Requires Some Research
- Project Workflow Could Be Confusing
- Working in a Cross-Build Environment Can Feel Unfamiliar
- Initial Build Times Can be Significant