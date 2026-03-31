# 代碼優化建議清單

本文件列出記帳 App (exp02) 各模組的可優化項目，供後續重構參考。

---

## 一、main.dart（應用入口與主框架）

| 項目 | 說明 | 優先級 |
|------|------|--------|
| 清理註解 | 移除過期 TODO、本地路徑註解（如 CoreSimulator 路徑） | 高 |
| 底部導航抽成元件 | 四個 Tab 結構重複，可抽成 `BottomNavItem` + 迴圈，減少重複碼 | 中 |
| 頁面列表型別 | `final List _pages` 改為 `final List<Widget> _pages`，並考慮 `const` | 低 |
| 頁面狀態保留 | 切換 Tab 時整頁重建；可改用 `IndexedStack` 保留各頁狀態、避免重載資料 | 中 |
| 導航索引常數 | 0,1,2,3 改為具名常數（如 `_tabHome`）或 enum，避免魔術數字 | 低 |

---

## 二、database/expense_provider.dart（支出狀態管理）

| 項目 | 說明 | 優先級 |
|------|------|--------|
| countTotalCost 型別 | 無 async 邏輯，改為 `void countTotalCost()` 即可 | 低 |
| add/remove 後更新範圍 | 目前呼叫 `setDayData(item.date)` 會重算當日；若只改單日可只更新 `_nowData` 與 `_totalCost`，減少重複查 DB | 中 |
| 錯誤處理 | `catch (e)` 僅 `print`，建議改為 `debugPrint` 或日誌套件，並區分可恢復/不可恢復錯誤 | 中 |
| setAllMonthData 錯誤訊息 | `print('error of tmp2')` 語意不清，改為明確描述（例如「當月無資料」）或移除 | 低 |
| 月份迴圈邊界 | `DateTime(_firstDate.year, _firstDate.month + i)` 在 month+1 超過 12 時需用 `DateTime.utc` 或手動換年，避免潛在月份溢位 | 高 |

---

## 三、database/db_helper.dart（SQLite 資料庫）

| 項目 | 說明 | 優先級 |
|------|------|--------|
| 刪除條件改用 id | 目前用 name+amount+date+type 刪除，若有重複資料可能刪錯筆；有 id 時應以 `id` 刪除 | 高 |
| 查詢方式一致 | getDay 用 `date LIKE ?`；若儲存為 ISO 字串，可考慮 `date >= ? AND date < ?` 範圍查詢，避免 LIKE 與索引問題 | 中 |
| 資料庫版本與遷移 | 若未來要改 schema，需在 `onUpgrade` 做遷移，並提高 version | 低 |
| getAll 效能 | 資料量大時 `getAll()` 一次載入全部；若有分頁或按月份載入，可改為分批查詢 | 低 |

---

## 四、models/transaction.dart（資料模型）

| 項目 | 說明 | 優先級 |
|------|------|--------|
| type 改為 enum | 用 enum（如 `TransactionType.income / expense`）取代字串 "income"/"expense"，避免拼字錯誤 | 中 |
| 型別安全 | tags 目前為 String；若需多標籤可考慮 `List<String>` 並在 toMap/fromMap 做 join/split | 低 |
| Day.items 可變 | 若希望不可變，可改為 `final List<TransactionItem> items` 並在建立時複製 | 低 |

---

## 五、models/color.dart（主題色彩）

| 項目 | 說明 | 優先級 |
|------|------|--------|
| 未使用 ChangeNotifier | MyColor 繼承 ChangeNotifier 但未呼叫 notifyListeners；若色彩不變可改為一般 class + const，或真正支援主題切換 | 低 |
| 色彩常數集中 | 可考慮改為 `ThemeData` 或 AppColors 靜態常數，方便日後支援深色模式 | 低 |

---

## 六、pages/home_page.dart（首頁）

