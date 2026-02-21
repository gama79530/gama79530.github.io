# IPMI 入門的 15 個問題

## 一、IPMI 基本定位（概念層）

### 1. IPMI 在整個伺服器系統中扮演什麼角色？它和 BIOS、OS 的關係是什麼？

IPMI 具有雙重面向，它既是一個`通訊規範`同時也是一個`管理介面`。

#### 通訊規範

在這個面向上 IPMI 定義了如何使用其他已經存在的標準通訊管道(e.g. `I2C`, `LPC`, `Serial/Modem`, `LAN` etc.)來進行元件之間的溝通方式以及資料交換的格式。

```{note}
通過這種方式， IPMI 實現了跨平台的功能。
```

IPMI 基本是以 message base 的方式進行溝通，所有的資料都是通過 message 的方式打包傳輸。但是根據場合的不同打包的方式也不同，因此定義出了像是 `IPMB`, `ICMB` 這些打包資料的規範。

#### 管理介面

在這個面向上 IPMI 定義了許多標準的系統管理功能，例如`清點硬體數量`,`監控硬體狀態`,`logging 硬體狀態`, `異常復原`等。常見的溝通對象有 `OS`, `BIOS`,`其它周邊設備(e.g. 風扇, 溫度計 etc.)`。除了標準功能之外也提供了一些如何新增自定義指令的規範讓 OEM 廠商可以自訂屬於自己的獨特功能來做產品差異化。

```{note}
IPMI 使用文字介面，沒有 GUI
```

#### 具體實現

概念上 IPMI 是一個**規範/介面**，所以需要安裝一個**實作了 IPMI 規範的韌體 (Firmware)** 才能運作。IPMI 通常是在獨立於 CPU 之外的 BMC 的系統上面執行，該 firmware 會與 OS 以及 BIOS 通訊用來監控系統的狀態以及發送指令操作，它與 `BIOS / OS` 之間是緊密合作但又彼此獨立的關係。

在緊密合作的面向上是通過 `In-Band` 的方式（通常是硬體提供的傳輸介面）與 `BIOS / OS` 溝通，如果是通過這種方式與 `BIOS / OS` 溝通的話就必須要 `OS / BIOS` 是在正常工作的狀態才能運作。
在獨立的面向上通過 `Out-of-Band` 的方式（通常是網路介面）與 `BIOS / OS` 溝通，所以即便 `OS / BIOS` 不是在正常運作的狀態也能正常運作。

通常會是有些核心功能使用 `In-Band` 的方式實作，而比較偏向管理操作的功能則是通過 `Out-of-Band` 的方式實作。但這並不是硬性規定，也可以對某些管理功能同時使用兩種通訊方式去實作當作互相的備援機制。

```{note}
OpenBMC 中實作此介面的專案可在 [openbmc/phosphor-host-ipmid](https://github.com/openbmc/phosphor-host-ipmid) 找到。
```

### 2. 什麼情況下可以使用 IPMI？什麼情況下 IPMI 仍然可以工作（例如 OS 不存在或當機）？

一般來說 IPMI 是在 BMC 上面獨立運行，所以只要 BMC 電壓足夠的話就能使用（即便 BMC 的系統沒有開機）。  

但功能是否正常要看該功能對系統的依賴程度

- `In-Band`: 通訊管道建立在 OS 之上。如果 OS 當機或未載入驅動，這條管道會直接**斷裂**，導致指令完全無法發送（連錯誤訊息都不會有，直接 Timeout）。
- `Out-of-Band`: 通訊管道獨立於 OS。即便 OS 當機，管道依然暢通。如果此時去存取一個依賴 OS 的功能（例如讀取 OS Hostname），BMC 頂多是回傳一個**錯誤代碼 (Error Code)** 表示無法獲取，這屬於「功能邏輯上的異常」，而非「系統運作層面的崩潰」，BMC 本身依然穩定運作。

### 3. IPMI 為什麼被認為是「舊但仍然重要」的管理介面？

1. 與新技術（e.g. `Redfish`）並不衝突，同時因為 IPMI 的系統資源開銷小，所以可以做為很好的備援通道。
2. 已經長時間是通用的標準，所以相關的資源非常多，不論是自動化管理的腳本或者是支援的硬體廠牌。

## 二、IPMI 通訊與架構（架構層）

### 4. IPMI 命令是如何送進 BMC 的？有哪些常見的傳輸通道（interface）？

IPMI 命令的傳送可以區分成兩個面向:

- 通訊協定
- 實體線路 / 介面

關於`通訊協定`的部分是採用 IPMI Messaging 的方式，所有指令都必須封裝成統一格式的 message（包含 NetFn、Command、Data 等），這是所有傳輸通道的基礎。
所有的線路都是在這個基礎上去傳送資料與溝通。  
`實體線路 / 介面`的部分則是要看硬體線路（通常線路的鋪設會與對應到的功能實作有關）的架構影響。

