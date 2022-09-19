# [Day 03] 什麼是搜尋引擎 II - 在 IT 邦尋求答案是否少了些什麼 |【搜尋引擎製作錄】

[Github], [Over Engineering]

昨天，我們介紹將透過`網路爬蟲`取得網頁的`html`，
再經過資料前處理，得到了許多如同下面範例中的`json`，

這樣的一份份資料代表著一個個可以被搜尋文本。
我們將這樣的`json`寫入搜尋引擎後，
搜尋引擎便可以通過例如在`title`或`content`中，
尋找與關鍵字相關的內容，來回應使用者的搜尋請求。

然而，將這樣的`json`寫入搜尋引擎的過程中，
其實包含了一項建立`索引` (Indexing) 的步驟。

```json
{
    "uuid": "e9622965-9b77-4bae-996f-7cc0f338fb1d",
    "href": "https://ithelp.ithome.com.tw/articles/10284028",
    "title": "使用程式來管理資料庫(DB Migrate) (Day27)",
    "raw_hl_content": "以下內容同步更新於...而下面是這次的寫的過成和程式碼",
    "word_seg_processed_content": "以下內容 同步 更新 ... 這次 寫 過成 程式碼",
    "keywords": [
        "資料庫",
        "sql",
        "版本控制",
        "更新",
        "程式"
    ],
    "hashtags": [
        "13th鐵人賽"
    ],
    "genre": "Software Development",
    "published_at": "2022-02-17 20:27:00",
    "published_at_unix": 1645100820,
    "author_href": "https://ithelp.ithome.com.tw/users/20113505/ironman",
    "author_name": "kevinyay945",
    "series_href": "https://ithelp.ithome.com.tw/users/20113505/ironman/4295",
    "series_name": "網頁新手入門，手把手用React/Golang(Echo)開發基礎網頁(以簡易智慧家庭為例)",
    "series_num": "27",
    "reading_time": 3
}
```


## 建立索引 (Indexing)

首先，我們必須先暸解為何需要建立`索引`。
`索引`其實是要幫助我們更快速地找到相關的內容，

想像一下今天使用者輸入的關鍵字是 "javascript"，
我們明明知道不是所有的文本都是在討論 "javascript"，
難道我們每次都要慢慢從所有文本、所有內容中尋找 "javascript" 這個關鍵字嗎？
還是說我們可以透過建立如同書本的目錄一樣機制，幫助我快速查找想要的內容？

這裡我要簡單介紹一項簡單的技術 [反向索引] (Inverted index)
舉一個維基百科上的例子，如果我們有3篇簡單的文本 Doc1, Doc2 and Doc3
```
Doc1: "it is what it is"
Doc2: "what is it"
Doc3: "it is a banana"
```
我們可以建立如同下面的`索引`
```
"a":      {2}
"banana": {2}
"is":     {0, 1, 2}
"it":     {0, 1, 2}
"what":   {0, 1}
```
如此一來，不論使用者的關鍵字是"what" 還是"banana"，
我們都可以快速略過那些必然無相關的文本，
甚至，我們不僅可以記錄哪些文本有提到"banana"，
還可以事先紀錄他們個字出現的位置，
如此一來可以使搜尋更加迅速。
尤其當檔案數量到達一定數量後，
建立`索引`所帶來影響會更為明顯。

這樣的方法也是以空間換時間的例子。
我們這次從鐵人賽上抓了86000多篇的文本，
這個數量並不算大，甚至已收尋引擎的角度而言算是相當的小，
經資料處理後，`json` 檔大小大概是 170MB，
而 index 到搜尋引擎後大概是 17GB。

> Kirby曾經嘗試用不做資料處理或是`indexing`，
> [直接資料庫中做搜尋]，先不說這樣的在功能上的局限性，
> 光時間就有好幾秒的等待時間，令人有些難以忍受 😅。
> 雖然不是嚴謹的 benchmark，但也從從側面提供了一些`索引`效用的參考。


