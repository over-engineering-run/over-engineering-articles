# 【】關於轉生爬蟲後的那檔子事

**因為太多細節處理，所以文章指擷取重要內容，請各位見諒!!!**

## 簡介 GitHub Action

GitHub Actions 讓我們可以簡單做出軟體流程自動化，
讓 Build, test, and deploy 直接在 GitHub 上進行管理。
除了上述，也可以製作 code reviews, 管理 branch, 還有 issue 追蹤等自動化工作。

這次我們要透過 GitHub Actions 製作 Scheduler，
在指定時間自動觸發 crawler，讓我們不用手動的去執行。

## Setup

在專案根目錄設置 `.github/workflows/`。

配置兩個檔案，分別是：
- `crawler-scheduler.yml`：負責處理自動排程
- `extract-articles.yml`：負責執行 crawler

## Extract Articles 擷取文章

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to run scrape'
        type: environment
        required: true
  workflow_call:
    inputs:
      environment:
        description: 'Environment to run scrape'
        type: environment
        required: true
```

這邊設置了兩個觸發方式，
- `workflow_dispatch`：會在 GitHub 上提供一個按鈕用於手動觸發，方便測試。
- `workflow_call`：讓其他的 workflow 能夠呼叫這個 workflow，類似於函式呼叫。

這兩個方式都需要拋入 `environment` 參數，用來指定是哪個環境需要執行 crawler，  
目前規劃只有 `staging` 跟 `production` 環境，  
在未來如果有擴充的可能，這邊也可以很方便進行調整。

詳細可見 [原始碼連結][extract-articles-on]

> 關於如何在 GitHub 建立環境，請參考 [這篇][create-env]

```yaml
jobs:
  execute:
    name: 🕷️ Execute
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    strategy:
      matrix:
        range:
          - { from: 0,    to: 200  }
          - { from: 200,  to: 400  }
          - { from: 400,  to: 600  }
          - { from: 600,  to: 800  }
          - { from: 800,  to: 1000 }
          - { from: 1000, to: 1200 }
          - { from: 1200, to: 1400 }
          - { from: 1400, to: 1600 }
          - { from: 1600, to: 1800 }
          - { from: 1800, to: 2000 }
          - { from: 2000, to: 2200 }
          - { from: 2200, to: 2400 }
          - { from: 2400, to: 2600 }
          - { from: 2600, to: 2800 }
          - { from: 2800, to: 2859 }
    steps:
      - name: 🚀 Execute
        run: |
          deno run --allow-all scraper/job.ts \
            --href="https://ithelp.ithome.com.tw/articles?tab=ironman" \
            --from="${{ matrix.range.from }}" \
            --to="${{ matrix.range.to }}"
```

*matrix strategies* 讓我們在同一個 job 中設置多個參數，並基於這些參數自動執行複數個 job。  
這邊透過這個方式指定每個 job 需要負責的頁數範圍。  
每個 job 是獨立的 process，平行執行且互不干擾。

詳細可見 [原始碼連結][extract-articles-job]

## Crawler Scheduler 排程

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'
```

排程類被歸類在 `schedule` 底下，
跟絕大多數的排程系統一樣，GitHub 也是採用 [POSIX cron syntax][posix-cron-syntax]，  
如果對這個不是很熟的話，可以用 [cron 大師][crontab-guru] 來幫助寫出正確時間。

詳細可見 [原始碼連結][crawler-scheduler-on]

```yaml
jobs:
  execute_staging:
    uses: ./.github/workflows/extract-articles.yml
    with:
      environment: staging

  execute_production:
    uses: ./.github/workflows/extract-articles.yml
    with:
      environment: production
```

分兩個環境到獨立的 job，透過拋參數的方式呼叫同一份 crawler 流程。

詳細可見 [原始碼連結][crawler-scheduler-job]

## Reference

- [如何建立 GitHub 環境][create-env]
- [POSIX cron syntax][posix-cron-syntax]
- [cron 大師][crontab-guru]

[create-env]: https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#creating-an-environment
[posix-cron-syntax]: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/crontab.html#tag_20_25_07
[crontab-guru]: https://crontab.guru/


[extract-articles-on]: https://github.com/over-engineering-run/over-engineering/blob/4e9a0fd519dff73cdb3d4a6cec19f461e4bfcf08/.github/workflows/extract-articles.yml#L3
[extract-articles-job]: https://github.com/over-engineering-run/over-engineering/blob/4e9a0fd519dff73cdb3d4a6cec19f461e4bfcf08/.github/workflows/extract-articles.yml#L17
[crawler-scheduler-on]: https://github.com/over-engineering-run/over-engineering/blob/4e9a0fd519dff73cdb3d4a6cec19f461e4bfcf08/.github/workflows/crawler-scheduler.yml#L3
[crawler-scheduler-job]: https://github.com/over-engineering-run/over-engineering/blob/4e9a0fd519dff73cdb3d4a6cec19f461e4bfcf08/.github/workflows/crawler-scheduler.yml#L9