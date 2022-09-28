# [Day 13] NLP - 果然我的自然語言處理搞錯了。|【搜尋引擎製作錄】

[Github], [Over Engineering]

**礙於篇幅緣故，過多細節的部分，會挑重點講述，如有疑問歡迎留言討論**


昨天我們有提到這次的資料處理，主要包含了以下的階段
- **Preprocessing 1: Load Data from SQL**
- **Preprocessing 2: Extract Content from HTML**
- **Preprocessing 3: Content Text**
- **Preprocessing 4: Keyword Extraction from Processed Contents**

今天我們就繼續從第三個階段開始。

## Preprocessing 3: Content Text
首先，會使用到第二階段的輸出，也就是從 HTML 的內文。

```json
{
    "content_text":"前言\n\n該系列是為了讓看過Vue官方文件或學過Vue但是卻不知道怎麼下手去重構現在有的網站而去規畫的系列文章，在這邊整理了許多我自己使用Vue重構很多網站的經驗分享給讀者們。\n\n什麼？單元測試？當你開始接觸開發專案有一段時間後，你會開始漸漸聽到這個專業術語，就讓我來大家了解一下什麼是單元測試\n\n影片搭配文章看學習效果會更好喔\n什麼是單元測試？\n簡單來說程式碼的最小單位進行測試，確保程式邏輯不會在團隊維護的過程中出錯，維護程式碼的品質。所謂的最小單位，我用個例子來舉例，假如你今天有一個主功能是由 A跟Ｂ兩個功能所組成的，而這兩個功能就是我們所說的最小單位，所以在撰寫測試的時候我們重點在針對A跟Ｂ來進行測試，主功能的測試中不會包含 A跟Ｂ的測試，這樣的測試就是我們所說的單元測試。\n為什麼需要單元測試？\n我先列出幾個優缺點，我們來比較一下\n優點：\n\n確保團隊跌代的時候不會影響原本的功能\n確保品質，準確對程式碼切割最小單位，降低耦合度\n程式的 return 變成可預期\n重構程式碼可以按照測試的規格走\n\n缺點 :\n\n初期可能撰寫單元測試所消耗的時間可能會大於實際開發時間\n如果迭代性高，很常寫好的測試要重寫，久了會浪費很多時間\n測試相關的配置繁瑣，為了配合許多開發上的細節要處理的設定很多\n\n從優缺點可以知道說，撰寫單元測試的初期對於開發的效益並不高，先撇開不熟悉測試來說，光就在公司常常會因為需求改變就要來來回回改寫程式，我就要再花許多時間來重寫測試，怎麼想都對於有時辰壓力的專案來說不是那麼划算，所以往往會在這個時候放棄寫測試，就像我如果在初期會遇到不斷修改的需求的時候，我也不會先寫測試（笑\n那什麼情況下該寫單元測試？其實產品開發的中期的時候，基本上中期的時候大多數的平台規格都確定了差不多，就可以考慮開始補單元測試，因為會開始遇到前面做好的功能因為新的功能造成預期外的錯誤，以及專案由其他同事接手的時候改壞某個功能但是同事不知道，這些我們都可以透過測試來了解，避免把測試沒通過的案子給推上線。\n開始寫 Vue 的單元測試前\n開始寫測試前我們要先了解一下我們是透過何種技術來撰寫測試的\nJest\nJest 是由 Facebook 開發維護的一款 JavaScript 測試框架，可以用簡潔的語法來測試你的 function 。\nVue Test Utils\nVue Test Utils 是 Vue 官方推出的組件單元測試框架，簡化組件的測試。它提供了一些方法來以區分掛載組件之間交互。\n我們會透過以上兩種測試用的框架來針對我們 vue 的 component 進行測試，Vue Test Utils 負責解析我們的 component，讓我們可以不透過 build 就可以模擬 DOM 被渲染出來的結果，再透過 Jest 撰寫 test case 來驗證是否符合預期。\n安裝 jest 與 Vue Test Utils （ Vue-cli ）\n如果你是新建立一個專案，請你選擇 Unit Testing -> Jest，這樣專案預設就會有安裝 jest 跟 Vue Test Utils\n\n如果你在建立專案的時候沒有選擇 Unit Testing 的話你可以輸入以下指令\n\n現有的 CLI 專案，也可以加入 jest 跟 Vue Test Utils\n基本語法介紹 describe & it & test\n先來帶大家來看一下基本的語法\n\n\ndescribe ： 類似群組的概念，用來將一個或是多個相關的測試包再一起。\nit ＆test ： 為測試的項目單位，it 為 test 的別名兩個是一樣的東西。\nexpect ：你要測試的項目內容。\ntoBe ： 斷言，主要是來檢查 expect 回傳的內容是否符合你的預期，有很多種形式的斷言。\n\n以上的這些語法屬於 jest 的語法 API\n接下來看看如何使用 Vue Test Utils 負責解析我們的 Component\n\n\n我們可以直接使用 shallowMount 這個方法來渲染我們的 Component，再透過 .text( ) 這個方法去取得 Component 裡面所有的文字內容來做比對，是不是覺得很簡單呢～\n最後\n好啦！關於單元測試的部分就到這邊先告一段落，如果你還想知道更多有關於單元測試的使用以及使用情境，歡迎購買我的新課程 Vue 單元測試 vue-test-utils｜入門\n課程網址：\n\n原價新台幣 2200 元，目前還是維持預購價新台幣 1800元，現在輸入折扣碼「 PAJNBFUNO300」馬上再折300元優惠。\n\n訂閱Mike的頻道享受精彩的教學與分享\n\n\nMIke 的官方 line 帳號，好友搜尋 @mike_cheng"
}
```
這個階段主要是自然語言處理，包含了最基本及最簡單的朗的兩個部分
- `斷詞` (Word Segmentation)
- `停用詞移除` ([Stop Word] Removal)