常見的通道分類可以分成

- 系統介面 (System Interface) - In-Band
- 管理匯流排 (Management Bus)
- 網路介面 (Network Interface) - Out-of-Band
- 序列/Modem 介面 (Serial/Modem Interface)

#### 系統介面 (System Interface) - In-Band

這是 **Host OS** 與 **BMC** 溝通的管道。雖然硬體底層走的是 Bus，但軟體驅動層定義了標準介面：

- **KCS (Keyboard Controller Style)**：最常見的介面，跑在 **LPC Bus** 上。它模擬傳統鍵盤控制器，速度慢 (Byte-by-Byte) 但相容性極高，是 x86 伺服器標準。
- **BT (Block Transfer)**：同樣跑在 **LPC Bus** 上，但支援區塊傳輸，效率較高。
- **SSIF (SMBus System Interface)**：跑在 **I2C/SMBus** 上，速度最慢，常用於非 x86 或針腳受限的環境。

原則上這三種管道功能是相同的，差別在於傳輸速度。對於指令的使用者來說並不需要了解是從哪個管道傳送，這部分會由 OS Driver 去自動偵測與決定。

```{note}
還有一個現在已經不常用的通道 `SMIC (System Management Interface Chip)` ，這個通道的功能與前面三個通道的功能相同，最初目標是要替代 KCS ，但最後因為相容性的問題並未成功。
```

#### 管理匯流排 (Management Bus)

`IPMB` 是用來與其他控制器通訊用的線路，通常是用 I2C 實現。最常見的使用場景是與機箱的控制器做溝通。

`ICMB` 則是一個橋接器，用來串聯多個 IPMB 線路以實現多機箱間的管理通訊，可用於多機箱間的管理。

#### 網路介面 (Network Interface) - Out-of-Band

**IPMI LAN Interface**是 IPMI 標準定義的網路協定層，規範如何將 IPMI message 封裝成 UDP 封包（通常為 port 623），用於遠端管理。無論底層硬體如何連接，只要能傳遞這種格式的封包就算支援 IPMI LAN。

以下是常見的底層硬體連接方式：

- **Dedicated NIC (專用網孔)**：BMC 擁有獨立的實體 RJ45 網孔，線路直通 BMC。
- **Shared NIC (共享網孔)**：BMC "寄生" 在主機的一般網卡 (LOM) 上。
  - **NC-SI (Network Controller Sideband Interface)**：現代標準的 Side-Band 介面。網卡會過濾出 BMC 的封包 (Port 623) 並轉發給 BMC，速度快且支援完整網路功能。
  - **SMBus (System Management Bus)**：早期做法，因頻寬太低，現多僅用於讀取網卡狀態。

#### 序列介面 (Serial Interface)

- **Basic Mode**：透過傳統 RS-232 物理線路直接連接。
- **SOL (Serial Over LAN)**：這是目前最常用的應用。BMC 將 Host 的序列訊號 (UART) 封裝成網路封包傳送給遠端。這讓管理者在 Host OS 網路斷掉或死當的時候，還能遠端看到開機時的文字畫面 (Console)。

```{node}
**Modem**：早期支援透過 Modem（撥號）遠端管理，現今較少見。
```

### 5. IPMI LAN 與本地（如 KCS）存取在用途與限制上有什麼差異？

從功能上來區分 IPMI LAN 主要是用在遠端管理上，當 host 不處於正常工作的時候（當機, 關機等）依舊可以通過 IPMI LAN 的方式來控制系統的一些功能（電源控制, 硬體狀態監控等）。  
而本地 KCS 則是用在主機內部通訊，當主機不能正常工作時這條線路就沒辦法工作。

```{note}
一般來說 IPMI LAN 的傳輸速度會比 KCS 還要快。
```

基於安全性，通過 LAN 的通訊會需要一個身分驗證的機制。而 KCS 因為算是 in-band 的方式所以不需要這個機制。

```{note}
IPMI LAN 的安全機制放到現在已經算是防禦強度比較弱的機制，這也是會出現新標準想要取代它的原因。
```

### 6. 一個 IPMI command 在 BMC 內部大致會經過哪些處理步驟？

1. 接收：BMC 透過某個介面（如 KCS、LAN、IPMB 等）收到一個 IPMI 指令封包。
2. 驗證與解碼（僅 IPMI LAN 需要）：若是經由 IPMI LAN，BMC 會先針對網路協議（如 RMCP、Session、加解密）進行解碼，然後處理 session 與身分驗證，確認使用者權限。
3. 解包：解包：BMC 解析外層協定（如 KCS、BT、LAN 等），取得核心 IPMI message，並取出 NetFn、Command、Data 等欄位。
4. 分派：根據 NetFn 和 Command，分派到對應的 command handler。
5. 執行：handler 執行對應的動作（如查詢感測器、控制電源等）。
6. 回應：handler 產生 Response Data 和 Completion Code。
7. 打包：BMC 將 Completion Code 與 Response Data 依 IPMI message 格式包裝成 Response 封包。
8. 回傳：透過原本的通道（如 KCS、LAN 等）回傳給發送端。

