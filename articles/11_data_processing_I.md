# [Day 11] 資料前處理 - 果然我的自然語言處理搞錯了。|【搜尋引擎製作錄】

[Github], [Over Engineering]

**礙於篇幅緣故，過多細節的部分，會挑重點講述，如有疑問歡迎留言討論**

當原始資料透過爬蟲抓下來，並存入資料庫後，
一切就準備妥當，等待自然語言處理。
接下來，我們會使用約5天的篇幅，描述資料處理與NLP的部分。

![](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day11-01-architecture-zh.png)

## 資料前處理
在 [Day 02] 中，我們有稍微提到為何要資料前處理，
其中可能包含 **html 的解析** 與 **自然語言處理** 等，
這其中的處理流程，還是要考慮到後續的需求，

![](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day11-02-search_engine.png)

所以這其實是有些從功能需求端，返推回來的過程。
當搜尋引擎在使用資料並提供搜尋服務時，會被使用到？
所謂的被用到，其中其實包含了
- **搜尋功能上的被使用到**
  我們在搜尋時要考慮哪些資訊，
  像是 **標題** 與 **內文** 中的文字。

- **顯示時會用到的部分**
  例如：我們要顯示 **閱讀時間**、**文章標籤** 等，
  而這些資訊相對而言並不會直接用於搜尋。

考慮到這些後，我們可以看看我們在資料庫中，已經具備哪些部分。
並思考如何取得其他缺失的資料。

```json
{
    "href" : "https:\/\/ithelp.ithome.com.tw\/articles\/10284028",
    "title" : "\n                                                使用程式來管理資料庫(DB Migrate) (Day27)\n                    ",
    "content" : "\n                        <div class=\"markdown__style\">\n                                                            <p>以下內容同步更新於<br>\n<a href=\"https:\/\/kevinyay945.com\/smart-home-tutorial\/027\/\" target=\"_blank\" rel=\"noreferrer noopener\">https:\/\/kevinyay945.com\/smart-home-tutorial\/027\/<\/a><\/p>\n<p>在這個之前的程式，都是先到資料庫那邊下語法建好表，然後再到程式這邊新增需要的屬性，但這個會有個問題是，如果有一天你需要到新的環境將你的程式部署起來，或是你需要兩個月前的資料庫型態，這時候就會發生你不知道之前執行了什麼樣的sql語法，不曉得兩個月前的資料庫長得怎麼樣(在你資料庫沒有定期備份的情況下)<br>\n因此，需要有個機制可以將資料庫的狀態也那納入git的版本控制<\/p>\n<p>在這邊，我使用到的是<br>\n<a href=\"https:\/\/github.com\/golang-migrate\/migrate\" target=\"_blank\" rel=\"noreferrer noopener\">https:\/\/github.com\/golang-migrate\/migrate<\/a><br>\n來幫我們進行資料庫的版本控制<br>\n沒有選擇使用gorm的migrate而是直接使用語法的原因主要是因為資料庫如果需要用一些gorm沒有寫到的extension，還是得把這些extension放到程式中，所以才會直接選擇使用語法來進行資料庫的表的版本控制<\/p>\n<p>而這個migrate的工具的使用方式還蠻簡單的<br>\n<a href=\"https:\/\/github.com\/golang-migrate\/migrate\/blob\/master\/MIGRATIONS.md\" target=\"_blank\" rel=\"noreferrer noopener\">https:\/\/github.com\/golang-migrate\/migrate\/blob\/master\/MIGRATIONS.md<\/a><br>\n在你需要的地方放上他指定規則的sql檔案<\/p>\n<pre><code>{version}_{title}.up.{extension}\n{version}_{title}.down.{extension}\n<\/code><\/pre>\n<p>他的version要持續變多，第一個是1，第二個就是2，當然你也可以直接跳10，只要數字變多就可以了<br>\n接著，關於up\/down的部分，因為在這種版本控制呢，會出現說你今天把原本的程式升級到v2.0.0版，卻發生了很大的bug，需要退回到v1.9.7版，那你的資料庫也會需要將資料變成v1.9.7的形狀，所以up跟down基本上是要相輔相成的，如果up有創表(create table...)，那down就要刪表(drop table ...)<\/p>\n<p>他的教學也寫得蠻詳盡的，如果有需要可以點進他的github閱讀他的readme喔<\/p>\n<p>而下面是這次的寫的過成和程式碼<\/p>\n<p><a href=\"https:\/\/www.youtube.com\/watch?v=98v_rdLQdYs\" target=\"_blank\" rel=\"noreferrer noopener\">https:\/\/www.youtube.com\/watch?v=98v_rdLQdYs<\/a><\/p>\n<p><a href=\"https:\/\/github.com\/kevinyay945\/smart-home-backend\/tree\/v0.6.0\" target=\"_blank\" rel=\"noreferrer noopener\">https:\/\/github.com\/kevinyay945\/smart-home-backend\/tree\/v0.6.0<\/a><\/p>\n <br>\n                                                    <\/div>\n                    ",
    "tags" : "13th鐵人賽",
    "genre" : "\n                                                        Software Development\n                        ",
    "publish_at" : "2022-02-17 20:27:00",
    "author_href" : "https:\/\/ithelp.ithome.com.tw\/users\/20113505\/ironman",
    "series_href" : "https:\/\/ithelp.ithome.com.tw\/users\/20113505\/ironman\/4295",
    "series_no" : "27"
}
```

