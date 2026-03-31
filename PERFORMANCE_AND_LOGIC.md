# 效能與邏輯問題分析

以下為目前專案中較重要的效能與邏輯問題，以及具體改善建議。

---

## 一、效能問題

### 1. 日曆頁每次進入都重載全月資料

**現象**：切換到「日曆」Tab 時，`MyCalendarPage` 會重新建立（因主頁用 `_pages[now]` 只掛載當前頁），`initState` 再次執行 `getData()`，又呼叫 `setFirstDate()` → `setAllMonthData()` → `setNowMonth()`。

**影響**：每次進日曆都會對 DB 做「1 次 getFirstTransactionDate + 1 次 getAll + N 次 getMonth」，資料多或月份範圍大時會明顯變慢。

**建議**：
- 主頁改用 `IndexedStack` 保留四個頁面實例，切換時不 dispose，日曆只載入一次（或改為「進入日曆時若已有該月快取就不重載」）。
- 或將「全月彙總資料」提升到 `ExpenseProvider`，由 App 啟動／登入時載入一次，日曆頁只讀取 Provider 內快取。

---

### 2. setAllMonthData 重複查詢與多餘的 getAll()

**現象**：`setAllMonthData()` 先執行 `await _helper.getAll()` 把全部交易載入，接著又用 `for (i=0; i<=total; i++)` 對每個月份呼叫 `await _helper.getMonth(nowMonth)`。

**影響**：
- 全表資料載入兩次（getAll 一次，各月 getMonth 再加總）。
- 迴圈內多次 await，若月份多會產生大量 DB 查詢。

**建議**：
- 若已決定「按月份組裝」，就移除 `getAll()`，只依 `_firstDate` 到當月用 `getMonth(nowMonth)` 逐月查詢。
- 或反過來：只做一次 `getAll()`，在記憶體中依 `transaction.date` 的 year/month 分組，組出各月 `List<Day>`，再寫入 `_monthData`，避免 N 次 getMonth。

---

### 3. 首頁列表「依分類」時 getAllTags 被重複計算

**現象**：`home_page` 的 `ListView.builder` 在 `isSort == true` 時，`itemCount` 為 `expense_data.nowData!.getAllTags.length`，`itemBuilder` 裡又用 `expense_data.nowData!.getAllTags[index]`。`Day.getAllTags` 會複製 list、排序、再遍歷去重。

**影響**：若有 T 個 tag，build 時會呼叫約 T 次 `getAllTags`，每次 O(items.length)，列表較長時會多出不必要的 CPU 開銷。

**建議**：在 `build` 內或 state 中只算一次，例如：
`final tags = expense_data.nowData!.getAllTags;`
然後 `itemCount: tags.length`、`tagName: tags[index]`，避免在 itemBuilder 內重複呼叫。

---

### 4. 日曆格線在 itemBuilder 內重複 firstWhere

**現象**：`calendar_page` 的月曆格 `itemBuilder` 中，對每個格子可能執行：
`expenseData.monthData.firstWhere((x) => ...)` 與 `month.$2.firstWhere((x) => ...)`。

**影響**：格數約 35～42，每個格子兩次線性搜尋，且 `monthData` / `$2` 在該頁面內不變，重複計算。

**建議**：在 `build` 開始時依 `expenseData.monthData` 與當前 `now` 先算出「當前月份的 `List<Day>`」（或 Map  date -> Day），itemBuilder 內用 `index` 對應到日期後用 O(1) 查表，避免在 builder 內重複 firstWhere。

---

## 二、邏輯問題

### 1. 月份迴圈邊界與 DateTime 建構

**現象**：`setAllMonthData` 內使用 `DateTime(_firstDate.year, _firstDate.month + i, ...)`。Dart 會自動處理 month 溢位（例如 13 月變次年 1 月），因此目前多數情況是正確的，但若未來改為 `DateTime.utc` 或不同建構方式，需注意 month 範圍。