### 斷詞
在 [Day 02] 中我們提到，
相對於其它語言如英文，最小有意義的單位是 **"字"**，
中文則是 **"詞"**，所以中文必須要`斷詞`。
我們使用的中文斷詞工具是被廣泛使用也相當具知名度的 python package [Jieba]。
背後使用到的細節與原理這裡就不細講，也不影響使用。
這個 package 使用的方式也可以參考 [Jieba] README 中的範例。

### 停用詞移除
`停用詞`的移除在前處理也是被廣泛的使用。
文章中，無法避免的會廣泛出現如 **"的"**, **"也"**，
或是英文中 **"the"**, **"of"** 等的字詞，

然而，這些字詞在文章中，
時常只是扮演語氣轉換或連接的功能，
並不具備太多意義，
也廣泛地出現在各式文章中，
因此對於文章搜尋並不能提供鑑別度，
甚至可能影響搜尋的準確度。

想像當使用者輸入如："API的實作"，
假設文章 A 中提到 3次 **"API"** 及 2次 **"實作"**，
而文章 B 中沒有提到 API，只提到了 30次 **"的"**，
若我們將`停用詞`與其它字詞的作用視為相等，
文章 B 甚至可能被視為更具相關度，
並被排在文章 A 前。

下方便是這階段的輸出結果，
一個是斷完詞的內文，
另一個則是在斷完詞後還將`停用詞`移除。

