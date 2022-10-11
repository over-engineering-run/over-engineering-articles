# [Day 27] 如何設計搜尋結果清單 - 實用至上主義前端 |【搜尋引擎製作錄】

[Github], [Over Engineering]

## 版型設計

這邊的設計確實讓人頭痛，
作為搜尋引擎，你無法肯定用戶送出搜尋之後，回傳的資料集大小。
假設有大量的資料結果，
那勢必是要做 [pagination] 來減少單次的傳輸量。

但 [pagination] 在手機上的操作並不友好，
在研究 [google] 的結果頁後發現，
他們是直接做了兩個版本 Mobile 跟 Desktop，且並非透過 RWD 處理，
在 Desktop 是傳統的 [pagination] 實作，
在 Mobile 是 Infinite Scroll 無限滑動清單。

在研究過一些有大資料集的平台後，
最終我決定實作 Infinite Scroll 試圖用 RWD 處理這兩種版型，
雖然這樣會增加工程難度，
但希望可以給予用戶較好的體驗。

## Remix Loader

[Remix][remix] 處理 Server Side Render 的資料會透過 [loader][loader] 來處理，
像是專門給這個頁面的 API 的感覺，
你可以在這邊處理 API Server Request 跟 Response，
而前端可以直接拿處理後的資料。

```typescript
export const loader: LoaderFunction = ({ request }) => {
  const url = new URL(request.url);

  const q = url.searchParams.get("q");
  if (!q) return redirectBack(request, { fallback: "/" });

  const _page = url.searchParams.get("page");
  const page = _page ? Number(_page) : 0;

  const _limit = url.searchParams.get("limit");
  const limit = _limit ? Number(_limit) : COUNT_PER_PAGE;

  return search({ q, page, limit }).then(json);
};

...

interface Data {
  query: string;
  result: SearchResult[];
  total: number;
}
const Page = () => {
  const data = useLoaderData<Data>();

  return (
    <div className="flex flex-1 flex-col">
      {/* Number of results found */}
      <p className="my-4 px-4 lg:ml-44 lg:px-0">About {data.total} results</p>

      {/* List of Search Results */}
      <div className="flex-1" key={data.query}>
        <SearchResults {...data} />
      </div>
    </div>
  );
};
```

以上適用於大部分使用情境，
但這次的情境 (aka. Infinite Scroll) 需要實現動態加載，
這時我們還需要另一個 API [useFetcher][usefetcher]。

> **NOTICE**
> 注意到我用了 `key`，
> 如果 `key` 跟前次渲染比對不相同時會 rerender 那個元件，
> 包含重置元件狀態，像是 `useState`，
> 如果你之前是透過 `useEffect` 來重置元件狀態的話，
> [建議你改採用這個方式][resetting]。

## useFetcher

[useFetcher][usefetcher] 可以幫助我們重發請求，
且他幫我們實作 browser level 的 request cancellation，
不僅是減少我們需要轉寫的程式碼量，
也大幅降低了 server 的 loading。

```typescript
type State = {
  page: number;
  results: SearchResult[];
};
function SearchResults(data: Data) {
  const [{ page, results }, setNextPage] = useState<State>({
    page: 0,
    results: data.result,
  });

  const fetcher = useFetcher<Data>();
  useEffect(() => {
    if (!fetcher.data?.result) return;

    const results = fetcher.data.result;
    setNextPage((state) => ({
      page: state.page + 1,
      results: [...state.results, ...results],
    }));
  }, [fetcher.data?.result, setNextPage]);

  function loadNextPage() {
    const params = new URLSearchParams({
      page: String(page),
      limit: String(COUNT_PER_PAGE),
      q: String(data.query),
    });

    fetcher.load(`/search?${params}`);
  }
...
```

## Infinite Scroll + Virtual List

實際上，Infinite Scroll 跟 Virtual List 是兩個不同的概念。

