# [Day 23] 如何規劃前端技術棧 - 實用至上主義前端 |【搜尋引擎製作錄】

[Github], [Over Engineering]

## 基礎

對於整個 web 開發生命週期而言，技術棧是極其重要的第一步。
選擇適合的技術棧等同建構一個好的骨幹，
它讓你達成你的目標產出，帶來優秀的效能，
以及 Kirby 個人建議主管層級應該關注的部分，**提升工程師的生產效率**。

> aka. 技術棧 應該要兼顧 效能 與 容易開發。

## 技術選擇

### 簡單

框架，架構，工具，必須要保持簡單。
並非是為了簡單而過度抽象，而是盡可能地接近原生。

### 效能

為了提供良好的用戶體驗，我們會參照 [Lighthouse] 建議的效能指標數據。

> 所謂的效能是相對性的，也就是說：
> 一個應用程式可能在我的裝置上很快，但在別人的裝置上很慢。
> 兩個應用程式雖然是同樣的載入時間，但是感覺其中一個比另一個快。
> 應用程式雖然載入很快，但是在用戶互動方面卻很鈍。
> 所以在談論效能時，精準跟客觀可量化的測量指標就非常重要。

首次內容繪製 (FCP)：
從頁面開始載入到頁面任何一處的內容被渲染到畫面上的時間。

速度指數 (SI)：
頁面開始載入到可以視覺呈現的時間。

最大內容繪製 (LCP)：
從頁面開始載入到頁面最大的文字區塊或是圖片被渲染到畫面上的時間。

可交互時間 (TTI)：
從頁面開始載入到應用程式可以迅速回應用戶互動的時間。

總阻塞時間 (TBT)：
從 FCP 到 TTI 期間，因主執行緒被阻塞而無法回應互動的時間。

累計佈局偏移 (CLS)：
當頁面開始載入直到頁面被關閉期間，Layout 產生非預期的位移。

第一字節時間 (TTFB)：
當用戶發出網路請求到瀏覽器取得第一個 byte 的時間。

分數要在 90 分以上。

## 基底框架

### React

簡單，
是我在使用了各種框架後，依然推薦使用[React]的原因。

這裡指的簡單並非是指入門簡單，
[React] 老實說入門並不簡單，
但對於目標是要 production 來說，反而開發相對簡單。
因為他非常吻合 javascript 的基礎觀念，
基於 functional programming 的架構，
讓追蹤資料流向跟問題變得非常容易，
且框架也不會沒事就綁手綁腳，
這非常符合我的觀念，
工程師不應該依賴於框架，而是運用框架。

### Remix

會採用 [Remix] 也是基於這點，
相較於 [Nextjs]，[Remix] 運用了更多的原生 web 就有的功能。
而且也沒有限制 server 用的技術，
雖然預設會給 express server，
但你也可以用 fastify 甚至是 deno server 來運行 remix。

再來是基於實測數據，
[Remix] 的效能確實筆 [Nextjs] 好非常多，
他真正的採用了 http2 的平行載入機制，
並且因為大部分運用的都是原生 web 的技術，
所以程式碼的量少非常多。

### Tailwindcss

使用 [tailwindcss] 能夠讓 style 的開發變的簡單且更容易維護，
我使用過非常多 css 技術，
從 css => sass => less => css module => css in js => postcss，
一直都沒有遇到讓我滿意的答案，直到遇見 [tailwindcss]。

我們不用在額外維護一堆 css 檔案，
在 jsx 就可以處理完我們的 style，
且無需花費額外的腦力成本去學習 [styled-components]，
所有的東西都是簡單的 html class。

在專案開發的過程中，最影響效能的不一定是 js 或是 其他資源，
反而可能是 css 的量，
在高度客製化樣式的專案，每個頁面可能會用到的樣式變化多端，
隨著時間經過，很容易就變成難以維護的大坑。

透過 [tailwindcss]，所有的 style 都會在掌控之中，
而且產生出來的 css 量也是非常少，
對於 production 來說幾乎是首選。

## 自動化與部署

因為相較於其他 CI/CD 工具來說，實在相對簡單。
我們會繼續使用 [GitHub Action][github-actions] 作為自動化工具。

並且部署到 [fly.io] 上，
他的定位跟 [heroku] 類似，但更簡單效能也更好。


[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/

[TTI]: https://developer.mozilla.org/en-US/docs/Glossary/Time_to_interactive
[Lighthouse]: https://web.dev/user-centric-performance-metrics/

[React]: https://reactjs.org/
[Remix]: https://remix.run/
[Nextjs]: https://nextjs.org/
[tailwindcss]: https://tailwindcss.com/
[styled-components]: https://styled-components.com/
[github-actions]: https://github.com/features/actions
[fly.io]: https://fly.io/
[heroku]: https://www.heroku.com/
