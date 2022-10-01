# [Day 16] Indexes, Schema, and Settings - 搜尋引擎，到了鐵人賽就拿出 Meilisearch |【搜尋引擎製作錄】

[Github], [Over Engineering]

**礙於篇幅緣故，過多細節的部分，會挑重點講述，如有疑問歡迎留言討論**

在上一篇 [Day 15] 我們提到如何使用我們的 zsh terminal plugin，
今天我們會進入搜尋引擎的部分，
我們使用 [meilisearch] 架設這次搜尋引擎伺服器。

為了能滿足搜尋的服務，我們必須要建立`索引`，
除此之外，根據功能需求，我們還要調整設定。

接下來，我們會花 3 天的時間來介紹
- `索引`
  - 建立`索引`時，要存入哪些資料？
  - 我們有需要建立多個`索引`？
- `搜尋`
  - `meilisearch` 搜尋與排序的背後邏輯
  - 有哪些設定需要調整？
- `其他功能實作`
  - `Auto Complete` 與 `Highlight`

![](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day16-01-architecture-zh.png)


## Features
在開始設計實作前，
我們必須了解實作的功能需求、想要解決的問題。
清點一下這次實作的基本功能包含
- `Auto Complete` (也稱 `Auto Fill`)
- `Search`
- `Highlight`

`Search` 是必要的功能，想來也無須贅述。
除此之外，`Auto Compelte` 與 `Highlight` 我們在 [Day 05] 也以 google 為例，

講述了 `Auto Complete` 是為了幫助使用者更好的組織語言，
將關鍵字表達得更加具體、詳細，以利搜尋引擎提供更加精確的結果。

而 `Highlight` 則是為了管理使用者的專注，並強調結果內容中的某部分。

![](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day16-02-search.png)

![](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day16-03-search2.png)

在了釐清我們要實作的功能後，
我們接下來會介紹 `Index` (索引), `Schema`, and `Settings` (設定)。


## Index

在 [Day 03] 中我們介紹，為何必須要建立索引。
除此之外，在接下來建立`索引`前，我們有些觀念必須釐清。

我們並 **不是** 把所有的資料都從`資料庫`複製到`搜尋引擎`，
同時，我們也 **不是** 把`搜尋引擎`當成`資料庫`。

通常我們會將原始的資料存在`資料庫`中，

而`搜尋引擎`則會根據功能需求，思考
- **哪些資料在搜尋時會被用到？**
  - 如：文章內文會在搜尋時，被用於比對使用者所輸入的關鍵字
- **哪些資料在搜尋到結果後，回傳時需要呈現給使用者？**
  - 如：標題、內文預覽 (snippet)

因此，我們 `Day 11` ~ `Day 14` 中所介紹的資料處理內容，
其實就是從`資料庫`將原始資料讀取出來，
根據需求加工成`搜尋引擎`所需要的格式與內容。

將初始資料與加工後的資料分開存放的另一個好處還有，
今天如果功能上需要更新，
或是我們有新的資料處理步驟、方法時，
我們還保留原始資料，
並不需要從爬所有資料再做資料處理。


## Schema
`Schema` 在其他的 `搜尋引擎` 如：`elasticsearch` 中，
在建立`索引`前，便需要準備好，

`Schema` 等同告訴`搜尋引擎`我們會有哪些的資料存入`索引`，
也就是索引中的 `field` (值)，且這些 `field` 的資料格式為何？

然而，`meiliesearch`相對簡化的一點便是`schemaless`。
雖然我們因此不需要準備`schema`，
但我們還是要知道我們要用到哪些資料，
因此，我在 github repo 中還是留下了 [doc search schema reference] 以供參考。


## Settings
它像是一個設定檔，用來設定`索引`，
並會影響後續在此`索引`上搜尋時的一些設定。

如：可以設定哪些 `fields` 可以在搜尋時被使用，
哪些字詞在搜尋時應被視為同義詞等等。

我們在明天的章節會根據實作需求進一步介紹。
設定檔在 [doc search settings] 也可瀏覽。

明天我們會就第二部分，search的實作繼續介紹。


[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[meilisearch]: https://docs.meilisearch.com/learn/getting_started/quick_start.html
[Day 15]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/15_ms_plugin.md
[Day 05]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/05_what_is_search_engine_IV.md
[Day 03]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/03_what_is_search_engine_II.md
[doc search schema reference]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/search_engine/resources/docs.reference_schema.json
[doc search settings]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/search_engine/resources/docs.settings.json
