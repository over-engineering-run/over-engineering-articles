# 如何規劃技術架構 - 在IT邦尋求答案是否少了些什麼 |【搜尋引擎製作錄】

## 概念

對於整個系統開發生命週期而言，技術棧是極其重要的第一步。  
選擇適合的技術棧等同建構一個好的骨幹，  
他讓你達成你的目標產出，帶來優秀的效能，  
以及我個人建議主管層級應該關注的部分，**提升工程師的生產效率**。

選擇適合的技術棧也可以提前預防未來可能會發生的問題，  
好的技術棧會幫助開發者避開風險，  
而這些**絕對會省下整體的開發成本跟時間**。

## 系統

整個系統可以被分做兩個部分，  
- 資料處理
- 應用程序

### 資料處理

用戶碰不到的部分，主要負責**資訊搜集**跟**自然語言處理建立 index**。

**crawler 爬蟲** 會將擷取到的資料儲存到 **database 資料庫** 中，
**crawler 爬蟲** 我們會用 [deno] 來擷取文章資訊，
並將擷取的資訊存進 [supabase]，開源的 [postgres] 雲端資料庫服務。

**nlp 自然語言處理** 會將 **database 資料庫** 中的資訊處理過後，
轉存進 **search engine 搜尋引擎**。

todo

### 應用程序

主要分成 **web 前端** 跟 **api 後端**。

**web 前端** 負責與用戶互動，讓用戶能夠高效簡單的操作系統，
我們採用 [remix]，一個新的 [react] [ssr] 框架。

**api 後端** 負責提供前端需要的資料，並保護敏感的資訊。

todo

## 架構流程


[deno]: https://deno.land/
[supabase]: https://supabase.com/
[postgres]: https://www.postgresql.org/
[remix]: https://remix.run/
[react]: https://reactjs.org/
[ssr]: https://en.wikipedia.org/wiki/Server-side_scripting#Server-side_rendering
