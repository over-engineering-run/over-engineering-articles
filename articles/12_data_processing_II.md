# [Day 12] Data Pipeline - 果然我的自然語言處理搞錯了。|【搜尋引擎製作錄】

[Github], [Over Engineering]

**礙於篇幅緣故，過多細節的部分，會挑重點講述，如有疑問歡迎留言討論**

昨天我們有提到，從功能、應用端思考缺少哪些資訊，
而這些資訊便需要透過資料處理取得。
所以資料處理便如同工廠將原材料加工後，
取得我們所想要的產品，並且在規格上須符合後續應用的要求。

## Data Pipeline
那麼，在進入到實作之前，
我們必須先介紹一個概念，[Data Pipeline]。
它的概念類似於工廠的流水生產線，一環接著一環，
每個生產階段的輸出，便會是下個階段的輸入。

![](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day11-03-production_line.png)

## Test Code Data Pipeline

這次我們資料處理的測試環節，
所用到的程式碼及資料都在 [Test Code] 中。

首先，我們要設置環境，
執行 [Test Code] 中的 setup script，
會安裝我們所需要用到的 python packages。

```bash
sh ./testing-setup.sh
```

我們的資料處理，主要包含了以下的階段
- **Preprocessing 1: Load Data from SQL**
- **Preprocessing 2: Extract Content from HTML**
- **Preprocessing 3: Content Text**
- **Preprocessing 4: Keyword Extraction from Processed Contents**

我們可以透過執行 [Test Code] 中 jupyter notebook `testing-nlp.ipynb`，
來測試 pipeline。

## Preprocessing 1: Load Data from SQL
資料處理的最開始，
我們需要從 [Test Code] 中的 `sqlite` 資料庫，
`testing-ironman_100.db` 中讀取測試資料。
我們用 100 篇文章作為簡單的測試資料。