```json
{
    "word_seg_content_text":"前言\n該 系列 是 為 了 讓 看過 Vue 官方 文件 或學過 Vue 但是 卻 不 知道 怎麼 下手 去 重構 現在 有 的 網站 而 去 規畫 的 系列 文章 ， 在 這邊 整理 了 許多 我 自己 使用 Vue 重構 很多 網站 的 經驗 分享 給 讀者 們 。\n什麼 ？ 單元測試 ？ 當你 開始 接觸 開發 專案 有 一段時間 後 ， 你 會 開始 漸漸 聽到 這個 專業術語 ， 就讓 我來 大家 了解 一下 什麼 是 單元測試\n影片 搭配 文章 看 學習效果 會 更好 喔\n什麼 是 單元測試 ？\n簡單 來說 程式碼 的 最小 單位 進行 測試 ， 確保 程式 邏輯 不會 在 團隊 維護 的 過程 中 出錯 ， 維護 程式碼 的 品質 。 所謂 的 最小 單位 ， 我用 個例 子來 舉例 ， 假如 你 今天 有 一個 主 功能 是 由\nA 跟 Ｂ 兩個 功能 所 組成 的 ， 而 這 兩個 功能 就是 我們 所說 的 最小 單位 ， 所以 在 撰寫 測試 的 時候 我們 重點 在 針對 A 跟 Ｂ 來 進行 測試 ， 主 功能 的 測試 中 不會 包含\nA 跟 Ｂ 的 測試 ， 這樣 的 測試 就是 我們 所說 的 單元測試 。\n為 什麼 需要 單元測試 ？\n我先 列出 幾個 優缺點 ， 我們 來 比較 一下\n優點 ：\n確保 團隊 跌代 的 時候 不會 影響 原本 的 功能\n確保 品質 ， 準確 對 程式碼 切割 最小 單位 ， 降低 耦合度\n程式 的\nreturn\n變成 可 預期\n重構 程式碼 可以 按照 測試 的 規格 走\n缺點\n:\n初期 可能 撰寫 單元測試 所 消耗 的 時間 可能 會 大於 實際 開發 時間\n如果 迭代 性高 ， 很常 寫 好 的 測試 要 重寫 ， 久 了 會 浪費 很多 時間\n測試 相關 的 配置 繁瑣 ， 為 了 配合 許多 開發 上 的 細節 要 處理 的 設定 很多\n從優 缺點 可以 知道 說 ， 撰寫 單元測試 的 初期 對於 開發 的 效益 並不高 ， 先 撇開 不 熟悉 測試 來說 ， 光 就 在 公司 常常 會 因為 需求 改變 就要 來來回回 改寫 程式 ， 我 就要 再花 許多 時間 來 重寫 測試 ， 怎麼 想 都 對於 有 時辰 壓力 的 專案 來說 不是 那麼 划算 ， 所以 往往 會 在 這個 時候 放棄 寫 測試 ， 就 像 我 如果 在 初期 會 遇到 不斷 修改 的 需求 的 時候 ， 我 也 不會 先寫 測試 （ 笑\n那 什麼 情況 下該 寫 單元測試 ？ 其實 產品開發 的 中期 的 時候 ， 基本上 中期 的 時候 大多數 的 平台 規格 都 確定 了 差不多 ， 就 可以 考慮 開始 補 單元測試 ， 因為 會 開始 遇到 前面 做好 的 功能 因為 新 的 功能 造成 預期 外 的 錯誤 ， 以及 專案 由 其他 同事 接手 的 時候 改壞 某個 功能 但是 同事 不 知道 ， 這些 我們 都 可以 透過 測試 來 了解 ， 避免 把 測試 沒 通過 的 案子 給推 上線 。\n開始 寫\nVue\n的 單元測試 前\n開始 寫 測試 前 我們 要 先 了解 一下 我們 是 透過 何種 技術 來 撰寫 測試 的\nJest\nJest\n是 由\nFacebook\n開發 維護 的 一款\nJavaScript\n測試 框架 ， 可以 用 簡潔 的 語法 來 測試 你 的\nfunction\n。\nVue\nTest\nUtils\nVue\nTest\nUtils\n是\nVue\n官方 推出 的 組件 單元測試 框架 ， 簡化 組件 的 測試 。 它 提供 了 一些 方法 來 以 區分 掛載 組件 之間 交互 。\n我們 會 透過 以上 兩種 測試 用 的 框架 來 針對 我們\nvue\n的\ncomponent\n進行 測試 ， Vue\nTest\nUtils\n負責 解析 我們 的\ncomponent ， 讓 我們 可以 不 透過\nbuild\n就 可以 模擬\nDOM\n被 渲染 出來 的 結果 ， 再 透過\nJest\n撰寫\ntest\ncase\n來 驗證 是否 符合 預期 。\n安裝\njest\n與\nVue\nTest\nUtils\n（\nVue - cli\n）\n如果 你 是 新 建立 一個 專案 ， 請 你 選擇\nUnit\nTesting\n- >\nJest ， 這樣 專案 預設 就 會 有 安裝\njest\n跟\nVue\nTest\nUtils\n如果 你 在 建立 專案 的 時候 沒有 選擇\nUnit\nTesting\n的話 你 可以 輸入 以下 指令\n現有 的\nCLI\n專案 ， 也 可以 加入\njest\n跟\nVue\nTest\nUtils\n基本 語法 介紹\ndescribe\n&\nit\n&\ntest\n先來 帶 大家 來看 一下 基本 的 語法\ndescribe\n：\n類似 群組 的 概念 ， 用來 將 一個 或是 多個 相關 的 測試 包再 一起 。\nit\n＆ test\n：\n為 測試 的 項目 單位 ， it\n為\ntest\n的 別名 兩個 是 一樣 的 東西 。\nexpect\n： 你 要 測試 的 項目 內容 。\ntoBe\n：\n斷言 ， 主要 是 來 檢查\nexpect\n回傳 的 內容 是否 符合 你 的 預期 ， 有 很 多種形式 的 斷言 。\n以上 的 這些 語法 屬於\njest\n的 語法\nAPI\n接下來 看看 如何 使用\nVue\nTest\nUtils\n負責 解析 我們 的\nComponent\n我們 可以 直接 使用\nshallowMount\n這個 方法 來 渲染 我們 的\nComponent ， 再 透過\n. text (\n)\n這個 方法 去 取得\nComponent\n裡面 所有 的 文字 內容 來 做 比對 ， 是不是 覺得 很 簡單 呢 ～\n最後\n好 啦 ！ 關於 單元測試 的 部分 就 到 這邊 先 告一段落 ， 如果 你 還想 知道 更 多 有 關於 單元測試 的 使用 以及 使用 情境 ， 歡迎 購買 我 的 新課程\nVue\n單元測試\nvue - test - utils ｜ 入門\n課程 網址 ：\n原價 新台幣\n2200\n元 ， 目前 還是 維持 預購 價新 台幣\n1800 元 ， 現在 輸入 折扣 碼 「\nPAJNBFUNO300 」 馬上 再折 300 元 優惠 。\n訂閱 Mike 的 頻道 享受 精彩 的 教學 與 分享\nMIke\n的 官方\nline\n帳號 ， 好友 搜尋\n@ mike _ cheng",
    "word_seg_processed_content_text":"前言\n系列 看過 vue 官方 文件 或學過 vue 下手 重構 網站 規畫 系列 文章 整理 vue 重構 很多 網站 經驗 分享 讀者\n單元測試 當你 接觸 開發 專案 一段時間 會 漸漸 聽到 專業術語 就讓 我來 了解 單元測試\n影片 搭配 文章 學習效果 會 更好 喔\n單元測試\n簡單 來說 程式碼 最小 單位 測試 確保 程式 邏輯 團隊 維護 過程 中 出錯 維護 程式碼 品質 最小 單位 我用 個例 子來 舉例 主 功能\na ｂ 兩個 功能 兩個 功能 所說 最小 單位 撰寫 測試 重點 針對 a ｂ 測試 主 功能 測試 中 包含\na ｂ 測試 測試 所說 單元測試\n單元測試\n我先 列出 幾個 優缺點\n優點\n確保 團隊 跌代 影響 原本 功能\n確保 品質 準確 程式碼 切割 最小 單位 降低 耦合度\n程式\nreturn\n預期\n重構 程式碼 測試 規格 走\n缺點\n\n初期 撰寫 單元測試 消耗 時間 會 大於 開發 時間\n迭代 性高 很常 寫 測試 重寫 久 會 浪費 很多 時間\n測試 相關 配置 繁瑣 配合 開發 細節 設定 很多\n從優 缺點 說 撰寫 單元測試 初期 開發 效益 並不高 先 撇開 熟悉 測試 來說 光 公司 會 需求 改變 就要 來來回回 改寫 程式 就要 再花 時間 重寫 測試 想 時辰 壓力 專案 來說 划算 會 放棄 寫 測試 初期 會 修改 需求 先寫 測試 笑\n情況 下該 寫 單元測試 產品開發 中期 基本上 中期 平台 規格 差不多 補 單元測試 會 做好 功能 新 功能 預期 外 錯誤 專案 同事 接手 改壞 功能 同事 透過 測試 了解 測試 沒 案子 給推 上線\n寫\nvue\n單元測試 前\n寫 測試 前 先 了解 透過 何種 技術 撰寫 測試\njest\njest\n\nfacebook\n開發 維護 一款\njavascript\n測試 框架 簡潔 語法 測試\nfunction\n\nvue\ntest\nutils\nvue\ntest\nutils\n\nvue\n官方 推出 組件 單元測試 框架 簡化 組件 測試 提供 方法 區分 掛載 組件 之間 交互\n會 透過 兩種 測試 框架 針對\nvue\n\ncomponent\n測試 vue\ntest\nutils\n負責 解析\ncomponent 透過\nbuild\n模擬\ndom\n渲染 透過\njest\n撰寫\ntest\ncase\n驗證 符合 預期\n安裝\njest\n\nvue\ntest\nutils\n\nvue cli\n\n新 建立 專案 請 選擇\nunit\ntesting\n\njest 專案 預設 會 安裝\njest\n\nvue\ntest\nutils\n建立 專案 選擇\nunit\ntesting\n輸入 指令\n現有\ncli\n專案\njest\n\nvue\ntest\nutils\n語法 介紹\ndescribe\n\n\n\ntest\n先來 帶 來看 語法\ndescribe\n\n類似 群組 概念 用來 多個 相關 測試 包再\n\ntest\n\n測試 項目 單位\n\ntest\n別名 兩個 東西\nexpect\n測試 項目 內容\ntobe\n\n斷言 檢查\nexpect\n回傳 內容 符合 預期 多種形式 斷言\n語法\njest\n語法\napi\n接下來\nvue\ntest\nutils\n負責 解析\ncomponent\n\nshallowmount\n方法 渲染\ncomponent 透過\ntext\n\n方法\ncomponent\n文字 內容 做 比對 簡單\n\n單元測試 先 告一段落 還想 更 單元測試 情境 購買 新課程\nvue\n單元測試\nvue test utils 入門\n課程 網址\n原價 新台幣\n2200\n元 預購 價新 台幣\n1800 元 輸入 折扣 碼\npajnbfuno300 馬上 再折 300 元 優惠\n訂閱 mike 頻道 享受 精彩 教學 分享\nmike\n官方\nline\n帳號 好友 搜尋\nmike cheng"
}
```

