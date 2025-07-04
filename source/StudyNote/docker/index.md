# Docker Tutorial

## 目錄

- 什麼是 Docker ，Docker 的重要概念
- Image 管理
- Dockerfile 介紹
- docker-compose.yml 介紹
- 什麼是 Linux capabilities，與 Docker container 的關係

## 什麼是 Docker，Docker 的重要概念

### 什麼是 Docker

Docker 的定位很接近`虛擬機（Virtual Machine）`，它提供一個輕量級、隔離的環境，可用來編譯原始碼、執行應用程式、進行測試等。不過相較於傳統的虛擬機，Docker 更加輕量，對系統資源的負擔也較小（因為與 host 共用 kernel），而且部署與使用方式也相對簡單。

Docker 有幾個重要的基本概念：

- Image
- Container
- Volume
- Network

### Image

Image 像是系統的快照，可以把系統的狀態完整保存。比較重要的特點是 Image 是唯讀的檔案，只能整體重建，不能做部分修改。

#### Image 相關指令

```bash
docker images --help
docker image rmi --help
```

### Container

Container 是 Image 的實體化，兩者的關係就像物件導向裡的`類別`與`實體`的關係。

#### Container 相關指令

```bash
docker ps --help
docker run --help
    -it, -d, -p, -e,  -P,  --env-file,  --mount
docker stop --help
docker start --help
docker exec --help
docker create --help
docker rm --help
    -f
```

### Docker Volume

Docker Volume 的設計是為了讓 Container 可以持久化儲存資料。由於 Image 本身是唯讀的，若程式會產生資料（例如資料庫的儲存檔），這些資料應該被存放在 Volume 中，才能在 Container 停止或刪除後仍保留。

#### Docker Volume 相關指令

```bash
docker volume create --help
docker volume ls --help
docker volume rm --help
docker volume prune --help
```

### Docker Network

Docker Network 允許 Container 之間的網路溝通，並與 Host 的網路隔離。這樣設計有助於提高安全性與可管理性，也能支援多 Container 應用部署架構（如微服務）。

#### Docker Network 相關指令

```bash
docker network ls --help
docker network create --help
docker network inspect --help
```

## Image 管理

要啟動 container 之前必須先有一個 image 。要如何建立 image ? 可以使用指令來建立，也可以從網路上的 `Registry` 去取得現成的 image 。  

### 指令快照

我們可以使用指令可以把`執行中`的 container 快照下來

#### 指令快照相關指令

```bash
docker commit --help
```

### Dockerfile

我們使用指令可以搭配 `Dockerfile` 來建立。Dockerfile 就像是個食譜，用來描述要如何建立一個 image 。

#### Dockerfile 相關指令

```bash
docker build --help
    -t,  --target,  --no-cache
```

### Registry

若將 Dockerfile 想像成建構 Image 的`食譜`，那 Registry 就是存放各種已建構好 Image 的`倉庫`。
最常見的 Registry 是 [Docker Hub](https://hub.docker.com/)，我們可以從中搜尋、下載，甚至推送自定義的 image。
在實務上我們可能會用 `git repository` 去對單一食譜做版本控制。我們通常會搭配 `tag` 機制，將相同應用的不同版本清楚標示在 Registry 中，方便團隊或使用者拉取特定版本的 Image。

#### Registry 相關指令

```bash
docker tag --help

docker search --help
docker pull --help
docker push --help
```

## Dockerfile 介紹

標準的 Dockerfile 架構有下面幾個部分

- Stage (如下圖紅色框框部分)
- Base Image (如下圖藍色框框部分)
- Layer (如下圖黃色框框部分)

![dockerfile_struct](../../_static/docker/dockerfile_struct.png)

### Layer

每一個 `Layer` 會對應到建構環境要使用的操作指令，例如 `RUN`, `ENV`, `ARG`, `USER` 等。有哪些指令以及各自的功能可以參考 [Dockerfile reference](https://docs.docker.com/reference/dockerfile/) 。

Docker 在 build 的過程中會幫每個 layer 建立 cache，建立 cache 的好處是如果要再重新 build 的時候可以取出來使用，加快 build 的速度。 Docker 在 build 的時候會自動檢查是否可以套用 cache ，但如果想要強制不使用 cache 的話可以在 build 指令加入 `options` 或者直接使用指令把 cache 清除之後再重建。

#### Cache 相關指令

```bash
docker builder prune --help
```

### Base Image

每個 stage 都會有一個 `base image` ， base image 是目前這個 stage 的基礎環境，其實際上也是一個特殊的 Layer。 提供了一個基礎的環境讓你可以再使用指令對這個環境做改造來產生新的環境。

### Stage

Dockerfile 的 stage 主要是將 image 的建構分階段。每一個階段都可以是一個獨立的 image ，但預設只有最後一個 stage 的 image 會被產生。

會使用 multi-stage 的原因通常是因為要精簡 image 的 size 。下面是一個官方提供的範例:  
你要從原始碼開始搭建一個實際運行的 container ，因此需要先做編譯，接著再佈署。 有些工具是只有在編譯時有需要但執行時不需要。例如`編譯 c 與 c++ 程式的 gcc` 、 `編譯 Java 的 JDK`。因此可以在 stage 1 安裝這些工具並且執行編譯，在 stage 2 把 stage 1 編譯出來的結果複製進來並安裝相關會使用到的工具。

## docker-compose.yml 介紹

在官方的 turtioral 裡面有提到，**每一個 container 應該要努力做好一件小事，而不是完成一件大事**。最簡單的例子就是架設一個 web 網站。通常 web 網站會需要一個`前後端 server` 以及一個 `資料庫`。 官方的建議是要將這兩個部分拆分成兩個 container 去處理，每個 container 各自把各自的功能設定好。但如果要這樣做的話會有一個問題是不同 container 之間的通訊要自己手動設定，這是個麻煩且容易出錯的工作。在這個使用場景之下可以使用 `docker compose` 來解決這個問題。

### docker compose 相關指令

```bash
docker compose up --help
     --build, -d
docker compose run --help
docker compose create --help
docker compose start --help
docker compose down --help
docker compose build --help
    -build-arg
```

<!--  -->

## 什麼是 Linux capabilities, 與 docker container 有何關係

<!-- #### 相關指令

```bash
``` -->