像是文章的內文缺少了 _乾淨的_ **內文** 及 **閱讀時間**，
我們就需要從 `content` 的 `html` 中，
解析出我們所需要的內文，
而閱讀時間則是要透過其他的方式取得。

下方我們就放上最後處理好後的範例資料。
```json
{
    "href":"https://ithelp.ithome.com.tw/articles/10284028",
    "title":"\n                                                使用程式來管理資料庫(DB Migrate) (Day27)\n                    ",
    "content_html":"\n                        <div class=\"markdown__style\">\n                                                            <p>以下內容同步更新於<br>\n<a href=\"https://kevinyay945.com/smart-home-tutorial/027/\" target=\"_blank\" rel=\"noreferrer noopener\">https://kevinyay945.com/smart-home-tutorial/027/</a></p>\n<p>在這個之前的程式，都是先到資料庫那邊下語法建好表，然後再到程式這邊新增需要的屬性，但這個會有個問題是，如果有一天你需要到新的環境將你的程式部署起來，或是你需要兩個月前的資料庫型態，這時候就會發生你不知道之前執行了什麼樣的sql語法，不曉得兩個月前的資料庫長得怎麼樣(在你資料庫沒有定期備份的情況下)<br>\n因此，需要有個機制可以將資料庫的狀態也那納入git的版本控制</p>\n<p>在這邊，我使用到的是<br>\n<a href=\"https://github.com/golang-migrate/migrate\" target=\"_blank\" rel=\"noreferrer noopener\">https://github.com/golang-migrate/migrate</a><br>\n來幫我們進行資料庫的版本控制<br>\n沒有選擇使用gorm的migrate而是直接使用語法的原因主要是因為資料庫如果需要用一些gorm沒有寫到的extension，還是得把這些extension放到程式中，所以才會直接選擇使用語法來進行資料庫的表的版本控制</p>\n<p>而這個migrate的工具的使用方式還蠻簡單的<br>\n<a href=\"https://github.com/golang-migrate/migrate/blob/master/MIGRATIONS.md\" target=\"_blank\" rel=\"noreferrer noopener\">https://github.com/golang-migrate/migrate/blob/master/MIGRATIONS.md</a><br>\n在你需要的地方放上他指定規則的sql檔案</p>\n<pre><code>{version}_{title}.up.{extension}\n{version}_{title}.down.{extension}\n</code></pre>\n<p>他的version要持續變多，第一個是1，第二個就是2，當然你也可以直接跳10，只要數字變多就可以了<br>\n接著，關於up/down的部分，因為在這種版本控制呢，會出現說你今天把原本的程式升級到v2.0.0版，卻發生了很大的bug，需要退回到v1.9.7版，那你的資料庫也會需要將資料變成v1.9.7的形狀，所以up跟down基本上是要相輔相成的，如果up有創表(create table...)，那down就要刪表(drop table ...)</p>\n<p>他的教學也寫得蠻詳盡的，如果有需要可以點進他的github閱讀他的readme喔</p>\n<p>而下面是這次的寫的過成和程式碼</p>\n<p><a href=\"https://www.youtube.com/watch?v=98v_rdLQdYs\" target=\"_blank\" rel=\"noreferrer noopener\">https://www.youtube.com/watch?v=98v_rdLQdYs</a></p>\n<p><a href=\"https://github.com/kevinyay945/smart-home-backend/tree/v0.6.0\" target=\"_blank\" rel=\"noreferrer noopener\">https://github.com/kevinyay945/smart-home-backend/tree/v0.6.0</a></p>\n <br>\n                                                    </div>\n                    ",
    "raw_tags_string":"[\"13th鐵人賽\"]",
    "genre":"\n                                                        Software Development\n                        ",
    "published_at":"2022-02-17 20:27:00",
    "author_href":"https://ithelp.ithome.com.tw/users/20113505/ironman",
    "author_name":"\n                                    kevinyay945\n                                ",
    "series_href":"https://ithelp.ithome.com.tw/users/20113505/ironman/4295",
    "series_name":"網頁新手入門，手把手用React/Golang(Echo)開發基礎網頁(以簡易智慧家庭為例)",
    "series_num":"27",
    "keywords_unigram":[
        "資料庫",
        "sql",
        "版本控制",
        "更新",
        "程式"
    ],
    "keywords_bigram":[
        "資料庫 版本控制",
        "版本控制 資料庫",
        "資料庫 語法",
        "資料庫 型態",
        "資料庫 定期"
    ],
    "programming_languages":[
        "sql"
    ],
    "processed_content_html":"\n<div class=\"markdown__style\">\n<p>以下內容同步更新於<br/>\n</p>\n<p>在這個之前的程式，都是先到資料庫那邊下語法建好表，然後再到程式這邊新增需要的屬性，但這個會有個問題是，如果有一天你需要到新的環境將你的程式部署起來，或是你需要兩個月前的資料庫型態，這時候就會發生你不知道之前執行了什麼樣的sql語法，不曉得兩個月前的資料庫長得怎麼樣(在你資料庫沒有定期備份的情況下)<br/>\n因此，需要有個機制可以將資料庫的狀態也那納入git的版本控制</p>\n<p>在這邊，我使用到的是<br/>\n<br/>\n來幫我們進行資料庫的版本控制<br/>\n沒有選擇使用gorm的migrate而是直接使用語法的原因主要是因為資料庫如果需要用一些gorm沒有寫到的extension，還是得把這些extension放到程式中，所以才會直接選擇使用語法來進行資料庫的表的版本控制</p>\n<p>而這個migrate的工具的使用方式還蠻簡單的<br/>\n<br/>\n在你需要的地方放上他指定規則的sql檔案</p>\n<pre></pre>\n<p>他的version要持續變多，第一個是1，第二個就是2，當然你也可以直接跳10，只要數字變多就可以了<br/>\n接著，關於up/down的部分，因為在這種版本控制呢，會出現說你今天把原本的程式升級到v2.0.0版，卻發生了很大的bug，需要退回到v1.9.7版，那你的資料庫也會需要將資料變成v1.9.7的形狀，所以up跟down基本上是要相輔相成的，如果up有創表(create table...)，那down就要刪表(drop table ...)</p>\n<p>他的教學也寫得蠻詳盡的，如果有需要可以點進他的github閱讀他的readme喔</p>\n<p>而下面是這次的寫的過成和程式碼</p>\n<p></p>\n<p></p>\n<br/>\n</div>\n",
    "content_text":"以下內容同步更新於\n\n在這個之前的程式，都是先到資料庫那邊下語法建好表，然後再到程式這邊新增需要的屬性，但這個會有個問題是，如果有一天你需要到新的環境將你的程式部署起來，或是你需要兩個月前的資料庫型態，這時候就會發生你不知道之前執行了什麼樣的sql語法，不曉得兩個月前的資料庫長得怎麼樣(在你資料庫沒有定期備份的情況下)\n因此，需要有個機制可以將資料庫的狀態也那納入git的版本控制\n在這邊，我使用到的是\n\n來幫我們進行資料庫的版本控制\n沒有選擇使用gorm的migrate而是直接使用語法的原因主要是因為資料庫如果需要用一些gorm沒有寫到的extension，還是得把這些extension放到程式中，所以才會直接選擇使用語法來進行資料庫的表的版本控制\n而這個migrate的工具的使用方式還蠻簡單的\n\n在你需要的地方放上他指定規則的sql檔案\n\n他的version要持續變多，第一個是1，第二個就是2，當然你也可以直接跳10，只要數字變多就可以了\n接著，關於up/down的部分，因為在這種版本控制呢，會出現說你今天把原本的程式升級到v2.0.0版，卻發生了很大的bug，需要退回到v1.9.7版，那你的資料庫也會需要將資料變成v1.9.7的形狀，所以up跟down基本上是要相輔相成的，如果up有創表(create table...)，那down就要刪表(drop table ...)\n他的教學也寫得蠻詳盡的，如果有需要可以點進他的github閱讀他的readme喔\n而下面是這次的寫的過成和程式碼",
    "content_code_info":[
        {
            "language":"unknown",
            "content":"{version}_{title}.up.{extension}\n{version}_{title}.down.{extension}\n"
        }
    ],
    "word_seg_content_text":"以下內容 同步 更新 於\n在 這個 之前 的 程式 ， 都 是 先到 資料庫 那邊 下 語法 建好表 ， 然後 再 到 程式 這邊 新增 需要 的 屬性 ， 但 這個 會 有 個 問題 是 ， 如果 有 一天 你 需要 到 新 的 環境 將你 的 程式 部署 起來 ， 或是 你 需要 兩個 月 前 的 資料庫 型態 ， 這時候 就 會 發生 你 不 知道 之前 執行 了 什麼樣 的 sql 語法 ， 不 曉得 兩個 月 前 的 資料庫 長 得 怎麼樣 ( 在 你 資料庫 沒有 定期 備份 的 情況 下 )\n因此 ， 需要 有個 機制 可以 將 資料庫 的 狀態 也 那 納入 git 的 版本控制\n在 這邊 ， 我 使用 到 的 是\n來 幫 我們 進行 資料庫 的 版本控制\n沒有 選擇 使用 gorm 的 migrate 而是 直接 使用 語法 的 原因 主要 是 因為 資料庫 如果 需要 用 一些 gorm 沒有 寫到 的 extension ， 還是 得 把 這些 extension 放到 程式 中 ， 所以 才 會 直接 選擇 使用 語法 來 進行 資料庫 的 表 的 版本控制\n而 這個 migrate 的 工具 的 使用 方式 還蠻 簡單 的\n在 你 需要 的 地方 放上 他 指定 規則 的 sql 檔案\n他 的 version 要 持續 變多 ， 第一個 是 1 ， 第二個 就是 2 ， 當然 你 也 可以 直接 跳 10 ， 只要 數字 變多 就 可以 了\n接著 ， 關於 up / down 的 部分 ， 因為 在 這種 版本控制 呢 ， 會 出現 說 你 今天 把 原本 的 程式 升級 到 v2.0 . 0 版 ， 卻 發生 了 很大 的 bug ， 需要 退回 到 v1.9 . 7 版 ， 那 你 的 資料庫 也 會 需要 將 資料 變成 v1.9 . 7 的 形狀 ， 所以 up 跟 down 基本上 是 要 相輔相成 的 ， 如果 up 有 創表 ( create\ntable ... ) ， 那 down 就要 刪表 ( drop\ntable\n... )\n他 的 教學 也 寫 得 蠻 詳盡 的 ， 如果 有 需要 可以 點進 他 的 github 閱讀 他 的 readme 喔\n而 下面 是 這次 的 寫 的 過成 和 程式碼",
    "word_seg_processed_content_text":"以下內容 同步 更新 於\n在 這個 之前 程式 先到 資料庫 那邊 下 語法 建好表 然後 再 到 程式 這邊 新增 需要 屬性 但 這個 會 有 個 問題 如果 有 一天 你 需要 到 新 環境 將你 程式 部署 起來 或是 你 需要 兩個 月 前 資料庫 型態 這時候 會 發生 你 不 知道 之前 執行 什麼樣 sql 語法 不 曉得 兩個 月 前 資料庫 長 得 怎麼樣 在 你 資料庫 定期 備份 情況 下\n因此 需要 有個 機制 可以 將 資料庫 狀態 也 那 納入 git 版本控制\n在 這邊 我 使用 到\n來 幫 進行 資料庫 版本控制\n選擇 使用 gorm migrate 而是 直接 使用 語法 原因 主要 因為 資料庫 如果 需要 用 一些 gorm 寫到 extension 還是 得 把 這些 extension 放到 程式 中 所以 才 會 直接 選擇 使用 語法 來 進行 資料庫 表 版本控制\n這個 migrate 工具 使用 方式 還蠻 簡單\n在 你 需要 地方 放上 他 指定 規則 sql 檔案\n他 version 要 持續 變多 第一個 1 第二個 就是 2 當然 你 也 可以 直接 跳 10 只要 數字 變多 可以\n接著 關於 up down 部分 因為 在 這種 版本控制 呢 會 出現 說 你 今天 把 原本 程式 升級 到 v2.0 0 版 卻 發生 很大 bug 需要 退回 到 v1.9 7 版 那 你 資料庫 也 會 需要 將 資料 變成 v1.9 7 形狀 所以 up 跟 down 基本上 要 相輔相成 如果 up 有 創表 create\ntable ... 那 down 就要 刪表 drop\ntable\n...\n他 教學 也 寫 得 蠻 詳盡 如果 有 需要 可以 點進 他 github 閱讀 他 readme 喔\n下面 這次 寫 過成 程式碼",
    "extracted_keywords":[
        "資料庫",
        "程式",
        "sql",
        "版本控制",
        "同步"
    ],
    "extracted_keywords_phrases":[
        "資料庫 版本控制",
        "先到 資料庫",
        "怎麼樣 資料庫",
        "資料庫 怎麼樣",
        "進行 資料庫"
    ]
}
```

處理好資料後，我們就需要根據需求，
有些資料要寫入搜尋引擎建立索引，
有些資料要更新至資料庫中，以利於後續在做統計資料與趨勢分析時，能夠使用。

根據不同的寫入目標，我們也需要將格式資料格式設置好，
以利後續分別寫入搜尋引擎及資料庫。

明天我們會描述資料處理的細節，
並使用 `jupyter notebook` 及 `sqlite` 提供本地端的測試。

[Github]: https://github.com/over-engineering-ru
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[Day 02]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/02_what_is_search_engine_I.md
[Day 03]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/03_what_is_search_engine_II.md