```json
{
    "href": "https://ithelp.ithome.com.tw/articles/10282236",
    "title": "[專案上線第01天] -  新來的主管說要寫 Vue Test Utils 單元測試",
    "content_html": "<div class=\"markdown__style\">\n                                                            <h3>前言</h3>\n<blockquote>\n<p>該系列是為了讓看過Vue官方文件或學過Vue但是卻不知道怎麼下手去重構現在有的網站而去規畫的系列文章，在這邊整理了許多我自己使用Vue重構很多網站的經驗分享給讀者們。</p>\n</blockquote>\n<p>什麼？單元測試？當你開始接觸開發專案有一段時間後，你會開始漸漸聽到這個專業術語，就讓我來大家了解一下什麼是單元測試</p>\n<p><iframe width=\"560\" height=\"315\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"allowfullscreen\" src=\"https://www.youtube.com/embed/j2ggBXF54dA\"></iframe><br>\n影片搭配文章看學習效果會更好喔</p>\n<h2>什麼是單元測試？</h2>\n<p>簡單來說程式碼的最小單位進行測試，確保程式邏輯不會在團隊維護的過程中出錯，維護程式碼的品質。所謂的最小單位，我用個例子來舉例，假如你今天有一個主功能是由 A跟Ｂ兩個功能所組成的，而這兩個功能就是我們所說的最小單位，所以在撰寫測試的時候我們重點在針對A跟Ｂ來進行測試，主功能的測試中不會包含 A跟Ｂ的測試，這樣的測試就是我們所說的單元測試。</p>\n<h2>為什麼需要單元測試？</h2>\n<p>我先列出幾個優缺點，我們來比較一下</p>\n<h3>優點：</h3>\n<ol>\n<li>確保團隊跌代的時候不會影響原本的功能</li>\n<li>確保品質，準確對程式碼切割最小單位，降低耦合度</li>\n<li>程式的 return 變成可預期</li>\n<li>重構程式碼可以按照測試的規格走</li>\n</ol>\n<h3>缺點 :</h3>\n<ol>\n<li>初期可能撰寫單元測試所消耗的時間可能會大於實際開發時間</li>\n<li>如果迭代性高，很常寫好的測試要重寫，久了會浪費很多時間</li>\n<li>測試相關的配置繁瑣，為了配合許多開發上的細節要處理的設定很多</li>\n</ol>\n<p>從優缺點可以知道說，撰寫單元測試的初期對於開發的效益並不高，先撇開不熟悉測試來說，光就在公司常常會因為需求改變就要來來回回改寫程式，我就要再花許多時間來重寫測試，怎麼想都對於有時辰壓力的專案來說不是那麼划算，所以往往會在這個時候放棄寫測試，就像我如果在初期會遇到不斷修改的需求的時候，我也不會先寫測試（笑</p>\n<p>那什麼情況下該寫單元測試？其實產品開發的中期的時候，基本上中期的時候大多數的平台規格都確定了差不多，就可以考慮開始補單元測試，因為會開始遇到前面做好的功能因為新的功能造成預期外的錯誤，以及專案由其他同事接手的時候改壞某個功能但是同事不知道，這些我們都可以透過測試來了解，避免把測試沒通過的案子給推上線。</p>\n<h2>開始寫 Vue 的單元測試前</h2>\n<p>開始寫測試前我們要先了解一下我們是透過何種<strong>技術</strong>來撰寫測試的</p>\n<h3>Jest</h3>\n<p>Jest 是由 Facebook 開發維護的一款 JavaScript 測試框架，可以用簡潔的語法來測試你的 function 。</p>\n<h3>Vue Test Utils</h3>\n<p>Vue Test Utils 是 Vue 官方推出的組件單元測試框架，簡化組件的測試。它提供了一些方法來以區分掛載組件之間交互。</p>\n<p>我們會透過以上兩種測試用的框架來針對我們 vue 的 component 進行測試，Vue Test Utils 負責解析我們的 component，讓我們可以不透過 build 就可以模擬 DOM 被渲染出來的結果，再透過 Jest 撰寫 test case 來驗證是否符合預期。</p>\n<h2>安裝 jest 與 Vue Test Utils （ Vue-cli ）</h2>\n<p>如果你是新建立一個專案，請你選擇 Unit Testing -&gt; Jest，這樣專案預設就會有安裝 jest 跟 Vue Test Utils</p>\n<p><img src=\"https://ithelp.ithome.com.tw/upload/images/20220419/20125854cuHDuilGGc.png\" alt=\"https://ithelp.ithome.com.tw/upload/images/20220419/20125854cuHDuilGGc.png\"></p>\n<p>如果你在建立專案的時候沒有選擇 Unit Testing 的話你可以輸入以下指令</p>\n<pre><code>vue add unit-jest\n</code></pre>\n<p>現有的 CLI 專案，也可以加入 jest 跟 Vue Test Utils</p>\n<h2>基本語法介紹 describe &amp; it &amp; test</h2>\n<p>先來帶大家來看一下基本的語法</p>\n<pre><code class=\"language-javascript\">describe(\"Test to do list\", () =&gt; {\n  it(\"Test to do 1\", () =&gt; {\n    expect(1 + 1).toBe(2);\n  });\n  test(\"Test to do 2\", () =&gt; {\n   expect(2 + 1).toBe(3);\n  });\n});\n</code></pre>\n<ul>\n<li>describe ： 類似群組的概念，用來將一個或是多個相關的測試包再一起。</li>\n<li>it ＆test ： 為測試的項目單位，it 為 test 的別名兩個是一樣的東西。</li>\n<li>expect ：你要測試的項目內容。</li>\n<li>toBe ： 斷言，主要是來檢查 expect 回傳的內容是否符合你的預期，有很多種形式的斷言。</li>\n</ul>\n<p>以上的這些語法屬於 jest 的語法 API</p>\n<p>接下來看看如何使用 Vue Test Utils 負責解析我們的 Component</p>\n<pre><code class=\"language-html\">&lt;!-- HelloWorld.vue --&gt;\n&lt;template&gt;\n  &lt;h1&gt;new message&lt;/h1&gt;\n&lt;/template&gt;\n\n</code></pre>\n<pre><code class=\"language-javascript\">import { shallowMount } from \"@vue/test-utils\";\nimport HelloWorld from \"@/components/HelloWorld.vue\";\ndescribe(\"HelloWorld.vue\", () =&gt; {\n  it(\"renders msg text\", () =&gt; {\n    const wrapper = shallowMount(HelloWorld);\n    expect(wrapper.text()).toBe(\"new message\");\n  });\n});\n</code></pre>\n<p>我們可以直接使用 shallowMount 這個方法來渲染我們的 Component，再透過 .text( ) 這個方法去取得 Component 裡面所有的文字內容來做比對，是不是覺得很簡單呢～</p>\n<h2>最後</h2>\n<p>好啦！關於單元測試的部分就到這邊先告一段落，如果你還想知道更多有關於單元測試的使用以及使用情境，歡迎購買我的新課程 <strong>Vue 單元測試 vue-test-utils｜入門</strong></p>\n<p>課程網址：<a href=\"https://thecodingpro.com/courses/vue-test-utils\" target=\"_blank\" rel=\"noreferrer noopener\">https://thecodingpro.com/courses/vue-test-utils</a></p>\n<p><img src=\"https://ithelp.ithome.com.tw/upload/images/20220419/20125854wT0M5271od.png\" alt=\"https://ithelp.ithome.com.tw/upload/images/20220419/20125854wT0M5271od.png\"></p>\n<p>原價新台幣 2200 元，目前還是維持預購價新台幣 1800元，現在輸入折扣碼「 PAJNBFUNO300」馬上再折300元優惠。</p>\n<p><img src=\"https://d1dwq032kyr03c.cloudfront.net/upload/images/20210901/20125854yMlu8aU1vd.jpg\" alt=\"QRcode\"></p>\n<h3>訂閱Mike的頻道享受精彩的教學與分享</h3>\n<p><a href=\"https://www.youtube.com/channel/UC7ArpUezGLX-dZ0FTS_jVMQ\" target=\"_blank\" rel=\"noreferrer noopener\">Mike 的 Youtube 頻道</a><br>\n<a href=\"https://medium.com/i-am-mike\" target=\"_blank\" rel=\"noreferrer noopener\">Mike的medium</a><br>\nMIke 的官方 line 帳號，好友搜尋 @mike_cheng</p>\n <br>\n                                                    </div>",
    "raw_tags_string": "13th鐵人賽,vue.js,vue,vue3,vue學習筆記",
    "genre": "Modern Web",
    "published_at": "2022-04-19 16:18:27",
    "author_href": "https://ithelp.ithome.com.tw/users/20125854/ironman",
    "author_name": "Mike",
    "series_href": "https://ithelp.ithome.com.tw/users/20125854/ironman/4112",
    "series_name": "[ 重構倒數30天，你的網站不Vue白不Vue ]",
    "series_num": "32"
}
```