| 項目 | 說明 | 優先級 |
|------|------|--------|
| 未使用 import | 移除 `dart:math`、`sqflite` 等未使用之 import | 高 |
| 首頁 AppBar 按鈕 | 返回、設定圖示目前無 onTap 或導航，需綁定行為或隱藏 | 中 |
| 排序時 itemBuilder | 當 `isSort == true` 時 itemCount 為 `getAllTags.length`，但 `item` 仍用 `items[index]`，在 tag 數少於 item 數時易錯；排序時應只傳 tag 與 Day，不取 `items[index]` | 高 |
| 魔術數字 | 寬高（360, 191, 87 等）、padding 可抽成常數或使用 ScreenUtil | 低 |

---

## 七、pages/calendar_page.dart（日曆頁）

| 項目 | 說明 | 優先級 |
|------|------|--------|
| 未使用變數 | `first_day`、`isEnd`、`isStart` 未使用，可刪除 | 低 |
| 月份統計重複 | getMonthTotalIncome / getMonthTotalExpense 邏輯類似，可抽成 `getMonthTotal(expenseData, isIncome)` | 中 |
| firstWhere 拋錯 | 若無符合月份會拋出，建議用 `firstWhere(..., orElse: () => ...)` 或 `cast`/安全取法 | 中 |
| 日曆格線效能 | 目前用 GridView.builder 且 shrinkWrap，若月份很長可考慮只渲染可見區或固定高度捲動 | 低 |
| standard 改 const | `standard` 可改為 `static const` 以利效能 | 低 |

---

## 八、pages/analysis_page.dart（統計頁）

| 項目 | 說明 | 優先級 |
|------|------|--------|
| 佔位內容 | 目前僅顯示 "456"，待實作圖表或統計摘要 | 高 |

---

## 九、pages/setting_page.dart（設定頁）

| 項目 | 說明 | 優先級 |
|------|------|--------|
| 佔位內容 | 目前僅顯示 "789"，待實作主題、匯出、關於等設定項 | 高 |

---

## 十、pages/add_page.dart（新增收支）

| 項目 | 說明 | 優先級 |
|------|------|--------|
| Controller 未釋放 | `TextEditingController` 需在 `dispose()` 呼叫 `name_controller.dispose()`、`amount_controller.dispose()`，避免記憶體洩漏 | 高 |
| 金額輸入 | 使用 `digitsOnly` 無法輸入小數點；若需小數可改為 `FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))` 等 | 中 |
| 儲存順序 | 目前先 `Navigator.pop` 再 `add`；應改為 `await context.read<ExpenseProvider>().add(...)` 再 `pop`，確保寫入後再關閉 | 高 |
| 時間不可編輯 | 時間固定為 `DateTime.now()`，若需記過去/未來可加日期時間選擇器 | 低 |
| 表單驗證 | 金額為空或非數字時應提示使用者，避免 parse 異常 | 中 |

---

## 十一、components/list/my_list.dart（單筆列表項）

| 項目 | 說明 | 優先級 |
|------|------|--------|
| Dismissible key | 若 `item.id` 為 null（例如未寫入 DB 的項目），Key 可能重複；可改用 `ObjectKey(item)` 或 id + name + date 組合 | 中 |

---

## 十二、components/list/my_list_group.dart（依標籤分組列表）

| 項目 | 說明 | 優先級 |
|------|------|--------|
| 未使用變數 | `expense_data` 未使用可移除 | 低 |
| tagsOfItems 回傳 | `tagsOfItems` 已回傳 List，`?? []` 多餘可刪 | 低 |
| tagName 預設 | `widget.tagName ?? "errorTag"` 若 tagName 為非 null 設計可簡化 | 低 |

---

## 優化實作建議順序

1. **立即修復**：home_page 排序時 itemBuilder 索引、add_page 的 dispose 與儲存順序、db_helper 刪除改用 id、expense_provider 月份邊界。
2. **短期**：main 底部導航抽元件、Provider 錯誤處理與 countTotalCost 型別、add_page 金額格式與驗證。
3. **中期**：transaction type 改 enum、日曆 firstWhere 安全取、首頁 IndexedStack。
4. **長期**：實作統計頁與設定頁、主題/色彩重構、資料量大時分頁或分批查詢。
