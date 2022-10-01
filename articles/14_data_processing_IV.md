# [Day 14] Pipeline Runner - 果然我的自然語言處理搞錯了。|【搜尋引擎製作錄】

[Github], [Over Engineering]

**礙於篇幅緣故，過多細節的部分，會挑重點講述，如有疑問歡迎留言討論**

今天會總結一下資料前處理的部分，
程式碼的部分請參考 [nlp code]。

我們在前幾篇介紹了，
**Pipeline** 及其中各個階段的一些概念，
今天，我們要介紹如何將之前所介紹的 Pipeline 串成實作。


## Environment Set Up
開始之前，我們有兩個步驟要做，將環境事先設定好

- **Set Up Script** ([set up script])
  - 在 nlp 目錄中執行以下指令，會透過腳本安裝所需要的 python packages
    ```bash
    sh ./scripts/nlp_update.sh
    ```

- **讀取環境變數**
  - 直接複製 `.env.example` 為 `.env` 應該就可以在本地端使用了
  - 唯一需要更改的環境變數是 supabase 的 url 跟 api key，
    創建完 project 後，[supabase api key] 得介紹中寫得相當清楚，
    非常容易取得。
  - 透過執行以下指令可以一次性的讀取環境變數
    ```bash
    source .env
    ```
    個人是用 [autoenv] 自動讀取，避免每次執行。


## Pipeline Runner
首先，[pipeline runner] 是整個 nlp pipeline 部分程式碼的進入點，
它會根據不同參數，執行整個 pipeline。
執行 pipeline 的方式可以參考或直接執行此 腳本 (script) [pipeline script]。

### Config and Arguments
我們將許多 **資源檔**、**模型** (model) 名稱 等，
放入到 [config file] 內，
而其它像是 `batch_size` 或是 `flask_url` 等，
則加入 [pipeline runner arguments] 的`參數` (argument) 中。

這不禁會讓人思考兩者之間的差異到底在哪？
其實選則到底是要將一個變數放入 [config file] 或是`參數`，
考慮到的是後續，當我們要將這段程式碼透過 `腳本` (script)，
甚至用 `cron` 週期性的去執行時，
哪些變數是有可能需要根據外在環境作出調整的？

像是 資源檔 基本上不會因為外在環境而改變，
若是要換資源檔，則 pipeline 的內部邏輯並會因此作出更動。
反觀，`flask_url` 則可能因為 `後端` 的伺服器架設位址更動而需要改變。

還有一種情況是，我們會想要在相同的程式架構下，
測試不同的參數會有得到不同好壞的成效。
例如：目前我們並沒有要測試不同的模型，所以模型被放在 [config file]，
若未來我們要比較不同模型所得到的，並可以將模型名稱移到 `參數` 中。

### Multiprocessing (多行程執行)
由於前處理中，`pipeline` 的有些部分執行的速度較慢，
且我們在處理各個文章時，
文章被執行的順序並不會影響最終執行所產出的結果，
換而言之，文章與文章之間沒有執行的相依性，
因此，這種情況如果環境資源允許，非常適合 `multiprocessing`。

這個部分，我們用到的方法是
**將輸入資料根據所需，平均切分成 N 等份，讓他們可以同時被執行**
可以沿著 [pipeline multiprocessing] 往下看。

切分輸入資料主要分為兩步驟，
例如：我們有 1000 筆輸入文章，且有 3 個 CPU cores，
- 將 1000 筆輸入切為 3 等分
    - `[(0, 334), (334, 667), (667, 1000)]`
    - 這一步主要是使每個 process 分到的總處理量平均
    - 可以參考 [pipeline] 中的 `split_by_segment_n`

- 將每一等分再進一步切為固定大小的資料量，
  如 `batch_size` = 100 為例
    - (0, 334) 被進一步被切為 [(0, 100), (100, 200), (200, 334)]
    - 這次主要是控制 process 在分次執行時，每次執行的大小
    - 可以參考 [pipeline] 中的 `split_by_segment_size`

切分完後，執行部分就相對簡單，
只是根據切分的資料來開 processes 去執行。
```python
# start nlp pipeline with multiprocessing
with Pool(processes=processes_n) as pool:

    for process_i in range(processes_n):

        logging.info(
            "starting %d / %d process for nlp pipeline",
            process_i,
            processes_n
        )

        pipeline_params = {
            "loglevel":           logging.INFO,
            "process_i":          process_i,
            "api_server_url":     api_server_url,
            "backlog_index_list": parallel_backlog_index_list[process_i]
        }

        pool.apply_async(
            func=pipeline.pipeline,
            args=[pipeline_config, pipeline_params]
        )

    pool.close()
    pool.join()
```


### Pipeline
最後，在每個 process 上，
每篇文章經過執行 [nlp pipeline] 後，會得到輸出結果，
這個部分與之前 `jupyter notebook` 中所看到的大致相同。

接著，除了將資料處理結果輸出成 `json` 外 (參考 [dump output])，
我們也會根據後續需求，將資料進一步加工成需要的格式，
並更新到 **資料庫** ([update DB]) 或是 **搜尋引擎** ([update search engine]) 中，
至於如何選擇哪些更新到搜尋引擎哪些是資料庫，
這部分就要根據需求，我們在後面章節也會再次提到。


**資料處理** 與 **NLP** 的章節就到這裡結束了，
這次因爲時間關係，許多的資料處理都做得相當簡單，
原本想要補充描述一些想嘗試的處理，
及可能可以提升資料輸出品質的方法，
但最後決定改到最後，等 **搜尋引擎** 及 **後端** 的文章完成後，
再視篇幅看要補充多少。

明天就準備進入搜尋引擎的部分，
在開始前，我們會花一天寫一個簡單的 `zsh plugin`，
以利我們後續在 terminal 測試搜尋引擎。


[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[nlp code]: https://github.com/over-engineering-run/over-engineering/tree/v0.0.1/nlp
[set up script]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/scripts/nlp_setup.sh
[pipeline runner]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/pipeline_runner.py
[pipeline script]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/scripts/nlp_run.sh
[config file]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/config/pipeline.yaml
[pipeline runner arguments]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/pipeline_runner.py#L12
[multiprocessing]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/pipeline_runner.py#L95
[parallel]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/src/parallel.py#L67
[pipeline multiprocessing]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/pipeline_runner.py#L95
[nlp pipeline]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/src/pipeline.py#L194_L239
[dump output]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/src/pipeline.py#L241_L252
[update DB]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/src/pipeline.py#L254_L261
[update search engine]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/nlp/src/pipeline.py#L263_L280
[supabase api key]: https://supabase.com/docs/guides/api
[autoenv]: https://github.com/hyperupcall/autoenv