## Preprocessing 2: Extract Content from HTML
接下來，我們使用 `beautiful Soup` 套件，
來分析、擷取我們 `html` 中的資料。
其中主要包含 **擷取內文** 與 **文章所使用的程式語言**。

- **擷取內文**
可以相當簡單的使用 `beautiful soup` 的函式 **get_text()**。
</br>稍微注意的是，我們後續搜尋引擎並沒有使用到網頁或是圖片連結，
所以要將要將連結移除。
</br>此外，程式碼的部分，目前在後續搜尋時，
也沒有用到程式語言的內容，所以在分析程式語言後，也回被從內文中移除。

- **分析文章所使用的程式語言**
分析程式語言的方式，目前也使用較簡單的方法，礙於時間還沒有深入研究。
此外，會用到 [Programming Language Dictionary] 於字串比對 (string matching)。

  - **code block**
    - 可以參考 `jupyter notebook` 中 `parse_programming_language_from_code_attr` 的部分。
    - 透過 code block 的 class attribute 得知是用到什麼程式語言。

  - **string matching**
    - 可以參考 `jupyter notebook` 中 `extract_programming_language_from_content` 的部分。
    - 使用簡單的規則，對內文做字串比對，
      找出所有被提及兩次以上的程式語言。

下方是擷取、分析出來的內文與程式語言。
輸出的內容會被用於下個階段的輸入。
明天我們會繼續介紹 `data pipeline` 剩下的兩個階段。