## Preprocessing 4: Keyword Extraction from Processed Contents
在進入第四階段前，
必須澄清一下，`Keyword Extraction` (關鍵字抽取) 中的關鍵字，
與 search query (關鍵字搜尋) 中的關鍵字，並不相同。

search query 中的 query (關鍵字) 指的是使用者輸入於 search bar 中的文字，
而 keyword extraction 中的 keyword (關鍵字) 則是用於總結文章、代表文意的字詞。
為避免混淆，這系列文章的關鍵字都是指 search query 中的 query，
keyword 則會直接使用英文。

剛剛有提到`keyword extraction`其實是想找到能代表文意的字詞，
有時在網站上如 twitter 中也以 hashtag 的方式出現。

這裡必須介紹的一個相當簡單的概念 [n-gram]，
在中文中，他其實就是連續的 n 個詞。
以內文舉例，我們能抓取出的 1-gram 就是 **"前言"**, **"系列"**, **"看過"**, **"vue"**, **"官方"**, **"文件"**... 等，都是 1-gram (或稱 unigram)。
而 2-gram (或稱 bi-gram) 以內文舉例就是，**"前言系列"**, **"系列看過"**, **"看過vue"**, **"vue官方"**, **"官方文件"**...等。
從 bigram 中我們可以發現，
並不是我們抓出的所有 bigram 都那麼的具有意義，
因此抓出 bigram 後通常還要進一步篩選。

這次我們`keyword extraction`用的是 python package [KeyBERT]，
使用的模型是 **"paraphrase-multilingual-MiniLM-L12-v2"**，可以適用於多語言。

```json
{
    "extracted_keywords":[
        "學習效果",
        "課程",
        "單元測試",
        "新課程",
        "testing"
    ],
    "extracted_keywords_phrases":[
        "單元測試 產品開發",
        "撰寫 單元測試",
        "單元測試 影片",
        "文章 學習效果",
        "單元測試 框架"
    ]
}
```

大家可以嘗試 **jupyter notebook** 中的程式碼，
明天會最後簡單概括一下資料處理的部分，
後天便會準備進入搜尋引擎相關的內容。

[Github]: https://github.com/over-engineering-ru
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[Day 02]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/02_what_is_search_engine_I.md
[Stop Word]: https://en.wikipedia.org/wiki/Stop_word
[Jieba]: https://github.com/fxsjy/jieba
[n-gram]: https://en.wikipedia.org/wiki/N-gram
[KeyBERT]: https://github.com/MaartenGr/KeyBERT
