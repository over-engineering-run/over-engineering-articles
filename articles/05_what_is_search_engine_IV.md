# [Day 05] 什麼是搜尋引擎 IV - 在 IT 邦尋求答案是否少了些什麼 |【搜尋引擎製作錄】

[Github], [Over Engineering]

![alt text](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day04-ms5.png)

在昨天的實作過程中，我們在本地端架設了一個簡單的搜尋引擎，
並透過 `Meilisearch` mini dashboard 開始搜尋。

今天，我們將藉由 google search 上的一些案例討論及個人經驗分享，
介紹收尋引擎實作時所遇到的挑戰，以及搜尋引擎中不同的元件，
默默的在幫助使用者解決什麼問題？

下面我先列出一些常見的元件，並在接下來一一說明
- auto complete
- snippets
- highlighting
- filtering
- sorting


## 挑戰: 關鍵字只反映少量使用者內心所想
首先，在實作搜尋引擎的中，最直接面對的一項問題便是：
使用者所輸入的關鍵字長度多數較短，
以英文為例僅有 1~3 個字。
**這也導致了一種使用者與搜尋引擎之間，對於搜尋目標的認知上的訊息不對稱。**

舉例而言，使用者輸入的關鍵字是`javascript`，
然而，對於搜尋引擎而言，有些人想看的是`javascript`的介紹，
有些人有找的是`javascript` 的教學，有些人則是要下載並安裝`javascript`。

![alt text](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day05-01-auto_fill_js.png)

使用者的內心所想，透過關鍵字所表達的可能只是表達了相當少的一部分資訊，
而搜尋引擎便是在這種前提下，嘗試去了解使用者的需求，
並在各種龐雜的資料中找到相關資訊，幫助使用者取得有用之參考解答。

> 使用者：搜尋`javascript`, 你應該知道我想要什麼吧～
> 搜尋引擎：崩潰，鬼知道你到底要什麼，能不能說的具體一點？ (╬⁽⁽ ⁰ ⁾⁾ Д ⁽⁽ ⁰⁾⁾)


## Auto Complete (自動完成)
從 google 的於上述`javascript`例子的關鍵字提示中，
我們也可以發現 `Auto Complete` (或者也稱 `Auto Fill`) 設計的其中一項目的，
**便是幫助使用者更好的組織語言，將關鍵字表達得更加具體、詳細，**
以利搜尋引擎提供更加精確的結果。

透過各種不同的資訊，例如：搜尋歷史、常見搜尋、甚至相關的常問問題等，
都能在使用者下關鍵字時，從不同層面提示使用者。

當然，`Auto Complete`也可以其他的益處，如：節省使用者許多打字的功夫，
但背後對搜尋引擎影響較大的，可能還是如前述，幫助使用者下更好的關鍵字。


## 挑戰: 如何幫助使用者在大量相關結果中快速過濾？
當使用者按下 enter 鍵後，搜尋引擎回傳了大量的結果，
雖然已經經過排序，但若呈現的結果需要一個個點進連結中查看，
無疑相當沒有效率，使用者體驗也較差。

如何能幫助使用者使用者在大量相關結果中，
快速過濾多數不相關的部分，並點入少量高機率相關的結果？
這無疑能大幅增加搜尋效率與使用者的體驗。

![alt text](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day05-02-search_result_js.png)


## Snippet (片段) 與 Highlight (強調)
`snippet` 提供使用者在點進連結前的預覽功能，
也藉此讓使用者自行跳過不相關的搜尋結果。

`snippet` 在設計上也有一些要注意的內容，
若`snippet`永遠只是提供如：連結網頁的第一段內容，
可能較難提供參考性，畢竟與關鍵字較為相關的部分內容，
不一定會出現在第一段。
> 這絕對不是特定指 IT 幫 🙃

此外，在 `snippet` 長度上也需要適度，
若`snippet`過長，而每個回傳的內容又都附上`snippet`，
就有可能一下子使太多的文字內容湧向使用者，
進而讓使用者瞬間接收到過多資訊，而失去對重點的專注。

管理使用者的專注力也是設計搜尋引擎介面中十分重要的考量，
不僅是`snippet`的長度，
像是如：`snippet`的文字大小，
或是到底還要不要放上 hashtags (標籤) 等的選擇上，
都與 **管理使用者的專注力** 相關。

也因此，我們要提到另一個相當常見的功能元件，`Highlight`。
`Highlight`是一項相當直接的做法，
透過將`snippet`與使用者關鍵字相同的部分直接反白，或是變換字體顏色等方式，
直接去引導使用者的瀏覽視線與專注點。


## filtering (過濾) 與 sorting (排序)

即使搜尋引擎已經盡量回傳相關結果，
有時還是會因為各種原因使結果與使用者所想不同，
這時，最直接而簡單暴力的方式可能，
便是直接用`filtering`(過濾) 與`sorting`(排序) 干預搜尋結果。

例如：搜尋結果回傳了許多西班牙文的相關節果，即使相關我也看不懂，
最直接修正這樣結果的方式，
便是將所有特定語言的結果透過`filtering`(過濾)濾除，
只保留想要的目標結果。

相對而言，`sorting`則是去干預排序，
例如：改以文章時間做排序，而非與關鍵字的相關度。

然而在設計時，也需要考慮到實用情境，
應該通用於各種搜尋情境，避免做到過於複雜。

例如：新聞搜尋時提供按時間排序便相當對有道理，
而購物網站的搜尋，則是要考慮有按價格排序搜尋結果的功能。
根據搜尋目標的資料特性提供相對合適的功能設計。


## 了解使用者搜尋的情境

最後，從 google search 中我們可以發現，它已經不單單只是搜尋引擎，
其中還結合了，例如：知識庫、問答系統等等，來幫助使用者更加快速地獲得解答。

相對而言，傳統的搜尋引擎只能提供存在可能解答的相關網頁，
解答也還是仰賴使用者從結果網頁中自行挖掘，
反觀 google 卻已經在嘗試於某些搜尋情境下，
使用如問答系統的方式直接告訴使用者解答。

![alt text](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day05-03-google_qa_sys.png)

這便牽涉到一項議題，要如何了解使用者搜尋的情境，並提供更有效的解答？
從`javascript`的例子，一方面，我們期待甚至嘗試引導使用者將關鍵字寫得更加具體；
然而，從另一個角度，我們是否能從有限的資訊中，加入一些合理的推測，讓搜尋變得更加精確呢？

例如：當使用者搜尋蘋果的股票代碼 "APPL"，
我們其實不難了解到使用者在做這項搜尋的情境與背後動機，
直接提供蘋果的歷史股價明顯可以滿足大多數的需求，有使搜尋結果更加精確、有效率。
![alt text](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day05-04-scenario_appl.png)

甚至，也能根據其他外部的資訊，例如：使用者所在位置、歷史搜尋紀錄等資訊等，
來對預設的搜尋情境進行微調，以提供更佳的搜尋結果。
如何透過有限的訊息，定義各種多不勝數的搜尋情境，也是一項挑戰。

![alt text](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day05-05-scenario_weather.png)

![alt text](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day05-06-scenario_curry.png)

> 溫馨提醒：考慮來東南亞工作的讀者，請三思而行，避免上當受騙。:)

明天我們會開始介紹並規劃我們【搜尋引擎製作錄】的實作系統架構。

[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/
