# [Day 02] 什麼是搜尋引擎 I - 在 IT 邦尋求答案是否少了些什麼 |【搜尋引擎製作錄】

[Github], [Over Engineering]

提到搜尋引擎，大家最直接的會想到 google。
若說以一個使用者的角度而言，相信大家都用過 google，也不需要我在此多做說明。
然而，若以一個實作者的角度來思考，或許需要一個更深入的視角。

搜尋引擎的目的無非是幫助人們的獲取想要的解答。
使用者能看到的是搜尋引擎透過所提供的關鍵字，找到並回傳與之相關的結果。
然而，在此之前，卻有著很大一部份是使用者沒能看到的，那便是搜尋資料的準備。

便如同餐廳在營業時，顧客只看見的煮好的餐點，可能也想到廚師烹調菜餚，
卻可能遺忘廚師在設計料理、選購食材與食材事先處理的過程。

本次文章主要是搜尋引擎的簡介，
讓大家對 "什麼是搜尋引擎" 有個更深入的概念。
文章會分為四天，圍繞著兩大方向來描述

- 如何獲取資料，並進行事先的處理？
- 如何在收到使用者的關鍵字後進行搜尋，並回傳相關結果？

介紹之後可能會運用上的 **技術概念** 及面臨到的 **挑戰**。
並會有一個十分簡單的實作環節，讓大家體驗一下在本地端架設一個簡單的搜尋引擎。


## 獲取資料

在實作搜尋引擎之前，我們必須針對搜尋目標搜集相關的文章或資料。

舉例而言，今天我們是做鐵人賽的搜尋引擎，那麼我們便必須下載所有的鐵人賽文章。
人工一篇篇瀏覽下載當然是不太可能，所以我們必須透過寫程式的方式，
也就是 [網路爬蟲] (web crawler)，以自動化的方式來下載。

`網路爬蟲`，簡而言之便是能夠基於事先設計好的規則、或是沿著網站的連結等的方式，
自動發送請求 (request)、讀取目標的內容，並將之存入的資料庫。


## 資料前處理

從網上透過`網路爬蟲`抓下來的資料是無法直接使用的。

- `html` 解析 (html parsing)
首先，這些網頁還是以`html`等極為原始方式被儲存，
在未經處理前，若直接拿來搜尋，不僅雜訊多，搜尋速度也慢。
例如：搜尋時可能會被`html`內的`tag`和`attribute`等資訊的干擾。
我們必須解析`html`並將所需的部分，例如內文，擷取出來。

- `自然語言處理`
其次，我們需要簡單介紹一個名詞:`自然語言處理` (NLP)，
以通俗的方式來說，大致上能理解為，
通過程式的方式來對人類的語言文字進行文字處理、語意理解等等的技術。
詳細較為精確的定義請參考維基百科 [自然語言處理]。
</br>在資料前處理中，也包許多`自然語言處理`的部分，
例如：中文相較英文而言，最明顯的便是英文是以"字"為單位，
而中文中最小有意義的單位是"詞"。
相同的中文字，本身意思必須要跟其他的字組成詞後才能確定。
例如："和"，在 "暖和"、"和氣"、甚至 "大和號" 之中，
所蘊含的意思都不盡相同。
因此，將內文從`html`截取出後，需要進行斷詞，
將內文切為已"詞"為單位，才能用以搜尋。

- 其他
此外，我們也在此階段做鐵人賽文章的程式語言擷取，
以用於後續統計與趨勢分析。

下面我放了其中一篇處理過的文章，透過`href`可以網頁上查看原始的文章。
我們透過爬蟲將原始網頁`html`下載下來後，經過資料前處理最後得到了以下的資料。

明天我們會繼續以這個`json`為例，
講述將資料寫入搜尋引擎並使用關鍵字進行搜尋。

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

> 斷詞對於後續語意的理解相當重要，
> 舉例: "我們中出了一個叛徒！"
> 如果斷詞出錯，便可能造成語意理解出問題。(⁄ ⁄•⁄ω⁄•⁄ ⁄)

[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[網路爬蟲]: https://zh.wikipedia.org/zh-tw/%E7%B6%B2%E8%B7%AF%E7%88%AC%E8%9F%B2
[自然語言處理]: https://zh.wikipedia.org/zh-tw/%E8%87%AA%E7%84%B6%E8%AF%AD%E8%A8%80%E5%A4%84%E7%90%86