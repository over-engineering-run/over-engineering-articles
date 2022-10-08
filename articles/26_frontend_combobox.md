# [Day 26] 如何設計搜尋欄位 - 實用至上主義前端 |【搜尋引擎製作錄】

[Github], [Over Engineering]

## 設計

輸入欄位是我第一個設計撞牆的部分，
光是其中的一個小部件就有很多眉角。

其中也沒有絕對正確的答案，
很多都有其適用情況跟意圖，
以下討論這次的設計跟理由。

### 讓搜尋欄位突出

搜尋欄位的樣式要能被用戶輕易識別。

這裡做了幾種方式來提高識別度，

#### 體現 box 的效果

- 用 輸入欄位 取代 一個連結 或是 按鈕，
  當搜尋功能在畫面上被收斂到只剩下一個按鈕時，
  比較難被用戶識別。

- 用顏色區分元件互動範圍。

- 輸入欄位寬度要足夠大，
  至少可以包含常用的搜尋關鍵字。

- 在 _focus_ 的時候要更加凸顯，
  這邊透過 `box-shadow` 增加視覺高度。

[關聯閱讀][search-should-be-a-box]

#### 配置 放大鏡 icon

![search-icon]

有些屬於大部分用戶都能識別其對應意義的 _icons_，
放大鏡就是其中之一，
光是附加在 `<input />` 附近就有辦法提供極高的辨別度。

有些網站為了節省空間，會選擇用 放大鏡 取代 _submit_ 按鈕，
不過這邊只採用強調的部分。

> 用簡單的 icon 取代複雜的 icon，
> 減少圖像細節可以減少視覺雜亂，
> 提供更好的識別功能。

[關聯閱讀][magnifying-glass-icon]

### 搜尋按鈕

提供按鈕可以幫助用戶識別搜尋功能要做的額外的步驟：**Submit 提交**。

- 為了預防客戶送出空的搜尋關鍵字，
  在搜尋關鍵字為空時不會顯示提交按鈕。

- 按鈕上顯示可以透過鍵入 <kbd>Enter</kbd> 來提交。
  也可以點擊提交。

- 手機因為可顯示空間的限制，文字顯示 `Submit` 用於表示提交。

### 功能強調

- 因為我們想強調這是搜尋引擎，
  將搜尋欄位配置在畫面接近正中間。

- 當用戶進入到主頁的時候，
  會自動 _focus_ 在搜尋欄位上。

- 當進入到搜尋結果頁面時，
  搜尋欄位會配置於 _header_ 常駐，
  讓提供用戶方便更改搜尋關鍵字。

### 保持簡單

- 大部分用戶會抗拒困難的操作，
  所以避免一開始就呈現進階搜尋的功能。

- 隱藏困難的部分，困難的工作由我們的魔法 (NLP) 來處理。

### 關鍵字推薦

對於大部分用戶來說，
可能光是輸入關鍵字就很困難了，
更何況要思考哪個關鍵字能夠解決自己的問題。

根據[統計][query-reformulation]，
有一半的用戶沒辦法在下第一次的關鍵字時，
就找到他們想要的答案。

透過推薦可以建議用戶可以輸入的關鍵字，
也能提供用戶參考。

### 搜尋紀錄

用戶極有可能會想要再度搜尋相同的問題，
紀錄用戶的搜尋紀錄會很有幫助。

## 實作

上述的規格，單獨都可以抽出來獨立講述，
但礙於篇幅，程式碼會擷取重點部分進行講述。

### 結構

首先，因為元件邏輯本身已經很複雜，
為了方便維護，
我個人會將邏輯部分透過 `custom hooks` 抽離。

```tsx
const Search = (props: Props) => {
  const form = useSearchBar();
  ...
}
```
[原始碼連結][source-1]

因為搜尋功能本身不與其他物件掛鉤，並常駐於整個網站。
其本身可以作為單獨的 `form` 處理，
透過 [Remix] 我們可以更輕鬆的處理 `form submit`。

```tsx
    <Form action="/search">
      <div {...form.getComboboxProps()}>
        <label {...form.getLabelProps()} className="sr-only">
          Search
        </label>

        <div>
          <Icon.Search />
        </div>

        <input
          {...form.getInputProps({ ref: form.ref })}
          name="q"
          type="search"
        />

        {form.canSubmit && (
          <button type="submit">
            <span>
              SUBMIT OR PRESS <kbd>↵</kbd>
            </span>
          </button>
        )}

        {form.transition.state === "submitting" && (
          <Icon.Loading />
        )}
      </div>

      <div {...form.getMenuProps()}>
        <ul>
          {form.options?.map((item, index) => (
            <li
              {...form.getItemProps({
                key: item.name,
                index,
                item,
              })}
            >
              <div>
                {item.type === "history" ? (
                  <Icon.History />
                ) : (
                  <Icon.Search />
                )}

                <span>{item.name}</span>
              </div>
            </li>
          ))}
        </ul>
      </div>
    </Form>
```
[原始碼連結][source-1]

