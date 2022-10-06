# [Day 21] API server and Meilisearch - 為搜尋引擎獻上後端！ |【搜尋引擎製作錄】

[Github], [Over Engineering]

**礙於篇幅緣故，過多細節的部分，會挑重點講述，如有疑問歡迎留言討論**

昨天我們簡介如何使用 flask 實作 backend API server。
此 API server 所提供的服務，
皆是 **搜尋引擎** 與 **資料庫** 相關，
背後連接的也是我們在前面章節所提到過的 meilisearch 與 supabase。

今天我們針對與 meilisearch 連接的部分重點說明一下。


## Meilisearch
如何透過 python package 連接 meilisearh 的細節，
可以參考 [meilisearch-python] 與 [meilisearch API reference]。

### Meilisearch Client
首先，我們在 APIServer `__init__` 中，需要宣告 meilisearch client，
並且，我們接下來會以 **GET** `/docs/v1/search` 舉例。

```python
import meilisearch as ms

class APIServer():

    def __init__(self, name, host="0.0.0.0", port=5000, debug=False):

        # init meilisearch client
        url = os.getenv("MEILISEARCH_URL")
        docs_index = os.getenv("MEILISEARCH_DOCUMENTS_INDEX")
        keywords_index = os.getenv("MEILISEARCH_KEYWORDS_INDEX")

        self.ms_url = url
        self.ms_docs_index = docs_index
        self.ms_keywords_index = keywords_index
        self.ms_client = ms.Client(self.ms_url)

        # init API
        self.add_endpoint(
            endpoint="/docs/v1/search",
            endpoint_name="search_docs",
            handler=self.search_docs,
            handler_params={"index": self.ms_docs_index},
            req_methods=["GET"]
        )
```

### Request and Response
我們先看看 API 的 request 和 response。
我們若用 `curl` 測試，
```bash
curl -XGET "http://0.0.0.0:5000/docs/v1/search?q=api&page=0&limit=10"
```
得到的 response 格式為
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
        }
    ]
}
```

### Request Arguments Parsing
在 search handler function 中，我們先 parse request arguments。
其中，我們先 parse 並檢查 request arguments 中，
是否包含所有必要的 arguments: **"q"**, **"page"**, and **"limit"**。
```python
def search_docs(self, params: dict):

    # parse and check request
    req_args_key_set = set(request.args.keys())
    req_must_key_set = {'q', 'page', 'limit'}

    if (req_must_key_set - req_args_key_set) != set():
        self.logger.error(
            "Missing params %s in doc search request.",
            ", ".join(req_must_key_set - req_args_key_set)
        )
        return Response(status=400, headers={})

    query = request.args.get('q', type=str)
    page = request.args.get('page', type=int)
    limit = request.args.get('limit', type=int)
    hashtags = request.args.getlist('hashtags', type=str)
```
- **"q"**: 搜尋關鍵字
- **"page"**: 搜尋結果有時會超過限制，所以我們必須分頁呈現結果。此參數便是用以指定第幾頁。
- **"limit"**: 指定每頁的最多回傳結果數。
- **"hashtags"**: 這個參數允許前端傳入 hashtags，用以 filter 結果文章 (目前前端並沒有使用)。

### Meilisearch Python SDK Search Request
接著，我們要準備 meilisearch sdk search request。
```python
ms_request = {
    'offset': page * limit,
    'limit':  limit,
    'attributesToRetrieve': [
        'title',
        'href',
        'published_at_unix',
        'author_name',
        'author_href',
        'series_name',
        'series_href',
        'hashtags',
        'keywords',
        'reading_time'
    ],
    'attributesToHighlight': ['raw_hl_content'],
    'highlightPreTag': '<mark>',
    'highlightPostTag': '</mark>',
    'attributesToCrop': ['raw_hl_content:100'],
    'cropMarker': ''
}

raw_filter = []
if len(hashtags) > 0:
    for h_tag in hashtags:
        raw_filter.append(f"hashtags = {h_tag}")
ms_request['filter'] = ' AND '.join(raw_filter)
```
其中，`attributesToRetrieve` 代表回傳結果文章中要哪些 fields。
而其它與 highlight 和 snippets 相關的參數，在 [Day 18] 中也有介紹。

### Run Search
我們可以直接使用 meilisearch client 執行 search。
```python
ms_index = params.get('index', None)
if not ms_index:
    return Response(status=500, headers={})

raw_resp = self.ms_client.index(ms_index).search(
    query,
    opt_params=ms_request
)

if not raw_resp:
    self.logger.error("Failed to run search request on Meilisearch.")
    return Response(status=500, headers={})
```

### Search Response Parsing
在從 meilisearch client 獲得 search response 後，
我們需要從回傳的資訊中，擷取我們所需，
並 format 好 API response 的格式。
```python
resp = {
    'query': raw_resp['query'],
    'total': raw_resp['estimatedTotalHits'],
    'result': []
}
for i, raw_hit in enumerate(raw_resp['hits']):

    hit = {

        'position': i,
        'title':    raw_hit['title'],
        'link':     raw_hit['href'],
        'snippet':  raw_hit['_formatted']['raw_hl_content'],
        'lastmod':  raw_hit['published_at_unix'],

        'about_this_result': {

            'author': {
                'name': raw_hit['author_name'],
                'link': raw_hit['author_href']
            },
            'series': {
                'name': raw_hit['series_name'],
                'link': raw_hit['series_href']
            },

            "hashtags":     raw_hit['hashtags'],
            "keywords":     raw_hit['keywords'],
            "reading_time": raw_hit['reading_time']
        }
    }
    resp['result'].append(hit)

return Response(
    response=json.dumps(resp),
    status=200,
    headers={"Content-Type": "application/json"}
)
```

> 今天的內容好像有點長，
> 我們就把 supabase 的內容放到明天吧。


[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[api.py]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/backend/api.py
[meilisearch-python]: https://github.com/meilisearch/meilisearch-python
[meilisearch API reference]: https://docs.meilisearch.com/reference/api/overview.html#headers
[Day 18]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/18_search_engine_highlight_and_auto_complete.md