Infinite Scroll 是指元件在用戶下滑時會動態產生新的物件，
使用戶有好像永遠都滑不到底的錯覺，
動態產生可能是透過 API Request 或是 程式演算 的結果，
此類也會在心理上給予用戶反饋感，
彷彿抽獎一樣，期待接下來會跑出什麼東西。

Virtual List 則是指畫面上的元件並沒有感覺起來這麼多，
透過重複利用超出畫面的元件，
來減少需要生成的物件數量，
結果就是需要的記憶體量大幅減少，
用戶不會因為程式效能影響到用戶體驗。

而這兩個常常會結合在一起使用，
因為 Infinite Scroll 會不斷地產生新的物件，
這時透過 Virtual List 可以固定需要產生的記憶體量，
但並不是絕對要配在一起用，端看你的使用情境。

```typescript
  ...
  const itemSize = 236;
  const margin = 20;

  const hasNextPage = results.length < data.total;

  const isNextPageLoading = fetcher.state === "loading";

  // If there are more items to be loaded then add an extra row to hold a loading indicator.
  const itemCount = hasNextPage ? results.length + 1 : results.length;

  // Only load 1 page of items at a time.
  // Pass an empty callback to InfiniteLoader in case it asks us to load more than once.
  const loadMoreItems = isNextPageLoading ? noop : loadNextPage;

  // Every row is loaded except for our loading indicator row.
  const isItemLoaded = (index: number) =>
    !hasNextPage || index < results.length;

  return (
    <AutoSizer>
      {(size) => (
        <InfiniteLoader
          isItemLoaded={isItemLoaded}
          itemCount={itemCount}
          loadMoreItems={loadMoreItems}
        >
          {({ onItemsRendered, ref }) => (
            <List
              {...size}
              itemCount={itemCount}
              itemSize={itemSize + 2 * margin}
              onItemsRendered={onItemsRendered}
              ref={ref}
            >
              {({ index, style }) =>
                !isItemLoaded(index) ? (
                  <div
                    className={clsx(
                      "px-4 lg:ml-44 lg:max-w-screen-md lg:px-0",
                      "flex items-center justify-center"
                    )}
                    style={{
                      ...style,
                      marginTop: margin,
                      marginBottom: margin,
                    }}
                  >
                    <div className="w-32">
                      <Icon.Loading />
                    </div>
                  </div>
                ) : (
                  <Result
                    className="px-4 lg:ml-44 lg:max-w-screen-md lg:px-0"
                    style={{
                      ...style,
                      marginTop: margin,
                      marginBottom: margin,
                    }}
                    {...applySpec<ResultProps>({
                      series: {
                        name: path(["about_this_result", "series", "name"]),
                        href: path(["about_this_result", "series", "link"]),
                      },
                      author: {
                        name: path(["about_this_result", "author", "name"]),
                        href: path(["about_this_result", "author", "link"]),
                      },
                      tags: path(["about_this_result", "hashtags"]),
                      href: path(["link"]),
                      title: path(["title"]),
                      lastmod: pipe(
                        path(["lastmod"]),
                        (value) => {
                          assert.number(value);
                          return value;
                        },
                        multiply(1000),
                        datefns.toDate,
                        (date) => datefns.format(date, "dd MMM yyyy")
                      ),
                      snippet: path(["snippet"]),
                      reading_time: path(["about_this_result", "reading_time"]),
                    })(results[index])}
                  />
                )
              }
            </List>
          )}
        </InfiniteLoader>
      )}
    </AutoSizer>
  );
}
```

[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/

[google]: https://google.com
[nextjs]: https://nextjs.org/
[remix]: https://remix.run/
[loader]: https://remix.run/docs/en/v1/guides/data-loading
[usefetcher]: https://remix.run/docs/en/v1/api/remix#usefetcher
[pagination]: https://en.wikipedia.org/wiki/Pagination
[resetting]: https://beta.reactjs.org/learn/you-might-not-need-an-effect#resetting-all-state-when-a-prop-changes