```json
{
    "processed_content_html":"<div class=\"markdown__style\">\n<h3>前言</h3>\n<blockquote>\n<p>該系列是為了讓看過Vue官方文件或學過Vue但是卻不知道怎麼下手去重構現在有的網站而去規畫的系列文章，在這邊整理了許多我自己使用Vue重構很多網站的經驗分享給讀者們。</p>\n</blockquote>\n<p>什麼？單元測試？當你開始接觸開發專案有一段時間後，你會開始漸漸聽到這個專業術語，就讓我來大家了解一下什麼是單元測試</p>\n<p><iframe allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen=\"allowfullscreen\" frameborder=\"0\" height=\"315\" src=\"https://www.youtube.com/embed/j2ggBXF54dA\" width=\"560\"></iframe><br/>\n影片搭配文章看學習效果會更好喔</p>\n<h2>什麼是單元測試？</h2>\n<p>簡單來說程式碼的最小單位進行測試，確保程式邏輯不會在團隊維護的過程中出錯，維護程式碼的品質。所謂的最小單位，我用個例子來舉例，假如你今天有一個主功能是由 A跟Ｂ兩個功能所組成的，而這兩個功能就是我們所說的最小單位，所以在撰寫測試的時候我們重點在針對A跟Ｂ來進行測試，主功能的測試中不會包含 A跟Ｂ的測試，這樣的測試就是我們所說的單元測試。</p>\n<h2>為什麼需要單元測試？</h2>\n<p>我先列出幾個優缺點，我們來比較一下</p>\n<h3>優點：</h3>\n<ol>\n<li>確保團隊跌代的時候不會影響原本的功能</li>\n<li>確保品質，準確對程式碼切割最小單位，降低耦合度</li>\n<li>程式的 return 變成可預期</li>\n<li>重構程式碼可以按照測試的規格走</li>\n</ol>\n<h3>缺點 :</h3>\n<ol>\n<li>初期可能撰寫單元測試所消耗的時間可能會大於實際開發時間</li>\n<li>如果迭代性高，很常寫好的測試要重寫，久了會浪費很多時間</li>\n<li>測試相關的配置繁瑣，為了配合許多開發上的細節要處理的設定很多</li>\n</ol>\n<p>從優缺點可以知道說，撰寫單元測試的初期對於開發的效益並不高，先撇開不熟悉測試來說，光就在公司常常會因為需求改變就要來來回回改寫程式，我就要再花許多時間來重寫測試，怎麼想都對於有時辰壓力的專案來說不是那麼划算，所以往往會在這個時候放棄寫測試，就像我如果在初期會遇到不斷修改的需求的時候，我也不會先寫測試（笑</p>\n<p>那什麼情況下該寫單元測試？其實產品開發的中期的時候，基本上中期的時候大多數的平台規格都確定了差不多，就可以考慮開始補單元測試，因為會開始遇到前面做好的功能因為新的功能造成預期外的錯誤，以及專案由其他同事接手的時候改壞某個功能但是同事不知道，這些我們都可以透過測試來了解，避免把測試沒通過的案子給推上線。</p>\n<h2>開始寫 Vue 的單元測試前</h2>\n<p>開始寫測試前我們要先了解一下我們是透過何種<strong>技術</strong>來撰寫測試的</p>\n<h3>Jest</h3>\n<p>Jest 是由 Facebook 開發維護的一款 JavaScript 測試框架，可以用簡潔的語法來測試你的 function 。</p>\n<h3>Vue Test Utils</h3>\n<p>Vue Test Utils 是 Vue 官方推出的組件單元測試框架，簡化組件的測試。它提供了一些方法來以區分掛載組件之間交互。</p>\n<p>我們會透過以上兩種測試用的框架來針對我們 vue 的 component 進行測試，Vue Test Utils 負責解析我們的 component，讓我們可以不透過 build 就可以模擬 DOM 被渲染出來的結果，再透過 Jest 撰寫 test case 來驗證是否符合預期。</p>\n<h2>安裝 jest 與 Vue Test Utils （ Vue-cli ）</h2>\n<p>如果你是新建立一個專案，請你選擇 Unit Testing -&gt; Jest，這樣專案預設就會有安裝 jest 跟 Vue Test Utils</p>\n<p></p>\n<p>如果你在建立專案的時候沒有選擇 Unit Testing 的話你可以輸入以下指令</p>\n<pre></pre>\n<p>現有的 CLI 專案，也可以加入 jest 跟 Vue Test Utils</p>\n<h2>基本語法介紹 describe &amp; it &amp; test</h2>\n<p>先來帶大家來看一下基本的語法</p>\n<pre></pre>\n<ul>\n<li>describe ： 類似群組的概念，用來將一個或是多個相關的測試包再一起。</li>\n<li>it ＆test ： 為測試的項目單位，it 為 test 的別名兩個是一樣的東西。</li>\n<li>expect ：你要測試的項目內容。</li>\n<li>toBe ： 斷言，主要是來檢查 expect 回傳的內容是否符合你的預期，有很多種形式的斷言。</li>\n</ul>\n<p>以上的這些語法屬於 jest 的語法 API</p>\n<p>接下來看看如何使用 Vue Test Utils 負責解析我們的 Component</p>\n<pre></pre>\n<pre></pre>\n<p>我們可以直接使用 shallowMount 這個方法來渲染我們的 Component，再透過 .text( ) 這個方法去取得 Component 裡面所有的文字內容來做比對，是不是覺得很簡單呢～</p>\n<h2>最後</h2>\n<p>好啦！關於單元測試的部分就到這邊先告一段落，如果你還想知道更多有關於單元測試的使用以及使用情境，歡迎購買我的新課程 <strong>Vue 單元測試 vue-test-utils｜入門</strong></p>\n<p>課程網址：</p>\n<p></p>\n<p>原價新台幣 2200 元，目前還是維持預購價新台幣 1800元，現在輸入折扣碼「 PAJNBFUNO300」馬上再折300元優惠。</p>\n<p></p>\n<h3>訂閱Mike的頻道享受精彩的教學與分享</h3>\n<p><br/>\n<br/>\nMIke 的官方 line 帳號，好友搜尋 @mike_cheng</p>\n<br/>\n</div>",
    "content_text":"前言\n\n該系列是為了讓看過Vue官方文件或學過Vue但是卻不知道怎麼下手去重構現在有的網站而去規畫的系列文章，在這邊整理了許多我自己使用Vue重構很多網站的經驗分享給讀者們。\n\n什麼？單元測試？當你開始接觸開發專案有一段時間後，你會開始漸漸聽到這個專業術語，就讓我來大家了解一下什麼是單元測試\n\n影片搭配文章看學習效果會更好喔\n什麼是單元測試？\n簡單來說程式碼的最小單位進行測試，確保程式邏輯不會在團隊維護的過程中出錯，維護程式碼的品質。所謂的最小單位，我用個例子來舉例，假如你今天有一個主功能是由 A跟Ｂ兩個功能所組成的，而這兩個功能就是我們所說的最小單位，所以在撰寫測試的時候我們重點在針對A跟Ｂ來進行測試，主功能的測試中不會包含 A跟Ｂ的測試，這樣的測試就是我們所說的單元測試。\n為什麼需要單元測試？\n我先列出幾個優缺點，我們來比較一下\n優點：\n\n確保團隊跌代的時候不會影響原本的功能\n確保品質，準確對程式碼切割最小單位，降低耦合度\n程式的 return 變成可預期\n重構程式碼可以按照測試的規格走\n\n缺點 :\n\n初期可能撰寫單元測試所消耗的時間可能會大於實際開發時間\n如果迭代性高，很常寫好的測試要重寫，久了會浪費很多時間\n測試相關的配置繁瑣，為了配合許多開發上的細節要處理的設定很多\n\n從優缺點可以知道說，撰寫單元測試的初期對於開發的效益並不高，先撇開不熟悉測試來說，光就在公司常常會因為需求改變就要來來回回改寫程式，我就要再花許多時間來重寫測試，怎麼想都對於有時辰壓力的專案來說不是那麼划算，所以往往會在這個時候放棄寫測試，就像我如果在初期會遇到不斷修改的需求的時候，我也不會先寫測試（笑\n那什麼情況下該寫單元測試？其實產品開發的中期的時候，基本上中期的時候大多數的平台規格都確定了差不多，就可以考慮開始補單元測試，因為會開始遇到前面做好的功能因為新的功能造成預期外的錯誤，以及專案由其他同事接手的時候改壞某個功能但是同事不知道，這些我們都可以透過測試來了解，避免把測試沒通過的案子給推上線。\n開始寫 Vue 的單元測試前\n開始寫測試前我們要先了解一下我們是透過何種技術來撰寫測試的\nJest\nJest 是由 Facebook 開發維護的一款 JavaScript 測試框架，可以用簡潔的語法來測試你的 function 。\nVue Test Utils\nVue Test Utils 是 Vue 官方推出的組件單元測試框架，簡化組件的測試。它提供了一些方法來以區分掛載組件之間交互。\n我們會透過以上兩種測試用的框架來針對我們 vue 的 component 進行測試，Vue Test Utils 負責解析我們的 component，讓我們可以不透過 build 就可以模擬 DOM 被渲染出來的結果，再透過 Jest 撰寫 test case 來驗證是否符合預期。\n安裝 jest 與 Vue Test Utils （ Vue-cli ）\n如果你是新建立一個專案，請你選擇 Unit Testing -> Jest，這樣專案預設就會有安裝 jest 跟 Vue Test Utils\n\n如果你在建立專案的時候沒有選擇 Unit Testing 的話你可以輸入以下指令\n\n現有的 CLI 專案，也可以加入 jest 跟 Vue Test Utils\n基本語法介紹 describe & it & test\n先來帶大家來看一下基本的語法\n\n\ndescribe ： 類似群組的概念，用來將一個或是多個相關的測試包再一起。\nit ＆test ： 為測試的項目單位，it 為 test 的別名兩個是一樣的東西。\nexpect ：你要測試的項目內容。\ntoBe ： 斷言，主要是來檢查 expect 回傳的內容是否符合你的預期，有很多種形式的斷言。\n\n以上的這些語法屬於 jest 的語法 API\n接下來看看如何使用 Vue Test Utils 負責解析我們的 Component\n\n\n我們可以直接使用 shallowMount 這個方法來渲染我們的 Component，再透過 .text( ) 這個方法去取得 Component 裡面所有的文字內容來做比對，是不是覺得很簡單呢～\n最後\n好啦！關於單元測試的部分就到這邊先告一段落，如果你還想知道更多有關於單元測試的使用以及使用情境，歡迎購買我的新課程 Vue 單元測試 vue-test-utils｜入門\n課程網址：\n\n原價新台幣 2200 元，目前還是維持預購價新台幣 1800元，現在輸入折扣碼「 PAJNBFUNO300」馬上再折300元優惠。\n\n訂閱Mike的頻道享受精彩的教學與分享\n\n\nMIke 的官方 line 帳號，好友搜尋 @mike_cheng",
    "content_code_info":[
        {
            "language":"unknown",
            "content":"vue add unit-jest\n"
        },
        {
            "language":"javascript",
            "content":"describe(\"Test to do list\", () => {\n  it(\"Test to do 1\", () => {\n    expect(1 + 1).toBe(2);\n  });\n  test(\"Test to do 2\", () => {\n   expect(2 + 1).toBe(3);\n  });\n});\n"
        },
        {
            "language":"html",
            "content":"<!-- HelloWorld.vue -->\n<template>\n  <h1>new message</h1>\n</template>\n\n"
        },
        {
            "language":"javascript",
            "content":"import { shallowMount } from \"@vue/test-utils\";\nimport HelloWorld from \"@/components/HelloWorld.vue\";\ndescribe(\"HelloWorld.vue\", () => {\n  it(\"renders msg text\", () => {\n    const wrapper = shallowMount(HelloWorld);\n    expect(wrapper.text()).toBe(\"new message\");\n  });\n});\n"
        }
    ],
    "programming_languages":[
        "javascript",
        "html"
    ]
}
```


[Github]: https://github.com/over-engineering-ru
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[Data Pipeline]: https://en.wikipedia.org/wiki/Pipeline_(computing)
[Test Code]: https://github.com/over-engineering-run/over-engineering/tree/v0.0.1/nlp/testing
[Programming Language Dictionary]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/resources/programming_language.json
