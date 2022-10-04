# [Day 19] 後端 API 設計 - 為搜尋引擎獻上後端！ |【搜尋引擎製作錄】

[Github], [Over Engineering]

**礙於篇幅緣故，過多細節的部分，會挑重點講述，如有疑問歡迎留言討論**

在結束資料庫、NLP模組、搜尋引擎，等部分的內容後，
我們也要開始介紹後端的部分。

後端在架構圖中扮演著 **"提供 API"** 與 **"溝通各個 Components (部件)"** 的角色。

![](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day19-01-architecture-zh.png)

當所有服務溝通的對象都是後端 server 時，
相對較簡單，不需要每一個 components 都實作相互的溝通，
當然可能要考慮後端負載等的問題，
但對於小 project 而言應該可以忽落。

這次後端的實作，考慮到 NLP 的部分已經用 python 了，
所以後端就也一起用 python 及 [flask] 吧。

這次後端的部分我們會分為三天介紹
- **Day 19**
  - 後端簡介
  - API 設計
- **Day 20**
  - Flask 實作 I
  - Meilisearch
- **Day 21**
  - Flask 實作 II
  - Meilisearch and Supabase

> 我也是第一次用 flask，
> 如果有任何指教也歡迎留言。 :)


## API 設計
API 設計時，我們也有參考 [google custom search] 與 [serpapi]，
看看別人是如何設計如：API 路徑、回傳資料結構等。

下面列出這次設計的 APIs
- **POST** &nbsp; `/docs/v1/index`
- **GET**  &nbsp; &nbsp; `/docs/v1/search`
- **POST** &nbsp; `/docs/v1/index/auto-complete`
- **GET**   &nbsp; &nbsp; `/docs/v1/search/auto-complete`
- **GET**   &nbsp; &nbsp; `/db/v1/articles`
- **PATCH** `/db/v1/articles`
- **GET**   &nbsp; &nbsp; `/statistics/v1/count_articles`
- **GET**   &nbsp; &nbsp; `/statistics/v1/prog_lang_count`
- **GET**   &nbsp; &nbsp; `/statistics/v1/count_by_genre`

基本上格式是 `/功能類別/版本數/功能名稱...`，
中間加入 **版本數** 也是未來要更新版本時，更方便區隔與迭代。

API 如 document search 的部分，
**GET** `/docs/v1/search`，可以用 curl 測試，

```bash
curl -XGET "https://over-engineering-backend.fly.dev/docs/v1/search?q=api&page=0&limit=10"
```

得到回傳的結果為
```json
{
    "query":"api",
    "total":850,
    "result":[
        {
            "position":0,
            "title":"\n                                                API 身分驗證\n                    ",
            "link":"https://ithelp.ithome.com.tw/articles/10223365",
            "snippet":"只有該 token 能呼叫 <mark>API</mark>\n\n其中鎖 IP 是最為麻煩的方法，因為 IP 為網路層（Network Layer）即可得知該內容，但若不同的路徑要有不同的限制時，那就只能在應用層（Application Layer）處理，這可能會令開發者不清楚在哪處理比較恰當。另一個問題則是，只要一鎖 IP，代表未來系統架構的彈性就可能會降低。\n而 token 則是相較彈性，且有相關的規範和安全注意事項可以參考。\n另外一開始有提到，使用者直接呼叫 <mark>API</mark> 也是類似這個場景",
            "lastmod":1569915457,
            "about_this_result":{
                "author":{
                    "name":"Miles",
                    "link":"https://ithelp.ithome.com.tw/users/20102562/ironman"
                },
                "series":{
                    "name":"我是誰？我在哪？",
                    "link":"https://ithelp.ithome.com.tw/users/20102562/ironman/2923"
                },
                "hashtags":[
                    "11th鐵人賽"
                ],
                "keywords":[
                    "使用者",
                    "密碼",
                    "驗證",
                    "身分",
                    "利用"
                ],
                "reading_time":5
            }
        },
        {
            "position":1,
            "title":"\n                                                API 實作(四)：實際串上 MongoDB 資料庫\n                    ",
            "link":"https://ithelp.ithome.com.tw/articles/10223396",
            "snippet":"之前有提過，MongoDB 的 Schema-less 特性、加上 BSON 結構很適合拿來用 Node.js 寫個 Side-project，所以今天要拿之前的 <mark>API</mark> 範例，實際串上 MongoDB 資料庫。\n事前準備\n建議你要準備一個主機環境：\n\n\n\n\n\n\n雖然  也可以，但可能會遇上一些問題\n\n你還需要：\n\n\n\n\n\n\n\n\n\n\n\n撰寫 <mark>API</mark>\n首先先來回顧一下  的範例。我們使用 Koa 搭配 koa-router 寫了幾個路由，然後分別用 POST、GET、PATCH、DELETE 對應到文章的 CRUD。\n\n如果你沒有跟到前面的文章又很懶得看的話，你可以",
            "lastmod":1569920609,
            "about_this_result":{
                "author":{
                    "name":"NoobTW",
                    "link":"https://ithelp.ithome.com.tw/users/20119970/ironman"
                },
                "series":{
                    "name":"前端工程師也該會的後端技倆",
                    "link":"https://ithelp.ithome.com.tw/users/20119970/ironman/2774"
                },
                "hashtags":[
                    "11th鐵人賽",
                    "mongodb",
                    "javascript",
                    "node.js"
                ],
                "keywords":[
                    "mongodb",
                    "schema",
                    "資料庫",
                    "router",
                    "連結"
                ],
                "reading_time":10
            }
        }
    ]
}
```
設計上最主要考慮的還是
- **Frontend 有哪些需要的資訊？**
  首先，還是從前端所需要哪些資料先考慮，
  資料齊全後再考慮如何規劃結構。

- **回傳資料的格式**
  因為平常我使用的是 [elasticsearch]，所以也有參考他搜尋回傳的格式。
  - 最外層如：**"query"** and **"total"** 是總體搜尋結果的資訊
  - 各個單一搜尋結果文章會放在 **"result"** 中
  - **result** 中的各個內容， 在呈現時也分為內外兩層，
    如果是一些必要、基本的資訊，如：**"href"** 會被放在外層，
    其他一些比較像是 metadata 的部分，
    則是包在 **"about_this_result"** 中，
    這樣未來的擴充性也較強。

API 設計的簡介大致上先說到這，
明天會就進入 Flask 實作，及一些與 Meilisearch 串接的重點部分，

[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[flask]: https://flask.palletsprojects.com/en/2.2.x/quickstart/
[google custom search]: https://developers.google.com/custom-search/v1/reference/rest/v1/cse/list
[serpapi]: https://serpapi.com/
[elasticsearch]: https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html
