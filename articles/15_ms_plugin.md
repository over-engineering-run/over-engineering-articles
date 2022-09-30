# [Day 15] 如何使用終端機 Plugin 加速測試流程 - 帶這 Plugin 闖蕩 Terminal |【搜尋引擎製作錄】

[Github], [Over Engineering]

**礙於篇幅緣故，過多細節的部分，會挑重點講述，如有疑問歡迎留言討論**

在 [Day 04] 的實作章節中，
我們有用 [meilisearch] 在本地端架設搜尋引擎伺服器，
並使用簡單的測試資料建立索引。

然而，雖然 `meilisearch` 提供了簡單的 **mini dashboard**，
使我們在測試搜尋相當方便，
但對於其他如：建立索引、更改索引設置、等等許多的操作，
我們並沒有一個簡單可用的介面。

因此，在進入搜尋引擎的章節前，
我們使用 `curl` 實作一個簡單 **zsh terminal plugin**，
今天用一篇的章節來介紹如何使用它，以利後續測試與使用 `meilisearch`。


## Meilisearch Zsh Plugin

程式碼的部分，可以參考 [ms plugin] 中 `.ms.plugin.zsh`。
主要是使用 `curl` 將 `meilisearch` 各項功能、操作寫成 zsh functions，
並在 terminal 中用 `.zshrc` 讀取並使用。

詳細的 README 可以參考 [ms plugin] 中 `README.md`，
這裡著重使用的部分講。

在使用 plugin 前，
還請在本地端啟動好 `meilisearch` server，
如何 run `meilisearch` server 的方式，
我們在 [Day 04] 的實作章節中也有提到過。


## 安裝
在終端機中使用 `source` 指令讀取 plugin 原始碼，
便可以馬上使用此 plugin。
```bash
source .ms.plugin.zsh
```

此外，你也可以在終端機中執行以下指令。
```bash
echo "source $(realpath .ms.plugin.zsh)" >> ~/.zshrc
```
它會將讀取 plugin 原始碼的 `source` 指令，
加入到家目錄下的 `.zshrc` 中，
`source` 指令於每次終端機開啟時被自動執行。


## 環境變數
在使用 plugin 前，請檢查環境變數。
- `MS_HOST`
  - `meilisearch` 伺服器所在位置連結
  - 預設："localhost:7700"


## Functions (函式)
- 在完成 **安裝** 及 **環境變數** 的設定後，
  我們就可以開始用用 plugin 中的 functions。
  至於有哪些 functions 可以參考 [ms plugin] 中 `README.md` 內容。

- 執行 functions 並傳入適當 positional arguments (位置參數) 來向 `Meilisearch` 發送 request.
  ```bash
  <function_name> $1 $2...
  ```

- 在使用 plugin functions 時，你可以使用 `-h` 或 `--help` 來獲取 function 簡介或是參數資訊。
  ```bash
  <function_name> --help
  ```

- offset (偏移量)
  - 在取得回傳資料時，從第幾個開始取

- limit (限制)
  - 限制回傳的資料個數


## Example
我們可以簡單使用 plugin 重現 [Day 04] 中所介紹實作內容。

在 [Day 04] 中，我們是執行了以下指令
```bash
curl -X POST 'http://127.0.0.1:7700/indexes/movies/documents' \
     -H 'Content-Type: application/json' \
     --data-binary @movies.json
```

若使用 plugin 則可以執行以下指令達到相同效果
```bash
ms-doc-index movies ./movies.json
```

如此的好處不僅是更加精簡，
function 的名稱也比 `curl` 指令的更加好記易懂，
還可以透過 tab autocomplete 不用記一堆 `curl` 指令的細節。

明天開始，我們會進入搜尋引擎的部分，
其中許多的講解都會用到 plugin 的 functions。

> :)


[Github]: https://github.com/over-engineering-ru
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[Day 04]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/04_what_is_search_engine_III.md
[meilisearch]: https://docs.meilisearch.com/learn/getting_started/quick_start.html
[ms plugin]: https://github.com/over-engineering-run/over-engineering/tree/v0.0.1/plugins
