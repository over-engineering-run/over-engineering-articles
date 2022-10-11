# [Day 30] Deployment - Fly.io 什麼的已經夠了啦。|【搜尋引擎製作錄】

[Github], [Over Engineering]

**礙於篇幅緣故，過多細節的部分，會挑重點講述，如有疑問歡迎留言討論**

昨天我們講述了如何準備 Dockefile，
今天我們來說一下要要如何 Deploy 到 Fly.io 上。

## 初始化 Fly.io 環境

### 安裝 Flyctl
可以參考 [install-flyctl] 教學，
在 terminal 中安裝 fly 的 command line tool。

以 mac 為例，可以用 brew 安裝
```bash
brew install flyctl
```

### Login or Sign Up
若沒有帳號，可以用 `fly auth signup` 指令創建新的帳號；
已經有帳號可以直接登入 `fly auth login`。

### 創建一個新的 Application
在 terminal 中執行 `fly launch`，
並根據提示輸入你想要新增的 App 的名稱 \<app-name\>。
接著，你會發現有一個新的 fly.io App 的設定檔 `fly.toml`。
後面我們會在 deploy 前，還會用到`fly.toml`，並更改其中設定。

至此，我們可以用 `fly status` 檢查剛剛新增的 app 狀態。


## 設定 Fly.io App
在 deploy app 前，我們有幾件事情要先做，
- 新增 App Secrets
- 新增 Volumes
- 更新 App Config

### 新增 App Secrets
參考 [Secrets and Fly Apps]，
我們需要新增 `SUPABASE_URL` 與 `SUPABASE_API_KEY` 這兩個環境變數。
```bash
fly secrets set SUPABASE_API_KEY=<api-key-value>
```
這兩個變數的值，也可以從 Supabase 平台上取得。
我們也可以列出 App 所有的 secrets 來檢查是否新增成功。
```bash
fly secrets list
```

### 新增 Volumes
參考 [Volumes] 內容，
我們必須為 Search Engine 新增一個 Volume，
如此一來，我們才不會每次 redeploy 都要重新 index 所有資料。
```bash
fly volumes create <volume-name>
```

### 更新 App Config
可以參考 [over engineering fly.toml] 中更改的部分。

- **port**
  我們根據 Dockerfile 中我們 expose 的 port，更新了 services 中的 `internal_port`。
  ```toml
  [[services]]
    internal_port = 5000
  ```
- **volumes**
  - `mounts`: 我們之前新增的 volume 名稱 \<volume-name\>。
  - `destination`: 我們搜尋引擎資料存放的位置，在 Dockerfile 我們透過環境變數 `MEILI_DB_PATH` 設定為 `/search_engine/data`。
  ```toml
  [mounts]
    source="ms_data"
    destination="/search_engine/data"
  ```

- **docker images**
  我們在這裡直接指定 App 要用哪個 docker images。
  這裡，我其實是在本地端 build 好後，push 到 dockerhub。
  ```toml
  [build]
    image = "tainvecs/over_engineering-backend:v0.0.31-so"
  ```

## Deployment
一切準備就緒後，就可以 deploy 了。
```bash
fly deploy --no-cache -a <app-name>
```
deploy 後，在 dashboard 中就可以看到如下資訊，
![fly-dashboard]
若成功，則可以透過 Hostname 中所顯示的 endpoint 對 API Server 發送 request。

![fly-monitoring]
若失敗，我們也可以從 Monitoring 中檢查log。

最後，有一點要注意，
由於 search engine 在建立索引時相當吃記憶體，
而 Fly.io 免費方案，記憶體限制只有 256 MB 的額度，
遠遠不夠一般搜尋引擎使用。 QAQ
尤其隨著 index 的 docs 數量增加，
光維持 search engine 運作所需要的記憶體就會增加。

因此，我們這次並沒有 index 我們資料庫中，所有8萬多篇的文章，
而是只 index 了大概 6千多篇文章。

## 結語
原本是想在單獨一篇說的，但沒想到 deployment 會花兩篇，
我連標題中要用的動畫名都想好了 "道別的篇章就用 Future Work 點綴吧" 可惜沒機會用了。 =w=

這次很感謝 Kirby 的邀請，我才會參加鐵人賽。
過程中也學到了許多，
尤其在實作時，用到的幾乎所有工具都與我工作用的不同，也是幾乎都是第一次用，
像：Flask, Meilisearch, Supabase, and Fly.io 等都是初次接觸。
連寫 Tech 文章也是第一次 XD。

唯一有點遺憾的是開始太晚，很多地方做的都相對簡略。
原本預計一個月的實作時間，沒想到拖到一個半月，
還簡略了許多功能的實作 :sweat_smile:
像是 NLP 的許多處理都有努力空間；
而統計資訊、trending 的部分更是刪減到相當簡略。

儘管如此，回頭看來，還是覺得收穫滿滿，
也希望這系列的文章也能帶給大家一些收穫，
當然，如有什麼建議也歡迎留言討論。 :)


[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/

[install-flyctl]: https://fly.io/docs/hands-on/install-flyctl/
[Secrets and Fly Apps]: https://fly.io/docs/reference/secrets/
[Volumes]: https://fly.io/docs/reference/volumes/
[over engineering fly.toml]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/fly.toml

[fly-dashboard]: https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day30-01-fly-io.png
[fly-monitoring]: https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day30-02-fly-io.png