## 關鍵字搜尋

當搜尋引擎內有資料後，等待的便是使用者所輸入的關鍵字，
根據不同的關鍵字，搜尋引擎必須能

- 找到相關的文本
- 對結果進行排序

對於較為嚴謹與深入的理論，還請參考 [Information Retrieval] 這項專門的學科。
一些名詞像是：精確率 ([precision]) 與 召回率 ([recall])，
或是 evaluation 相關的 [F1 score] 等等，
在這系列文章中會較少出現，也不太會影響文章的理解或閱讀。
這系列的文章還是會以基本概念的介紹、實作與個人經驗分享為主。

> Ooops, 我好像愛上貼 wiki 連結了，
> 這絕對不是因為我有點懶著解釋名詞 ;)
> 不過會影響閱讀的部分如 `索引` 我還是會解釋的 :muscle:

### 找到相關的文本
首先，我們要如何定義相關呢？

例如：使用者的關鍵字是`javascript`，
只要文本中提到`javascript`就是相關文本？

還是說即使文本中沒有直接提到`javascript`這個字，
但卻有提到相關的技術內容，如：直接放上`javascript code`也能算相關？
亦或是文本提到`typescript`, `js`等，應該也能算是相關？

其實這幾種文本，都能算是相關，只是相關的程度可能有所不同。
至於要如何比較文本間的相關程度，並以此對於結果進行排序
這也就是第二部分的議題，排序 (`ranking`) 。

### 對結果進行排序 (Ranking)

一般而言，我們必須針對文本特性、使用者在使用搜尋引擎的需求與情境，
制定相應的搜尋演算法與相關性的評估邏輯。

例如：對於許多的文本，像是新聞，
它們的標題，或是文章的第一段，通常便是文章的重點總結，
或許在關鍵字搜尋時，
在文本與關鍵字相關度的評估中，便需要給予標題更高的權重。

以此為例，一個簡單的排序方式可以是，
將標題、內文同時出現關鍵字的文本排在最前，
只有標題出現關鍵字的文本次之，
最後是只有內文出現關鍵字的文本。
而完全沒有提及關鍵字的文本則列為不相關的文本。

反觀有些文本的標題可能便需要謹慎使用，
例如鐵人賽的文章標題就有許多玩各種梗的標題 XD

此外，在了解不同使用者搜尋情境後，
我們也可以針對各種不同的需求，作出相應的客製化邏輯，
以更有效率的方式利用所能取得的資訊，
進而提升搜尋的精確率或是召回率(使我們能找到的相關結果更加豐富)。

如上述提到的例子，針對關鍵字中包含程式語言`javascript`的搜尋，
我們便可以利用文本中出現的 code block，讓搜尋的範圍擴大，
只要文本中有`javascript code`也能算相關，
而不一定要直接提及`javascript`這個關鍵字。

針對這類了解使用者情境及客製化邏輯的部分，
在 "day05 什麼是搜尋引擎 IV" 中會以 google 舉例，
進行更多的案例討論。

明天 "day04 什麼是搜尋引擎 III" 會進入到簡單的實作環節。
在本地端架設一個簡單的搜尋引擎，畢竟本系列應該偏向實作。
也透過實作的過程中了說明各個搜尋引擎的元件如：highlight, filter 背後的意義。

[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[反向索引]: https://zh.wikipedia.org/zh-tw/%E5%80%92%E6%8E%92%E7%B4%A2%E5%BC%95
[直接資料庫中做搜尋]: https://supabase.com/docs/reference/javascript/textsearch
[Information Retrieval]: https://en.wikipedia.org/wiki/Information_retrieval
[precision]: https://en.wikipedia.org/wiki/Precision_and_recall
[recall]: https://en.wikipedia.org/wiki/Precision_and_recall
[F1 score]: https://en.wikipedia.org/wiki/F-score
