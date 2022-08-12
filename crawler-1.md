# 【】關於前端大叔轉生爬蟲後的那檔子事

為了提供我 Data Science 需要的資料，要來準備爬蟲程式！

不想特別去寫 _Python_，所以就用 _Javascript_ 吧！  

> 在我們的搜尋結果也發現，**沒有人** 有嘗試過 _Python_ 以外的選項！？

這個小系列分做三份  
- 概述 (當前這篇)
- 實作 [Crawler] ([Deno])
- 實作 [Scheduler] ([Github Action])

## 相關名詞

這邊先進行名詞解釋，方便後面同步。

[Scraping] 專門指擷取網頁資料，  
人工的 Copy Paste 也算在此類，  
把資料擷取下來之後再送去分析或儲存，  
使資料能更有效的被利用。

[Crawler] 一般用作 [Indexing]，_index_ 是指圖書館的那種。  
搜尋引擎方會寫機器人用來搜集在網路上的資料，  
機器人會爬過每一個頁面跟每一個連結，比較非目的性，  
許多大型的搜尋引擎像是 Google, Bing, Yahoo 使用的 Bots 就屬於此類。  
( 就一般人在講的 _spider_ )。

[Scheduler] 預先設置好在某個時間點執行某項任務的腳本。  
也可以稱作 _排程_。

## 程式邏輯

![architecture](https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/WebCrawlerArchitecture.svg/1280px-WebCrawlerArchitecture.svg.png)

我們的目的只需要鐵人賽文章，  
因為有明確的目標加上幾乎固定的資料集，  
這邊就不用特別沿著連結慢慢爬，  
直接對確定的目標進行資料擷取，  
然後每週固定跑一次即可。

再來設計程式流程，  
整個資料搜集分做兩大塊，_crawler job_ 跟 _extracting_。  

為了不佔篇幅，這邊直接給最後的思路 (pseudo code)。

### Crawler Job
- 透過 [Scheduler] 觸發 [Crawler]。
- 根據總頁數，拆做好幾份，生成對應數量的 [Crawler] 並行處理。

### Extracting
- 根據指定的頁數範圍，擷取該頁的文章列表。
- 根據文章列表的文章連結，接取該連結的文章資訊。
- 將擷取出的文章資訊存入資料庫。

另外，我的目標是 _盡可能減少不必要的程式碼_，  
所以 _crawler job_ 會透過 [GitHub Action] 處理。 

## 待優化方向

- 應該另外寫一隻用於擷取總頁數以及拆分頁數的程式，而不是寫死頁數。
- 完整的架構應該還需要 url 的紀錄，以便避免重複擷取。

## Reference

- [Crawler]
- [Indexing]
- [Scraping]
- [Scheduler]
- [Github Action]
- [deno]

[Crawler]: https://en.wikipedia.org/wiki/Web_crawler
[Indexing]: https://en.wikipedia.org/wiki/Web_indexing
[Scraping]: https://en.wikipedia.org/wiki/Web_scraping
[Scheduler]: https://en.wikipedia.org/wiki/Scheduling_(computing)
[Github Action]: https://github.com/features/actions
[deno]: https://deno.land/