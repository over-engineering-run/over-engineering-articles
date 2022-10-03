# [Day 17] Search - 搜尋引擎，到了鐵人賽就拿出 Meilisearch |【搜尋引擎製作錄】

[Github], [Over Engineering]

**礙於篇幅緣故，過多細節的部分，會挑重點講述，如有疑問歡迎留言討論**

今天要說明 search 部分的實作。
Search 功能便是藉由比對 **使用者的關鍵字** 與 **索引中的文章**，找到相關結果。
實作主要包含3個步驟
- 建立新的索引
- 根據功能，更改索引設定
- 將文章寫入索引

在開始前，別忘了 [Day 15] 中提到的，事先完成
- 在本地端啟動 `Meilisearch Server`
- 設定好環境變數
- 讀取 zsh plugin `.ms.plugin.zsh`

我們的輸入資料便是 Day 11 ~ Day 14 的輸出。
今天的測試資料會用這裡的 [test docs]。

## 建立索引
我們可以用以下指令創建一個新的 index
```bash
ms-index-create $MEILISEARCH_DOCUMENTS_INDEX 'uuid'
```
第一個參數，是從環境變數中讀取到的 index 名稱，
也可以直接用字串取代。

第二個參數表示，我們用 **"uuid"** 作為 primary key。
預設是用 **"id"**，而我們的測試資料是用 **"uuid"**。

## 根據功能，更改索引設定
我們可以看看預設的 index setting 是什麼
```bash
ms-settings-ls $MEILISEARCH_DOCUMENTS_INDEX
```
我們可以從 [meilisearch setting] 看到詳細的說明，
以下是預設的 setting。
```json
{
  "displayedAttributes": [
    "*"
  ],
  "searchableAttributes": [
    "*"
  ],
  "filterableAttributes": [],
  "sortableAttributes": [],
  "rankingRules": [
    "words",
    "typo",
    "proximity",
    "attribute",
    "sort",
    "exactness"
  ],
  "stopWords": [],
  "synonyms": {},
  "distinctAttribute": null,
  "typoTolerance": {
    "enabled": true,
    "minWordSizeForTypos": {
      "oneTypo": 5,
      "twoTypos": 9
    },
    "disableOnWords": [],
    "disableOnAttributes": []
  },
  "faceting": {
    "maxValuesPerFacet": 100
  },
  "pagination": {
    "maxTotalHits": 1000
  }
}
```
而我們會就以下幾個，這次調整的部分說明
- `searchableAttributes`
  這個代表搜尋引擎在進行搜尋時，會對哪些 field 進行關鍵字比對，
  並評估相關度。
  我們在 [Day 16 index] 的部分有提到，寫入 index 中的資料有
  - 哪些資料在搜尋時會被用到？
  - 哪些資料在搜尋到結果後，回傳時需要呈現給使用者？

  的不同考量與用途。
  這裏，我們僅希望第一個考量的相關資料被用以搜尋。
  因此，我們設定從預設的 **"\*"** (意味著所有 field 都會被用)，
  改為如下。
  ```json
  "searchableAttributes":[
    "title",
    "raw_hl_content",
    "word_seg_processed_content",
    "hashtags",
    "keywords",
    "genre",
    "published_at_unix",
    "author_name",
    "series_name",
    "series_num"
  ]
  ```

- `synonyms`
  有些字詞為同義詞，如：`javascript` 與 `js`。
  當使用者搜尋任一者，若文章中含有另一者，也應該被視為相關。
  這裏，我們僅用了一個簡單的同義詞典。

- `stopWords`
  其實，既然搜尋是要比對 **關鍵字** 與 **文章**，
  那們他們就應該被進行相似的資料處理與轉換，
  例如：stop word removal。
  這裏，我們用的是與 NLP 章節時，對文章處理時相同的 stop words。

- `rankingRules`
  相對其他搜尋引擎如 `elasticsearch`，
  `meilisearch` 搜尋與判斷文章相關度的規則相對簡單。
  不像 `elasticsearch` 要寫複雜的 search query，
  `meilisearch` 只要定義如以下簡單的排序規則
  ```json
  "rankingRules":[
    "words",
    "typo",
    "proximity",
    "attribute",
    "sort",
    "exactness"
  ]
  ```
  詳細可以參考 [meilisearch ranking rules]，
  但基本上便是根據一條條的規則，
  如：**"words"**, **"typo"** 等，看哪些文章符合規則。

  **"words"** 便是看個篇文章中，哪些包含較多的關鍵字的字詞數。
  如：使用者輸入關鍵字 "javascript 教學"，
  關鍵字中包含 "javascript" 與 "教學" 兩個詞。
  若有文章 A 同時含有 "javascript" 與 "教學" 兩個詞，
  而文章 B 只有 "javascript"，則文章 A 會被排在 B 前面。

  有一點注意的是，他只看文章有沒有出現 "javascript" 或 "教學"，
  而不考慮出現的次數。

  若有在第一條規則 "words" 實施下，有平手出現，
  則會依次往下面規則判斷，藉此判定誰排在前。

在了解到這些不同設定的意義後，
我們最後調整好的設定在 [doc search settings] 中供參考。
我們可以更新 index setting。
```bash
ms-settings-update $MEILISEARCH_DOCUMENTS_INDEX ./search_engine/resources/docs.settings.json
```

## 將文章寫入索引

最後，我們將測試資料 [test docs] 寫入索引。
```bash
ms-doc-index $MEILISEARCH_DOCUMENTS_INDEX ./backend/testing/testing-meilisearch_docs_indexing_100.json
```
雖然 100 筆資料應該瞬間就完成了，
但我們也可以透過 task 相關 function，
查看 `meilisearch` 背景工作的執行情況。
```bash
ms-task-ls 1
```

## Search
最後，在完成這些後，
我們可以透過 mini dashboard 或以下指令測試搜尋
```bash
curl -XPOST "http://localhost:7700/indexes/$MEILISEARCH_DOCUMENTS_INDEX/search" \
     -H 'Content-Type: application/json' \
     --data-binary '{ "q": "stm" }'
```

抱歉這篇晚了一天，
明天會就 `highlight` 與 `auto complete` 的實作部分繼續。


[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[Day 15]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/15_ms_plugin.md#meilisearch-zsh-plugin
[test docs]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/backend/testing/testing-meilisearch_docs_indexing_100.json
[meilisearch setting]: https://docs.meilisearch.com/reference/api/settings.html#settings-object
[Day 16 index]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/16_search_engine_index_schema_setting.md#index
[meilisearch ranking rules]: https://docs.meilisearch.com/reference/api/settings.html#ranking-rules-array
[doc search settings]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/search_engine/resources/docs.settings.json