**建議**：可改為明確換年，可讀性較好且避免依賴隱式溢位：
```
dart
int year = _firstDate.year;
int month = _firstDate.month + i;
while (month > 12) { month -= 12; year++; }
DateTime nowMonth = DateTime(year, month, 1);
```

---

### 2. 日曆頁 firstWhere 未防錯

**現象**：`getMonthTotalIncome` / `getMonthTotalExpense` 有先判斷 `monthData.isEmpty`，但月曆格線的 itemBuilder 內直接：
`expenseData.monthData.firstWhere((x) => (x.$1.year == time.year && x.$1.month == time.month))`
以及
`month.$2.firstWhere((x) => (x.date.day == time.day))`（依你實際比對欄位）。

**影響**：若該月尚未載入、或該日沒有資料，會拋出 StateError，導致整頁崩潰。

**建議**：
- 使用 `firstWhere(..., orElse: () => ...)` 提供預設，或
- 用 `cast.firstWhereOrNull`（需 import collection）再判斷 null，沒有則顯示預設格（例如灰色、0）。

---

### 3. 刪除交易依「名稱+金額+日期+類型」可能刪錯筆

**現象**：`db_helper.delete` 用 `name = ? AND amount = ? AND date = ? AND type = ?` 刪除。若同一天有兩筆同名、同金額、同類型的紀錄，會一次刪掉多筆或與預期不符。

**建議**：若該筆交易已從 DB 讀出過，應帶有 `id`。刪除改為 `where: 'id = ?', whereArgs: [item.id]`；若 `id == null` 再 fallback 到現有條件（並在 UI 上盡量避免產生無 id 的刪除）。

---

### 4. add 後未取得並回傳新 id

**現象**：`ExpenseProvider.add()` 呼叫 `_helper.insert(item)`，insert 回傳新 row id，但沒有把 id 寫回 `TransactionItem`。若之後用這筆做刪除，item.id 仍為 null，只能依 name/amount/date/type 刪除，容易與「刪除邏輯改為依 id」衝突。

**建議**：insert 後用回傳的 id 建立新的 `TransactionItem(id: newId, ...)` 或讓 `TransactionItem` 支援 `copyWith(id: newId)`，後續刪除一律用 id。

---

### 5. setFirstDate 未 notifyListeners

**現象**：`setFirstDate()` 只更新 `_firstDate`，沒有呼叫 `notifyListeners()`。若日曆頁或其它 UI 依 `expenseProvider.firstDate` 顯示（例如可切換的月份範圍），可能不會更新。

**建議**：在 `setFirstDate()` 結尾加上 `notifyListeners();`（若該方法為 async，在 await 之後、方法結束前呼叫）。

---

### 6. countTotalCost 宣告為 Future 但無非同步邏輯

**現象**：`countTotalCost()` 內沒有 await，卻宣告為 `Future<void>`，容易讓人誤以為需要 await，且多餘的 Future 沒有實質好處。

**建議**：改為 `void countTotalCost()`，呼叫端維持 `countTotalCost();` 即可。

---

## 三、小結與優先順序

| 優先級 | 項目 | 類型 |
|--------|------|------|
| 高 | 刪除改依 id、add 後回寫 id | 邏輯／正確性 |
| 高 | 日曆 firstWhere 加 orElse / 防錯 | 邏輯／穩定性 |
| 高 | setAllMonthData 移除多餘 getAll 或改為只做一次查詢 | 效能 |
| 中 | 首頁「分類」模式快取 getAllTags | 效能 |
| 中 | setFirstDate 後 notifyListeners | 邏輯 |
| 中 | 日曆用 IndexedStack 或快取避免每次重載 | 效能 |
| 低 | countTotalCost 改為 void | 程式品質 |
| 低 | 日曆格線預先算好「當月 Day 表」避免 itemBuilder 內 firstWhere | 效能 |

先處理「刪除／新增 id」與「日曆 firstWhere 防錯」，再調整 setAllMonthData 與日曆載入策略，可同時改善正確性與體感效能。
