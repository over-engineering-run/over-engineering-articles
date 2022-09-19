# [Day 04] 什麼是搜尋引擎 III - 在 IT 邦尋求答案是否少了些什麼 |【搜尋引擎製作錄】

[Github], [Over Engineering]

今天我們將進入簡單的實作環節，
在本地端 (localhost)，使用 [Meilisearch] 架設一個簡單的搜尋引擎。


## Meilisearch
本系列文章選用 `Meilisearch` 的原因，
是因為它相較業界常用的 `Elasticsearch` 更加容易學習。
此外，作者也比較過其他 open source 搜尋引擎，
如：`zinc` 或是 `typesense` 等，
`Meilisearch` 的 documentation 將較而言更加完整易讀，
功能也十分齊全、可靠，使用者介面也十分友善。

本次實作會參照 [meilisearch quick start] 中的內容，
作者的環境為

- macOS `12.0.1 Intel`
- curl `7.77.0`
- Meilisearch `0.28.1`

接下來的說明，會以此環境作為依據，linux 應該也是相同適用。
至於 windows 或其它作業系統環境，還請參考 [meilisearch quick start] 。
如果在安裝或是設置上有任何問題，也歡迎在下面留言討論。

若想跳過安裝及建立索引的部分，或是使用 docker 也可以參考最後的附錄。


### 安裝並執行 Meilisearch

在終端機 (terminal) 中執行以下指令

- 下載 `Meilisearch` 應用程式
  ```bash
  curl -L https://install.meilisearch.com | sh
  ```

- 於本地端執行 `Meilisearch` server
  ```bash
  ./meilisearch
  ```
從下圖可以看到執行結果，並在回應資訊中看到，
`Meilisearch` server 的位置便在預設的 `127.0.0.1:7700`。

![alt text](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day04-ms1.png)

打開瀏覽器，拜訪本地端 `Meilisearch` server，
便可見以下的 `Meilisearch` 預設的 mini dashboard (小型儀表板)。
從右上角可見，現在我們還沒有建立任何`索引`，也沒有任何資料供搜尋。

![alt text](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day04-ms2.png)


### 建立索引

讓 `Meilisearch` server 持續在本地端運作。
切到終端機其他視窗，執行以下指令，來進一步使用測試資料建立`索引`。

- 下載測試資料集 `movies.json`
  ```bash
  curl https://docs.meilisearch.com/movies.json \
       --output movies.json
  ```

- 發送 POST Request 給 `Meilisearch` server 並建立`索引`
  ```bash
  curl -X POST 'http://127.0.0.1:7700/indexes/movies/documents' \
       -H 'Content-Type: application/json' \
       --data-binary @movies.json
  ```

從下圖中可以看到，回應訊息中任務的狀態中顯示 **"enqueued"** ，
便代表任務已經排入工作佇列 (Queue) 中，並等待執行。

![alt text](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day04-ms3.png)


### 開始搜尋

大約等待30秒到一分鐘後重新整理，可以看到 mini dashboard 中，
出現了新的`索引` movies，並有 31,944 筆資料。

![alt text](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day04-ms4.png)

當設建立好`索引`後，便可以使用 mini dashboard 中的搜索欄 (search bar)，
輸入關鍵字，例如 **"joker"**，開始在測試資料上搜尋。

![alt text](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day04-ms5.png)

今天礙於時間與篇幅，搜尋引擎中不同的元件的說明並留到明日，
與 google 案例討論討論中一併說明。

> Errr 說是礙於篇幅，其實是因為快要 23:00 了
> 今天下班有點事，只趕出來上面的部分。
> 晚點把上面安裝與索引建制的部分寫成 script 放上來，
> 有時間的話再補充 docker 的部分。


## 附錄


### 透過 bash script 安裝並設定 `Meilisearch`
若想跳過安裝及建立索引的部分，也可以執行以下的指令。

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/scripts/day04-ms-local.sh)"
```

它會將 `Meilisearch` 安裝及建立索引的步驟，透過 bash script 完成，
並在 localhost:7700 背景執行 `Meilisearch` server。


### Docker
作者在 [Docker Hub] 還提供了 Debian based 的 `Meilisearch` Docker Images.
對於 macbook M1 也有支援。
或是想參考 Dockerfile 自行 build images 也可以參考 [Dockerfile]。


[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[meilisearch]: https://docs.meilisearch.com/
[meilisearch quick start]: https://docs.meilisearch.com/learn/getting_started/quick_start.html#setup-and-installation
[Docker Hub]: https://hub.docker.com/repository/docker/tainvecs/meilisearch-debian
[Dockerfile]: https://github.com/tainvecs/garage/tree/main/meilisearch/deployment
