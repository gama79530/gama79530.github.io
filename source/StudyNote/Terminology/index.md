# 專業術語筆記

## 硬體

### BMC (Baseboard Management Controller)

BMC 是一個嵌入在`伺服器`或`工業電腦`中的微處理器，主要用於`監控`與`管理`硬體狀態，此外也可以監控作業系統的狀態，並執行與電源相關的管理操作。可以把它理解為一顆具備特殊用途的獨立處理器，通常會搭載一個極度輕量化的作業系統，該作業系統中運行著各種用於監控與遠端管理的服務（如硬體感測、遠端開關機、KVM-over-IP 等）。有了 BMC 架構，管理者即使在作業系統關機、當機，甚至尚未安裝 OS 的情況下，也能進行伺服器的遠端管理與故障排除。

### GPIO (General Purpose Input/Output)

GPIO 是一些直接連接到積體電路或開發板的針腳，這些針腳可以由軟體控制，作為輸入或輸出。根據連接對象，可以分成 `積體電路 GPIO` 與 `板級 GPIO`。一般在軟體開發中比較常接觸的是 `板級 GPIO`。每個 GPIO 可以被配置為 `input`、`output`、`analog` 或 `alternate function`。通常 GPIO 不會有預先固定的功能，開發者可以自定義操作方式及對應功能。

#### alternate function

`alternate function` 指 GPIO 的其他可選功能，例如 I2C, SPI, USART, CCP, PWM, Clock 等。GPIO 如何使用這些功能，取決於外部設備（peripheral）及其驅動程式的配置。


## 軟體

### OpenBMC

OpenBMC 是一個開源專案，其主要目的是建立一個專為 BMC 硬體設計的 `Linux 發行版（Linux distribution）`，用來提供各種伺服器遠端管理與監控功能。該專案目前由 `Linux Foundation` 主導與維護，並有多家業界廠商 (例如 IBM, Intel, Facebook, Google 等) 參與貢獻。

### U-boot (Universal Boot Loader)

[Das U-Boot: The Universal Boot Loader](https://u-boot.org/)

U-Boot 是一個`開源的`、`用在嵌入式裝置的` bootloader 。它同時是 `first-stage bootloader` 與 `second-stage bootloader` 。在安裝時可以選擇切割成兩個程式來分別扮演不同 stage 的 bootloader 也可以直接用單一程式來提供所有 stage 的功能。 U-Boot 支援了很多不同的平台，例如  M68000, ARM, Blackfin, MicroBlaze, AArch64, MIPS, Nios II, SuperH, PPC, Power ISA, RISC-V, LoongArch 與 x86 等。

#### bootloader (a.k.a. bootstrap loader)

bootloader 是一個開機過程中會使用到的小程式，它主要負責的工作是`初始化底層硬體`以及`將作業系統的 kernel 載入與啟動`。根據工作的流程通常會把負責`初始化底層硬體`的部份稱為 `first-stage bootloader` ，而負責將作業系統的 kernel 載入與啟動的部份稱之為 `second-stage bootloader` 。這兩個 stage 可以視同一個程式，也可以是兩個不同的程式。常見的 first-stage bootloader 包含 BIOS, UEFI, coreboot, Libreboot 與 Das U-Boot 等。而常見的 second-stage bootloader 則是有 GNU GRUB, rEFInd, BOOTMGR, Syslinux 與 NTLDR 等。

## 系統

### In-band, Side-band and Out-of-band

這三個術語是用來分類通訊的方式

| 分類 | 定義 |
| - | - |
| In-band | 與主要資料共用同一物理和邏輯通道 |
| Side-band | 與主要資料共用同一物理通道，但使用不同邏輯通道或協定 |
| Out-of-band | 使用完全獨立的物理和邏輯通道 |

#### 額外補充

物理通道就是實際對應到硬體建立的通道，邏輯通道則是通過軟體控制劃分的方式將物理通道切割產生的通道。

## 商業術語

### Linux distribution

簡單來說，Linux distribution（發行版）就是將 Linux 核心（Kernel）搭配一系列預先整合好的套件與工具，打包成一個可以安裝使用的作業系統。
這樣使用者就不需要從零開始安裝或設定每個元件，而是可以直接使用一個預設良好的系統環境，再依需求進一步調整。
