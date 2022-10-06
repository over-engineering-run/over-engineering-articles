# [Day 20] Flask 實作 - 為搜尋引擎獻上後端！ |【搜尋引擎製作錄】

[Github], [Over Engineering]

**礙於篇幅緣故，過多細節的部分，會挑重點講述，如有疑問歡迎留言討論**

今天講述 Flask 實作後端 API 的內容，
實作的原始碼可以參考 [api.py]。


## Flask App
當初在開始寫 flask 時，官網內容有些太多，
所以就參考 stackoverflow "[using-flask-inside-class]" 這篇討論，
從一個簡單的 flask app 的 class wrapper 開始寫。

```python
class APIServer():

    def __init__(self, name, host="0.0.0.0", port=5000, debug=False):
        self.host = host
        self.port = port
        self.debug = debug
        self.app = Flask(name)

    def add_endpoint(self, endpoint=None, endpoint_name=None, handler=None, handler_params=None, req_methods=["GET"]):
        self.app.add_url_rule(
            endpoint,
            endpoint_name,
            EndpointAction(handler, handler_params),
            methods=req_methods
        )

    def run(self):
        self.app.run(debug=self.debug, port=self.port, host=self.host)
```


### add_endpoint

首先，class wrapper 包含一個 `add_endpoint` 的 method，
可以幫我們宣告 API 的路徑、方法、與 handler。

例如：我們昨天提到的 API
- **POST** `/docs/v1/index`
  ```python
  self.add_endpoint(
      endpoint="/docs/v1/index",
      endpoint_name="index_docs",
      handler=self.index,
      handler_params={"index": self.ms_docs_index},
      req_methods=["POST"]
  )
  ```
便可用此 method 在新增不同的 API 服務。

其中我們看到
- `endpoint` and `endpoint_name`
  API request route 的路徑。

- `req_methods`
  宣告 request 的 method，如：**GET** or **POST**，
  相同的 endpoint 我們也可以宣告不同的 `req_methods` 與 handler。

- `handler` and `handler_params`
  `handler` 為當接收到 request 時，要如何處理 request 並處理服務？

  這裡的 `handler` 皆為 function，
  而 `handler_params` 則為此 `handler` function 的傳入參數
  (注意並非 request 的 arguments )。

  我們會用 class `EndpointAction` wrap 好 `handler` 與 `handler_params`，
  以方便後續執行。

  ```python
  class EndpointAction():

      def __init__(self, action, action_params):
          self.action = action
          self.action_params = action_params

      def __call__(self):
          return self.action(self.action_params)
  ```

  這個 `EndpointAction` class 便如同工廠，
  透過 `handler_params`，我們可以傳入不同的 index (索引) 名稱，
  當我們在 instansitate `EndpointAction` 時，
  便相當於針對不同 index 的 handler 被製造出來。

這些 API endpoint 的新增可以參考 [api.py]，
都於 APIServer 的 `__init__` 中。


### run
APIServer class 中的這個 run method，
```python
def run(self):
    self.app.run(debug=self.debug, port=self.port, host=self.host)
```
其實就是當我們新增完所有 API endpoint 後，
開始執行 flask app 的 function。

在 debug mode 之下，
我們可以很簡單用剛才提到的 app wrapper，
instanciate 一個新的 APIServer instance，
之後直接執行其中的 run function 便可。

```python
api_server = APIServer(
    name="api",
    host=os.getenv("FLASK_HOST"),
    port=os.getenv("FLASK_PORT"),
    debug=True
)
api_server.run()
```

而 production 則是從 flask 官方網站的介紹，
選了一個蠻簡單的方法 [flask waitress]。

```python
from waitress import serve

api_server = APIServer(
    name="api",
    host=os.getenv("FLASK_HOST"),
    port=os.getenv("FLASK_PORT"),
    debug=False
)

serve(
    api_server.app,
    host=os.getenv("FLASK_HOST"),
    port=os.getenv("FLASK_PORT"),
)
```
把 flask app instance 傳入 waitress 的 serve function 中即可。


## Run a Flask API Server on Localhost
接下來我們說明一下，
要如何在本地端啟動及測試我們的 flask API backend server。

### Set Up
其實與 [Day 14] 中介紹的大同小異，也是完成以下兩個步驟的設定。

- **Set Up Script**
  在 backend 目錄中執行
  ```bash
  sh scripts/flask_api_setup.sh
  ```
  它會安裝所需要的 python package。

- **讀取環境變數**
  相同的，確認環境變數已經被正確的讀取。
  ```bash
  source .env
  ```

除此之外，如過要使用到 meilisearch 或 supabase 的相關 API
也要確定環境變數設定正確，並可被連接。

如：環境變數設定 meilisearch server 在本地端，
則記得在本地端啟動 meilisearch server。


### Start API Server
啟動 flask api server 的方法也相當簡易
```bash
python api.py --debug true
```


### Test with Curl or Jupyter Notebook

我也在 [testing directory] 中，
準備了簡單的 **測試環境** 與 **jupyter notebook** 供參考，
在本地端跑起 flask app 後，可以用 juypter notebook 測試。

除此之外，在 [api.py] 各個 endpoint 的 handler function 上，
我也有放上 curl command 註解，如：
```bash
curl -XGET "http://0.0.0.0:5000/docs/v1/search?q=api&page=0&limit=10"
```
只要更改 url 中的 host 與 port 即可用。


> 今天的內容比想像中的多，
> Meilisearch 的內容便留到明天一同講吧。


[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/
[api.py]: https://github.com/over-engineering-run/over-engineering/blob/v0.0.1/backend/api.py
[testing directory]: https://github.com/over-engineering-run/over-engineering/tree/v0.0.1/backend/testing
[using-flask-inside-class]: https://stackoverflow.com/questions/40460846/using-flask-inside-class
[flask waitress]: https://flask.palletsprojects.com/en/2.2.x/deploying/waitress/
[Day 14]: https://github.com/over-engineering-run/over-engineering-articles/blob/main/articles/14_data_processing_IV.md#environment-set-up
