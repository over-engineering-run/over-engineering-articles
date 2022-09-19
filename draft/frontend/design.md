# 為什麼需要 design system - 實用至上主義前端 |【搜尋引擎製作錄】

隨著作為開發者的時間年復一年的過去，  
我最終認識到 **Design System** 的重要性，  
它不僅僅只是為了 **設計師** 而存在，  
實際上它跟 **軟體開發** 跟 **公司成本** 都有著很大的關係。

## 什麼是 Design System

**Design System** 是一組 **有明確的設計標準** 跟 **可被重複利用的元件**，
用來組合成任意應用程序。

> “Design systems are always evolving,
> and the way you share and encourage adoption of new iterations will evolve along the way as well.”  
> –Diana Mounter, design systems manager at GitHub  
> 關聯閱讀： [Design Systems, when and how much?][2]

## 為什麼需要 Design System

### 讓團隊能共享同樣的語言 => 降低溝通成本

**文字非常重要。**

精準的用字能讓團隊成員所有人都能準確的理解想傳達的話，  
它能夠節省掉大量的鬼打牆時間。

如果團隊常常浪費大量的時間再來回溝通，  
或許你需要好好反思這個概念。

### 共享思考模型 => 明確的目標

他能將你想做的東西或是概念文件化，  
並且可以白板說明你為何如此設計，

> “Design systems provide a convenient, centralized, and evolving map of a brand’s known product territories
> with directional pointers to help you explore new regions.”  
> —Chris Messina, tech evangelist and former developer experience lead at Uber

### 共享設計跟程式資源 => 節省開發成本

有系統的管理開發資源跟工具，  
會對整體開發流程跟體驗有非常大的效益。

> 我自己的體驗是，  
> 比起設計天花亂墜系統架構框架，  
> 提供能真正幫助到開發者們的資源或工具，  
> 更有機會讓專案成功落地而不會著火。

## 常見迷思

### Design System 是設計師的事，沒工程師什麼事

**Design System** 可以幫工程師：

- 減少開發時程
- 減少錯誤
- 減少無意義的討論
- 減少放飛自我的設計

a.k.a **提早下班**。

### 用現成元件庫兜一兜不就好了，為何要自找麻煩

你也可以用這些元件做出很屌的東西，  
如果不在意品牌經營的話。

![no-coherent](https://intercom.com/blog/wp-content/uploads/2017/04/Lego-aircraft-carrier.jpg)

如果你也同意 **品牌經營對於產品成敗至關重要**，  
那可能需要好好考慮一下。

軟體開發的原則：低耦合，高內聚，同樣適用於設計跟品牌，  
好的產品會讓用戶體驗到：首尾呼應的主題，風格，印象，  
以及沒有累贅跟重複的服務內容，每項功能都很明確。

![coherent](https://intercom.com/blog/wp-content/uploads/2017/04/Lego-Empire-system.jpg)

**不需要做出一艘軍艦，也可以把產品賣的嚇嚇叫。**

## 如何設計 Design System

### 設計原則

程式跟設計都必須基於同一套 規範，限制，原則。

> 規範的範例：  
> **Color**  
> Rule：顏色對比度必須大於 4.5:1  
> Constraint：使用的顏色總數量  
> Principle：每個顏色的使用必須要有意義

### 基於設計原則的程式參數

```bash
red
├── text
├── background
├── border
...
```

### 範疇

**Design System** 的範疇可以非常廣，  
從比較視覺設計層面囊跨到商業核心。

**好的設計甚至可以涉及到心理層面。**

- Typography 排印
- Components 元件
- Color 顏色
- Size / Spacing 大小 / 間距
- Layout 版型
- Interaction models 互動模型
- Content 內文
- Service Mechanics 服務機制

### UI / Pattern Library / 使用情境 / 文件

將所有產品中用到的 `button` `form` `modal` `image` 集中建檔，  
並設法整合他們，或是移除沒有用到的部分。

集中管理方便開發團隊可以清楚掌握手上有哪些可用資源。

## 規劃流程

1. 規劃需要什麼元件
   建立簡單的的清單幫助你快速識別專案需要哪些元件。
2. 在不同的介面下，試著整合並精簡化元件
3. 建立 Design Principle 跟 Style Guideline
4. 打造元件

### 元件

搜尋引擎部分至少需要：

- Combobox
- Result List
- Result

在接下來的文章中，會再一一介紹到這些實作上遇到的細節。

[2]: https://www.youtube.com/watch?v=Hx02SaL_IH0&ab_channel=Netlify
