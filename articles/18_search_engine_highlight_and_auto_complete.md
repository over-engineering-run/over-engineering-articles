# [Day 18] Auto Complete and Highlight - 搜尋引擎，到了鐵人賽就拿出 Meilisearch |【搜尋引擎製作錄】

[Github], [Over Engineering]

**礙於篇幅緣故，過多細節的部分，會挑重點講述，如有疑問歡迎留言討論**


今天的主題為 features `Highlight` 與 `Auto Complete` 的實作。


## Highlight and Snippet

`Highlight` 與 `Snippet` 密不可分，
且其實皆是上個篇章中 search 的延伸。

在取得搜尋結果後，我們時常需要提供 `snippet` 給使用者，以提供預覽。
而 `Highlight` 則是進一步強調 `snippet` 中與關鍵字相關的部分。

![](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day16-03-search2.png)

Meilisearch 的 search 功能中，
其實已經內建了 `Highlight` 與 `Snippet`，
我們只要在 search 時，調用、調整參數便可。

延續昨天 search 時的 request，
我們可以加入以下參數
- `attributesToCrop`
  - 用此參數宣告要從哪個 field 擷取 `snippet` 及擷取長度
- `attributesToHighlight`
  - 要 `highlight` 哪個 field

更多的參數，可以參考 [meilisearch search parameters]。

我們用此 curl command 測試 search，並取得 `snippet` 和 `highlight`。
```bash
curl -XPOST "http://localhost:7700/indexes/$MEILISEARCH_DOCUMENTS_INDEX/search" \
     -H 'Content-Type: application/json' \
     --data-binary '{ "q": "stm", "attributesToCrop": ["raw_hl_content:100"], "attributesToHighlight": ["raw_hl_content"]}'
```
可得結過如
```json
{
  "_formatted": {
    "raw_hl_content": "…我編寫教學書籍的內容和想法~\n目前寫了1、2章1萬多個字，個人認為對標準庫開發流程該知道的知識都交代的相當詳細了，該提到手冊的重點我都有拿出來說明\n目錄\n第 1 章 做一塊自己的開發板\n1.1\t<em>STM</em>32是什麼？\n1.2\t<em>STM</em>32開發板製作\n第 2 章 暫存器開發\n2.1暫存器映射\n2.2<em>STM</em>32的GPIO介紹\n2.3開發環境創建-Keil5\n2.4操作暫存器控制LED閃爍講解\n2.5總結\n我隨便截幾章目前暫存器章節的內容下來"
    }
}
```


## Auto Complete
`Auto Complete` (或稱 Auto Fill) 其時在實作時，也可以用 search 完成。
只是，相對前面我們都是 search 文章，
這次我們要 search 的是 `keyword`。

![](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day16-03-search2.png)

還記得 [Day 13 Keyword Extraction] 的介紹，
我們從文章中抽取出來的 `keywords`。
這些 `keywords` 不僅是文章文意的精華，
且必然在文章中曾經出現過，
正是用於 Auto Fill 的好材料。

我們用類似於 [Day 17] 中介紹的內容，為所有 keywords
- 建立新的索引
- 根據功能，更改索引設定
- 將文章寫入索引

可以參考 [search engine directory] 中的 setting 與 schema。

搜尋引擎的部分到這裡就介紹到一個段落了，
明天會進入新的章節：後端。


[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[meilisearch search parameters]: https://docs.meilisearch.com/reference/api/search.html#body
[Day 13 Keyword Extraction]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/13_data_processing_III.md#preprocessing-4-keyword-extraction-from-processed-contents
[Day 17]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/17_search_engine_search.md
[search engine directory]: https://github.com/over-engineering-run/over-engineering/tree/main/search_engine/resources
