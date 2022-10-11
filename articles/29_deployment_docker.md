# [Day 29] Dockerfile - Fly.io 什麼的已經夠了啦。|【搜尋引擎製作錄】

[Github], [Over Engineering]

**礙於篇幅緣故，過多細節的部分，會挑重點講述，如有疑問歡迎留言討論**


在結束了 Kirby 分享的前端部分，這個系列也到尾聲。
回頭來看，當初的 architecture，
每個部分我們都在前面的章節涵蓋到了。

![](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day06-01-architecture-zh.png)

最後，我們來看看各個部分的 deployment。
- **網路爬蟲**
  - 我們在 [Day 09] 有提到如何使用 GitHub Action 來進行排程。
- **資料庫**
  - 我們使用 serverless database, Supabase, 詳細可以參考 [Day 10]。
- **NLP 模組**
  - 其實我們應該要將 NLP 處理模組與網路爬蟲串接，也透過 GitHub Action 來進行排程。然而礙於時間，最後我沒有做這個部分，而是寫了一個 script。
  - [nlp_run.sh] 腳本會讀取資料庫中的文章，並用 NLP 模組進行處理。詳細資訊可以參考 [Day 14] 內容。

最後，前端、後端、搜尋引擎的 deployment，我們皆是使用 [fly.io]。
[Fly.io] 是一個 serverless platform，
我們只需要準備好 docker images，就可以直接 deploy，
並不需要自己管理、設定 server。

今天，我們會以後端與搜尋引擎為例，講述 deployment 內容。

## Dockerfile
在開始準備 Dockefile 及 Docker Images 前，
我們要思考如何架構 **後端** 與 **搜尋引擎**？
它們的 Docker Images 要如何組織、溝通？

在考慮到 **搜尋引擎** 其實並不需要直接與 **前端** 或 **使用者** 溝通。
這兩者都是透過後端 API，來進行搜尋或是其他的服務請求。
因此，在一番思慮後，
我們決定將 **後端** 及 **搜尋引擎** 放在同一個 Docker Image 中。

如此做的原因還考慮到
- 我們這是相對較小的 project。
- 如此一來，**搜尋引擎** 對於 **後端** 來說便在 localhost，兩者間的溝通會更加簡單。
- **搜尋引擎** 不需要 expose 給外界，因此，也不需要設定 Master key 或 API key，相對更簡單。

接下來，我們來看看 [Dockerfile] 的內容，
主要分為幾個部分：
- 設定環境變數
- 設定 Backend Flask Server
- 設定 Search Engine Meilisearch
- Entrypoint

### 設定環境變數
會用到的環境變數，與之前 localhost 時大致相同，
唯一一點要注意的是，如 `SUPABASE_URL` 或 `SUPABASE_API_KEY` 等具有機密性的環境變數，
需要透過 setting secrets 的方式設定，而不是放在 Dockerfile 中。
這點後面在 fly.io 的內容會進行說明。

```dockerfile
# env
ENV BACKEND_ROOT="/backend"
ENV FLASK_HOST="0.0.0.0"
ENV FLASK_PORT="5000"
ENV FLASK_URL="http://$FLASK_HOST:$FLASK_PORT"

ENV MEILISEARCH_ROOT="/search_engine"
ENV MEILISEARCH_VERSION="0.28.1"
ENV MEILISEARCH_HOST="0.0.0.0"
ENV MEILISEARCH_PORT="7700"
ENV MEILISEARCH_URL="http://$MEILISEARCH_HOST:$MEILISEARCH_PORT"

ENV MEILI_HTTP_ADDR="$MEILISEARCH_HOST:$MEILISEARCH_PORT"
ENV MEILI_DB_PATH="$MEILISEARCH_ROOT/data"
ENV MEILI_LOG_LEVEL="info"
ENV MEILI_MAX_INDEXING_MEMORY="300Mb"

ENV MEILISEARCH_DOCUMENTS_INDEX="og_docs_search"
ENV MEILISEARCH_KEYWORDS_INDEX="og_keywords_search"

# ENV SUPABASE_URL=""
# ENV SUPABASE_API_KEY=""
```