### Downshift / Combobox

[downshift] 是專門用來處理 [combobox] 的套件，
有別於以往元件庫的作法沒有綁樣式，
只實作了 *WAI-ARI* 指定的規格。

> **headless component** 是個人比較推薦的元件方式，
> 我認為元件開發，元件邏輯比樣式更容易被重複利用，
> 透過只封裝元件邏輯，並讓樣式能夠根據使用情境高度客製化，
> 也能減少程式碼的打包量。

```tsx
function useSearchBar() {
  ...

  const items = query ? autoComplete.options : history.options;

  const props = useCombobox({
    id: useId(),
    items,
    initialInputValue: query,
    itemToString: (item) => item?.name || "",
    onInputValueChange: ({ inputValue }) => setQuery(inputValue?.trim() || ""),
    onStateChange: (state) => {
      if (state.type === useCombobox.stateChangeTypes.InputChange) {
        const query = state.inputValue?.trim();

        return query && autoComplete.search(query);
      }
    },
  });

  ...
}
```
[原始碼連結][source-3]

### Cancel Request

[Remix] 預設會幫忙 **取消沒用到的請求**，
所以我們**不需要**做任何 [debounce 或是 throttle][debouncing-throttling]，
而是真的打字就發 request。

```tsx
function useAutoComplete() {
  const fetcher = useFetcher<AutoCompleteResult>();

  function search(q: string) {
    const params = new URLSearchParams({
      q,
      max: String(5),
    });

    fetcher.load(`/api/auto-complete?${params}`);
  }
  ...
}
```
[原始碼連結][source-4]

### 搜尋歷史紀錄

我們不想將搜尋紀錄，記錄在 server，
將使用者的搜尋紀錄保留在 `localstorage`，
除了可以減輕 server 的負擔外，
也落實用戶個人資料的安全。

```tsx
function useHistory() {
  const [_options, setHistory] = useLocalStorage<History[]>(
    "search-history",
    [],
    {
      raw: false,
      serializer: JSON.stringify,
      deserializer: JSON.parse,
    }
  );
  const options = _options?.slice(0, 5) || [];

  options.sort((a, b) => b.created_at - a.created_at);

  function append(query: string) {
    setHistory([
      { type: "history", name: query, created_at: Date.now() },
      ...options,
    ]);
  }

  ...
}
```
[原始碼連結][source-5]

## 參考

- [magnifying-glass-icon]
- [search-should-be-a-box]
- [Remix]
- [downshift]
- [combobox]

[Github]: https://github.com/over-engineering-run
[Over Engineering]: https://over-engineering-frontend.fly.dev/

[magnifying-glass-icon]: https://www.nngroup.com/articles/magnifying-glass-icon/#:~:text=Recommendations%20for%20Designing%20with%20the%20Magnifying%2DGlass%20Icon

[search-should-be-a-box]: https://www.nngroup.com/articles/search-visible-and-simple/#:~:text=Search%20Should%20be%20a%20Box

[search-icon]: https://miro.medium.com/proxy/1*ZimH1QT0zKfzzgocMfpYOA.png

[query-reformulation]: https://www.nngroup.com/articles/search-visible-and-simple/#:~:text=Query%20Reformulation%3A%20Not

[source-1]: https://github.com/over-engineering-run/over-engineering-frontend/blob/e3bd9a7ba8ecfd42b2819a7fe9f241290ffb6f35/app/components/Search.tsx#L121

[source-2]: https://github.com/over-engineering-run/over-engineering-frontend/blob/e3bd9a7ba8ecfd42b2819a7fe9f241290ffb6f35/app/components/Search.tsx#L130

[source-3]: https://github.com/over-engineering-run/over-engineering-frontend/blob/e3bd9a7ba8ecfd42b2819a7fe9f241290ffb6f35/app/components/Search.tsx#L80

[source-4]: https://github.com/over-engineering-run/over-engineering-frontend/blob/e3bd9a7ba8ecfd42b2819a7fe9f241290ffb6f35/app/components/Search.tsx#L50

[source-5]: https://github.com/over-engineering-run/over-engineering-frontend/blob/e3bd9a7ba8ecfd42b2819a7fe9f241290ffb6f35/app/components/Search.tsx#L22

[Remix]: https://remix.run/
[downshift]: https://github.com/downshift-js/downshift
[combobox]: https://www.w3.org/WAI/ARIA/apg/patterns/combobox/

[debouncing-throttling]: https://css-tricks.com/debouncing-throttling-explained-examples/