## 三、IPMI 命令與功能分類（功能層）

### 7. IPMI 命令大致可以分成哪些類型（例如電源, sensor, storage）？

| NetFn (Hex) | 名稱 | 用途說明 |
|---|---|---|
| 0x00 0x01| Chassis | 常見的機箱`控制`與`狀態`功能 |
| 0x02 0x03 | Bridge | 把訊息橋接給另外一個 bus 的功能，只會出現在橋接節點上 |
| 0x04 0x05| Sensor/Event | `Event Message`, `Sensor` 的設定與傳輸 |
| 0x06 0x07 | Application | IPMI 定義的標準命令，例如: BMC 管理、日誌、Watchdog |
| 0x08 0X09| Firmware | `韌體更新`, `裝置管理`。除了包裝的格式之外內容的格式由個設備自行解讀 |
| 0x0A 0x0B| Storage | SEL（事件日誌）、FRU（硬體資訊）、SDR（感測器描述）存取 |
| 0x0C 0x0D| Transport | 用來`設定`或`操作`特定的`媒體介面`。例如:LAN 設定、Serial/SOL 管理 |
| 0x0E 0x2B| Reserved |  |
| 0x2C 0x2D| Group Extension | 非 IPMI 標準而是某些有影響力的團體提供的擴展命令。第 1（request）或第 2（response）個 data byte 代表組織 ID |
| 0x2E 0x2F| OEM/Group | 廠商自訂命令，前 3 個 data bytes 用 IANA 編號標示廠商 |
| 0x30 0x3F| Controller-specific OEM/Group | 由硬體廠商提供且與硬體綁定的指令，命令歸屬由控制器的 Manufacturer ID 識別  |

```{note}
NetFn 大部分是成對的，偶數代表 `request`, 奇數代表 `response`。
```

### 8. 什麼是標準 IPMI command？什麼是 OEM command？為什麼需要 OEM command？

#### OEM Command

由廠商自定義的 command ，通常會是針對硬體相關的功能擴充。需要另外查閱廠商提供的文件才能了解怎樣使用。這些功能可能是廠商的獨門絕活並不具備通用性，也可以用來把多個標準功能打包成一個客製化命令方便使用。這類的指令通常只能發送 `raw command` 手動指定 `NetFn`, `Command`, `Data`

#### 標準的 IPMI command 

在 IPMI 的規範裡有明確的定義，涵蓋了伺服器管理的通用功能（如電源控制、sensor 存取、event log）。這些 command 只要平台有支援 IPMI 標準就要支援，因此具有跨平台的特性。因為這些指令的標準化，所以在常見的工具可以直接使用高階指令來下命令（如 `ipmitool power status`, `ipmitool sensor`）。

#### OEM Command

由廠商自定義的 command，通常針對硬體相關的功能擴充。需要另外查閱廠商提供的文件才能了解怎樣使用。這些功能可能是廠商的獨門絕活，並不具備通用性。也可以用來把多個標準功能打包成一個客製化命令，方便使用。這類指令通常只能用 `ipmitool raw`，手動指定 `NetFn`, `Command`, `Data` 來發送。

```{note}
OEM command 通常僅適用於特定品牌或型號，跨平台相容性較差。
```

### 9. IPMI 是如何表示與存取 Sensor（溫度、電壓、風扇）的？

IPMI 是通過 SDR(sensor data record) repository 來管理 sensor。 所有的 sensor 在這個 repository 裡面都會有一個對應的資料。這些資料的來源可以是以 static 的方式通過 config 在系統初始化的時候載入，也可以 dynamic 的方式通過 master 發送 broadcast 的方式去主動等回應後加入。

SDR 由三大部份組成

1. RECORD HEADER
2. RECORD `KEY` FIELDS
3. RECORD BODY

#### RECORD HEADER

這個部份對所有的紀錄都是同樣格式，會分別紀錄

- Record ID: 這個 id 就像是 map 的 indexing 是用來加速查找使用，ID 是有可能重新被指派給另外一筆紀錄。 
- SDR Version: SDR 格式版本編號，會與 record type 一起使用
- Record Type: 紀錄 sensor 的 type, 會影響到後面的 key field 與 record body 格式
- Record Length: `key` + `body` 的大小(bytes)

#### RECORD KEY FIELDS