### 設定 Backend Flask Server
Flask 的設定也並不難，
我們只需要把 `backend` 資料夾中複製一份到 Docker Image 中，
並用 pip 安裝 **requirements.txt** 中所有要用到的 python packages。
最後，別忘了 expose flask API 會用到的 port。
```dockerfile
# init flask api
WORKDIR $BACKEND_ROOT
ADD ./backend $BACKEND_ROOT

# install requirements
RUN python -m pip install --upgrade pip
RUN python -m pip install -r "$BACKEND_ROOT/requirements.txt"

expose 5000
```

### 設定 Search Engine Meilisearch
相同的，複製一份 `search_engine` 資料夾內容到 Docker Image 中。
接著，用 apt 安裝 `curl`, `wget`, and `ca-certificates`。
最後，下載 meilisearch 的執行檔 (binary file)。
```dockerfile
# init meilisearch
WORKDIR $MEILISEARCH_ROOT
ADD ./search_engine $MEILISEARCH_ROOT

# install prerequisite apt apps
RUN apt-get update && \
    apt-get install --no-install-recommends -y curl wget ca-certificates

# download meilisearch binary
RUN wget -O meilisearch "https://github.com/meilisearch/meilisearch/releases/download/v${MEILISEARCH_VERSION}/meilisearch-linux-amd64" && \
    chmod +x meilisearch
```
meilisearch 我們若要測試也可以 expose port，
但若沒有需要，就不必 expose 了。

### Entrypoint
最後，我們的 entrypoint 會用一個腳本 [entrypoint.sh]。
要用 script 的原因在於 Docker Container 啟動時，我們要
- 啟動 Flask Server
- 啟動 Meilisearch Server
- 設定 Meilisearch Indexes and Settings

且要先等 Meilisearch Server 啟動完成後，才能開始設定 Indexes 和 Settings。

### 啟動 Flask and Meilisearch Servers
首先，我們在背景執行並啟動 Flask and Meilisearch Servers。
```bash
# run meilisearch engine
"$MEILISEARCH_ROOT/meilisearch" &
# run API server
python "$BACKEND_ROOT/api.py" &
```

### 設定 Meilisearch Indexes and Settings
由於我們會使用 docker volumes，
所以即使重啟或是重新 deploy 新的 Docker Image，
搜尋引擎中的資料也不會隨著 Container 消失而被刪除。

我們用 `curl` 查看 Meilisearch 中是否已經有我們要設定的 Index。
同時，也是在等待 Meilisearch Server 啟動完成。

我們每隔 1 秒嘗試一次，共嘗試 5 次，
如果 curl request 的 response status_code 為 200，
就代表 Meilisearch Server 啟動完成且 Index 存在。
```bash
status_code=$(
    curl --write-out %{http_code} \
         --silent \
         --output /dev/null \
         "$MEILISEARCH_HOST:$MEILISEARCH_PORT/indexes/$MEILISEARCH_DOCUMENTS_INDEX"
)
attempts=5
until [[ $attempts == 0 ]]; do
    [[ $status_code == 200 ]] && break;
    [[ $attempts -gt 0 ]] && ((--attempts));
    [[ $attempts -gt 0 ]] && sleep 1;
done
```

最後，我們若 status_code 不為 200，我們就嘗試新增並設定 Index。
```bash
if [[ $status_code != 200 ]]; then

    curl -XPOST "$MEILISEARCH_URL/indexes" \
         -H 'Content-Type: application/json' \
         --data-binary '{
             "uid": "'$MEILISEARCH_DOCUMENTS_INDEX'",
             "primaryKey": "uuid"
         }'

    curl -XPATCH "$MEILISEARCH_URL/indexes/$MEILISEARCH_DOCUMENTS_INDEX/settings" \
         -H 'Content-Type: application/json' \
         -d "@$MEILISEARCH_ROOT/resources/docs.settings.json"

fi
```

今天的內容好像有點長，
剩下 Fly.io 方面設定的部分就留到明天好了。 XD


[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/

[Day 09]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/09_crawler_III.md
[Day 10]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/10_supabase.md
[nlp_run.sh]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/scripts/nlp_run.sh
[Day 14]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/14_data_processing_IV.md#pipeline-runner
[fly.io]: https://fly.io/
[Dockerfile]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/deployment/backend_and_search_engine.Dockerfile
[entrypoint.sh]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/deployment/backend_and_search_engine.entrypoint.sh
