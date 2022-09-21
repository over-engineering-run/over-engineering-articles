# [Day 06] 實作技術架構 - 在 IT 邦尋求答案是否少了些什麼 |【搜尋引擎製作錄】

[Github], [Over Engineering]

今天便是前言的最後一篇了，
在進入到接下來的實作前，
我們要來討論一下整體搜尋引擎的架構，
以及我們用到了哪些的技術。

選擇合適的技術棧及架構設計，
不僅能提升開發的效率，
也能避免後續可能產生的一些問題。

![alt text](https://raw.githubusercontent.com/over-engineering-run/over-engineering-articles/main/resources/day06-01-architecture-zh.png)


## 系統架構
從上面一張簡單的架構圖中，我們可以從中間將整系統切為上下兩部份，

- **應用程序**
  位於上半部的 **"應用程序"** 是使用者透過網站前後端、搜尋引擎來獲得搜尋的服務。
- **資料處理**
  而下半部 **"資料處理"** 的部分則是包含`網路爬蟲` (web crawler)、資料庫、NLP模組、搜尋引擎等，來搜集與建構後台的資料庫。

這次的鐵人賽在 [day 01] 也有提到過是與 Kirby 合作完成的，
我的專長在於`NLP`與搜尋引擎，後端與資料庫也有涉略，
唯獨對於前端部分是完全不會，而 Kirby 的專長也正是前端。

因此，在實作分工時，便由我負責`NLP`與搜尋引擎。
後端由於 API 都是與搜尋引擎功能緊密連結，所以也由我負責。
而 Kirby 則是負責前端的部分，與分擔網路爬蟲的實作。


### 資料處理
一切都須從資料搜集開始，當我們確定搜尋引擎所要搜尋的資料目標後，
便需要開始搜集相關的資料。

- **網路爬蟲**
這次我們實作的是 IT 邦鐵人賽文章的搜尋引擎，
因此我們便需要透我們在 [day 02] 所提到的網路爬蟲，
藉由自動化的方式將網頁資料抓取下來。
<br>這次 Kirby 在實作爬蟲時，使用的語言是`javascript`。
實作時使用 [deno] 擷取資料，
並存入資料庫 [supabase]，一個開源的 [postgresql] 雲端資料庫服務。

> Kirby 選擇用`javascript` 寫爬蟲的原因，
> 一來他比較喜歡`javascript` XD
> 二來`javascript`爬蟲的文章相對 `python` 較少，
> 他也想藉此實作寫下一些文章。

> 選擇 `supabase` 的原因除了 postgresql 外，
> 它在一定儲存量下也是免費的。

- **NLP 模組**
在 [day 02] 時，我們也簡述了，
在透過網路爬蟲取得原始資料後，為何要進行資料的前處理。
並且`NLP`也是其中不可或缺的一環。
這次的實作中，我所使用的語言是`python`，
將資料從資料庫 [supabase] 中讀取出來後，
我們透過`NLP`及其他前處理後，
將得到的結果資料寫入到搜尋引擎 [Meilisearch] 中，並建立索引。
同時，有部分的資料也會同時更新寫回到資料庫 [supabase] 中。

> 選擇使用 `python` 的原因，
> 也是因其有許多資料處理與機器學習的相關 packages，
> 相當的方便。

> 至於選擇 `Meilisearch` 的原因，
> 則是它相對而言對於初學者更加的友善易上手。


### 應用程序

取得並完成資料處理後，我們便可以開始建置我們應用程序的部分。
應用程序程序主要分為 **Web 前端** 跟 **API 後端** 兩個部分

- **Web 前端**
  負責與用戶互動，讓用戶能夠高效簡單的操作系統，
  Kirby 採用 [remix]，一個新的 [react] [ssr] 框架。

- **API 後端**
  負責提供前端需要的資料、及相關服務，並保護敏感的資訊。
  API 的部分也依據所提供的功能，
  需要與搜尋引擎 [Meilisearch] 或是 [supabase] 連結溝通。
  我使用 [flask] 架設了一個簡易的後端。

> 我原本是想用 `golang`寫後端的，
> 後來會選擇使用 `python` 也是為了避免過多不同的語言，
> 影響文章的可讀性。
> 同時過去也沒有用過 `flask`，想嘗試看看。

最後，我們除了在本地端測試外，
也會將之部署到 [fly.io] 上。
[fly.io] 是一個相對於 aws 或 gcp 等更加簡單的平台，
只要將 docker image 準備好，就可以輕易部署完成。
同時，雖然有些許限制，但也是近乎免費。
非常適合用於產品週期前期的開發與測試。

明天我們將會進入到實作環節，並從資料處理部分的`網路爬蟲`開始。


[Github]: https://github.com/over-engineering-ru
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[day 01]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/01_introduction.md
[day 02]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/02_what_is_search_engine_I.md#%E7%8D%B2%E5%8F%96%E8%B3%87%E6%96%99
[deno]: https://deno.land/
[supabase]: https://supabase.com/
[postgresql]: https://www.postgresql.org/
[remix]: https://remix.run/
[react]: https://reactjs.org/
[ssr]: https://en.wikipedia.org/wiki/Server-side_scripting#Server-side_rendering
[flask]: https://flask.palletsprojects.com/en/2.2.x/
[meilisearch]: https://docs.meilisearch.com/
[fly.io]: https://fly.io/