與 Sensor 有關的格式是由 `Sensor Owner ID`, `Sensor Owner LUN` 以及 `Sensor Number` 組成。這三個 field 會形成一個 `unique key` 。

`Sensor Owner ID` 組成有兩部份

- [0]: 用來指示負責管理的是硬體還是軟體。
- [7:1]: `address` 或者是 ID, 看是由硬體還是軟體管理決定

`Sensor Owner LUN` 組成有三部份

- [1:0]: `Sensor Owner LUN` 用來標定與 sensor 溝通的 IPMB message 。 
- [3:2]: 在`對 FRU 做讀寫`的時候座標定用的 bits
- [7:4] 指定用來與 sensor 做溝通的 `channel number` 

`Sensor Number` 則是在前面兩個組成之後在做編號用來區分實體的 sensor

#### RECORD BODY

根據 record type（如 `Full Sensor`, `Compact Sensor`, `Event-only`）決定 body 的格式與內容。例如 `Full Sensor Record` 會包含比較完整的資訊，而 `Compact Sensor Record` 或 `Event-Only Record` 則只記錄必要資訊。

比較重要的資訊有

- Entity ID: 用來表示 sensor 在監控的物理實體的種類(e.g. `processor`, `disk`, etc.)
- Entity Instance: 由兩個部份組成用來對 instance 做編號
  - [6:0]: entity number
  - [7]: 用來表示是 `physical entity` 還是 `logical entity`
- Sensor Type: 代表 sensor 的 type (e.g. `溫度`, `電壓`, etc.)
- Event / Reading Type Code: 用來表示 data 要`怎樣解讀`，當了解了怎樣解讀之後就要搭配指令實際去抓資料並套用公式來轉換成實際數值。

Event / Reading Type Code 可以大致分成下面這幾類

- Discrete: 用 `bit field` 的方式來表示狀態。最多可以表示 15 種狀態。可以用來回報通用狀態也可以用來回報 sensor-specific 的狀態。
- Digital: 只有兩種狀態的 Discrete type 的子集合。
- Threshold: 根據 value 以及 threshold 來改變事件狀態， offset 可以看做是 discrete type 的特例。從 sensor 抓資料的時候會同時回傳 `analog reading` 以及與 threshold 比較過後對應的 bit field
- OEM: 由 OEM 自行定義

```{tip}
- `Sensor Type` 可以去 spec p531 的 `Table 42-, Sensor Type Codes` 查表  
- `Event / Reading Type Code` 可以去 p529 的 `Table 42-, Generic Event/Reading Type Codes` 查表
```

#### 怎樣得到數值

SDR 只告訴我們要如何解讀 sensor 回傳的數值讀數，在解讀之前需要通過 IPMI 的指令 (e.g. `Get Sensor Reading`) 來取得讀數。另外因為不同 sensor 的單位, 解讀方式全都不一樣，所以通常也是直接依賴工具幫忙轉換成人類好讀的數據。

## 四、實務操作與工具（操作層）

### 10. ipmitool 是做什麼用的？它在實務上扮演什麼角色？

ipmitool 是個通用的 client 端工具，用來把`標準的 IPMI 指令`以及回傳值封裝成人類可讀的格式，可以用它與支援 IPMI 的系統做溝通。在實務上因為它提供了對 `machine` 或 `sensor` 發送命令去設定或取得狀態的功能所以適合使用在`診斷`,`測試`,`維運`,`自動化腳本`等地方(e.g. `電源控制`, `SDR 存取`, etc.)。

### 11. 透過 IPMI 可以對機器做哪些「危險但必要」的操作？

- 電源管理(NetFn: Chassis) - 直接控制 host 的電源狀態。不正常的操作有可能造成資料遺失
- 韌體更新(NetFn: Firmware) - 更新韌體版本與裝置管理。操作失敗可能導致硬體無法使用
- 網路設定管理(NetFn: Transport) - 修改 ip, gateway 等網路設定。沒操作好可能造成機器無法通過網路只能通過實體線路去控制。
- 帳號管理(NetFn: Application) - 修改 ipmi 的帳號密碼以及權限。若操作不當可能影響安全性或導致無法登入管理介面。
- 清除 SEL(NetFn: Storage) - 刪除故障記錄，可能失去追蹤問題的依據。
- Reset BMC(NetFn: Chassis)

### 12. IPMI 的事件（SEL）是什麼？它的用途是什麼？

<!-- ??? -->

## 五、限制、風險與 OpenBMC 關聯（整合層）

### 13. IPMI 在安全性上有哪些先天限制或歷史問題？

<!-- ??? -->

### 14. 在 OpenBMC 裡，IPMI 和 D-Bus 的關係是什麼？

<!-- ??? -->

### 15. 為什麼在 OpenBMC 專案中，很多新功能不再優先設計成 IPMI？

<!-- ??? -->
