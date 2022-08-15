# 【】關於轉生爬蟲後的那檔子事

**因為太多細節處理，所以文章指擷取重要內容，請各位見諒!!!**

## 環境設置

[deno] 在腳本輕量化實在是做的很好 (no `node_modules`)，環境設置也很容易，  
我們接下來就要用 [deno] 來處理爬蟲。

```bash
brew install deno
```

接下來確認 [deno] 是否正確安裝。

```bash
deno --version
deno 1.24.2 (release, aarch64-apple-darwin)
v8 10.4.132.20
typescript 4.7.4
```

這樣我們就準備好環境了。

> windows 可以自行前往 [deno] 進行查看設置方式。

## 主流程

我希望程式能夠接收 **指定的頁數範圍** 跟 **目標網址** 來進行爬蟲，  

**指定的頁數範圍** 的原因是：
我想要 _將平台的文章列表拆分至數個執行緒做平行處理_，  
平台的文章列表頁數有將近 3000 頁，如果一個一個跑可能要花上一天半，  
平行處理可以省下不少時間。

**目標網址** 是為了方便以後改動，  
平台有機會更改文章網址 (但理論上不應該頻繁改動網址，因為會影響自家的 SEO)，  
調整成參數就可以在不需要更動程式碼的情況作出處理。

```ts
// 根據指定的頁數範圍
for (let page = from; page <= to; page++) {
    // 生成該頁網址
    const page_href = url_string({ pathname: href, search: { page } });
    // 擷取該頁
    const document = await fetchDOM(page_href);
    // 根據文章列表的連結，接取對應連結的文章資訊。
    await extract(document, {
        // 將擷取出的資訊存入資料庫。
        user: insert(db, "users"),
        series: insert(db, "series"),
        article: insert(db, "articles"),
    });
    // 隨機冷卻 300 - 700 毫秒
    await delay(random(300, 700));
}
```
詳細可見 [原始碼連結][main-process]

> `insert` 部分我們會在後面介紹。

## `fetchDOM`

`DOMParser` 在網路上有非常多個版本，像是 [js-dom], [linke-dom]。  
不同的 `DOMParser` 著重的重點也不同，
此次使用的是 [deno-dom]，主要用在 _SSR_ 上。

```ts
const parseDOM = (() => {
  // Singleton，只需要一個 Parser
  const it = new DOMParser();

  return (source: string) => {
    // 生成 DOM node
    return it.parseFromString(source, "text/html");
  };
})();
```
詳細可見 [原始碼連結][parse-dom]

```ts
async function fetchDOM(href: string) {
  // 請求網址資料，並將 response 轉成 HTML 純文字 
  const source = await fetch(href).then((res) => res.text());
  if (!source) {
    throw new Error(`fetch ${href} response is empty`);
  }

  // 將 HTML 解析成 DOM node
  const document = parseDOM(source);
  if (!document) {
    throw new Error(`failed to parse source into dom`);
  }

  return document;
}
```
詳細可見 [原始碼連結][fetch-dom]

解析完後的 `document` 就幾乎跟在瀏覽器上用的 `document` 一樣，  
可以透過 `querySelector`, `querySelectorAll` 找到我們需要的 DOM Node。

> 相對於 純字串操作 (像是 Regex)，  
> 如果只需要該頁面的一筆資料，使用 Regex 效率會比較好，  
> 但如果需要針對該頁面多個部分進行處理，  
> 轉換成 DOM Node，比較方便後續做複雜的程式處理。  

## 資料擷取

這邊會使用到一些 _Functional Programming_ 的寫法，  
_Functional Programming_ 很適合應用在這類資料操作的案例，  
整個資料像是被丟進了一個生產線一樣，  
很容易知道發生了什麼事。

`InsertProxy` 是 _Dependency Injection_，  
不直接寫死在邏輯內，而是透過呼叫方決定要 `insert` 到哪個 _database_，  
方便以後要切換 _database_ 時，不用動到底層邏輯。

```ts
type InsertProxy = {
  user: (user: Partial<User>) => Promise<unknown>;
  series: (series: Partial<Series>) => Promise<unknown>;
  article: (article: Partial<Article>) => Promise<unknown>;
};
export const extract = (document: HTMLDocument, insert: InsertProxy) =>
  all(
    DOM(document)
      // 在 document 上，根據 css selector 找到所有文章連結
      .selectAll(".qa-list__title-link")
      // 取得文章連結的 href
      .map(getAttribute("href"))
      .map((href) => 
        // 根據 href 取得該文章的 document
        fetchDOM(href).then(
          // 擷取文章資訊，分別要擷取 article (文章內容), user (作者), series (文章系列)
          R.applySpec({
            article: extractArticle(href),
            user: extractUser,
            series: extractSeries,
          })
        )
      )
  )
    .then(
      R.map(async (information) => {
        // 將擷取到的資訊存進指定 database
        await insert.user(information.user);
        await insert.series(information.series);
        await insert.article({
        ...information.article,
        // 透過 作者連結 關聯到 作者資料
        author_href: information.user.href,
        // 透過 系列連結 關聯到 系列資料
        series_href: information.series.href,
        });
      })
    )
    .then(all);
```
詳細可見 [原始碼連結][extract]


透過 _CSS Selector_ 擷取文章資料。  
受益於 [ramda] 我們可以讓程式碼關注於，**從指定的 _CSS Selector_ 擷取 _哪項資料_**。

```ts
const extractArticle = (href: string) =>
  R.applySpec({
    href: R.always(href),
    genre: selectText(".qa-header .group__badge"),
    tags: selectAllText(".qa-header__tagGroup .tag"),
    title: selectText(".qa-header .qa-header__title"),
    publish_at: selectText(".qa-header .qa-header__info-time"),
    content: selectHTML(".qa-markdown .markdown"),
    series_no: selectText(
      ".qa-header .ir-article__topic > .ir-article__topic-count"
    ),
  });
```
詳細可見 [原始碼連結][extract-article]

```ts
const extractSeries = R.applySpec({
  href: selectHref(".qa-header .ir-article__topic > a"),
  name: selectText(".qa-header .ir-article__topic > a"),
});
```
詳細可見 [原始碼連結][extract-series]

```ts
const extractUser = R.applySpec({
  name: selectText(
    ".ir-article-info .ir-article-info__content .ir-article-info__name"
  ),
  href: selectHref(
    ".ir-article-info .ir-article-info__content .ir-article-info__name"
  ),
});
```
詳細可見 [原始碼連結][extract-user]

## Database

> 記得使用 [dotenv] 處理像是 api key 之類的資訊。
> ```ts
> config({ safe: true, export: true });
> ```

此次我們用的 _database_ 是 [supabase]，是最近發展的一種服務類型 DaaS 服務，  
他的好處是幫我們處理 _database infrastructure_ 的相關問題，  
方便開發者將時間花在應用邏輯上。

```ts
const db = createClient(
  // Supabase API URL 
  Deno.env.get("SUPABASE_URL")!,
  // Supabase API KEY 
  Deno.env.get("SUPABASE_API_KEY")!
);

const insert =
  (db: SupabaseClient, table: string) => async (record: Partial<unknown>) => {
    const { data, error } = await db.from(table).upsert(record);

    if (error) {
      throw error;
    }
    return data;
  };

...

    await extract(document, {
        // 將 user 資訊，存入 users table 
        user: insert(db, "users"),
        // 將 series 資訊，存入 series table 
        series: insert(db, "series"),
        // 將 article 資訊，存入 articles table 
        article: insert(db, "articles"),
    });
```
詳細可見 [原始碼連結][insert-db]

## 執行

試打看看，應該會把資料打到雲端服務上。

```bash
deno run --allow-all job.ts \
    --href="https://ithelp.ithome.com.tw/articles?tab=ironman" \
    --from=<開始頁數> \
    --to=<結束頁數>
```

## Reference

- [supabase]
- [ramda]
- [deno-dom]
- [linke-dom]
- [js-dom]


[supabase]: https://supabase.com/
[ramda]: https://ramdajs.com/
[deno-dom]: [https://deno.land/x/deno_dom@v0.1.33-alpha
[linke-dom]: https://github.com/WebReflection/linkedom
[js-dom]: https://github.com/jsdom/jsdom
[dotenv]: https://github.com/motdotla/dotenv

[main-process]: https://github.com/over-engineering-run/over-engineering/blob/8b3d62f485c9d4db18de9ef5ec1c1660feb06161/crawler/job.ts#L34
[fetch-dom]: https://github.com/over-engineering-run/over-engineering/blob/8b3d62f485c9d4db18de9ef5ec1c1660feb06161/crawler/lib.ts#L23
[parse-dom]: https://github.com/over-engineering-run/over-engineering/blob/8b3d62f485c9d4db18de9ef5ec1c1660feb06161/crawler/lib.ts#L16
[extract]: https://github.com/over-engineering-run/over-engineering/blob/8b3d62f485c9d4db18de9ef5ec1c1660feb06161/crawler/lib.ts#L123
[extract-article]: https://github.com/over-engineering-run/over-engineering/blob/8b3d62f485c9d4db18de9ef5ec1c1660feb06161/crawler/lib.ts#L83
[extract-series]: https://github.com/over-engineering-run/over-engineering/blob/8b3d62f485c9d4db18de9ef5ec1c1660feb06161/crawler/lib.ts#L100
[extract-user]: https://github.com/over-engineering-run/over-engineering/blob/8b3d62f485c9d4db18de9ef5ec1c1660feb06161/crawler/lib.ts#L109
[insert-db]: https://github.com/over-engineering-run/over-engineering/blob/8b3d62f485c9d4db18de9ef5ec1c1660feb06161/crawler/job.ts#L12