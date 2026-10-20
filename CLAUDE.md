# CLAUDE.md — GoVN iOS（工程師 Session）

你是 **GoVN 的工程師**。這個 repo 是三款白牌匯款 App 裡最舊的越南版（另兩款在 `../gopadala_ios`、`../indogo_ios`，**不要改它們**，但需求 3 要從 GoPadala 移植程式碼過來，可以讀）。
流程、分支、交付格式在 `../docs/工作流程.md`，需求規格在 `../docs/spec/`。先讀這兩個再動手。

## 目前任務

需求代號 `compliance-202610`，規格：`../docs/spec/三國合規更新.md`。GoVN 三個需求都要做：

1. ARC 發證日期。**注意 GoVN iOS 目前沒有 `register_step_1`**，註冊是一步式走 `API_Register`（`/app/remit/register`），在 `govn/View/Register/RegisterIDSignVC.swift`。Android 的 GoVN 走的是 `register_step_1`。本輪先把 `arc_issue_date` 加進 `API_Register`，用測試機實測後端有沒有收；若後端拒收，回報使用者轉 CTO，不要自己改成兩步式。
2. 防詐提醒。
3. 匯款目的（從 `../gopadala_ios/Gopadala/` 移植，規格裡有來源檔案對照表）。

分支 `feature/compliance-202610` 已開好，直接在上面 commit。不 push、不合 main。**commit 訊息用中文，不可出現 Claude、AI、Co-Authored-By 等署名。**

## 第二輪修正（2026-10-17，CTO 審閱 handoff 後退回）

第一輪三個需求都做了，品質不錯，只有下面四點和規格不符，修完更新 `../_handoff/govn-compliance-202610.md` 再交付：

1. **發證日期列的位置**：規格要求放在「Thời hạn cư trú（到期日）」那列的**上方**，現在在下方。改 `Register.storyboard`。
2. **防詐視窗只留一顆按鈕**：拿掉「HỦY」取消鈕。規格是「只有一顆確認鈕，點外面不能關」。
3. **防詐視窗文字改成和 Android 一致**：標題 vi「Cảnh báo」／en「Warning」，按鈕 vi「Đã hiểu」／en「I Understand」。改 `Localizable.strings` 的 `Fraud Alert Title`、`Fraud Alert Confirm`。
4. **`API_FraudMessage` 去掉 `.php`**：測試機兩種路徑都通，三款 App 統一用 `/app/remit/fraud_message`。

其他在 handoff 第 3 節列的待確認事項，CTO 都已接受（決定寫在規格檔最下方的決定紀錄），不用改。

## 第四輪：註冊改兩步式（2026-10-17）

前三輪都已通過。新增需求 4，規格在 `../docs/spec/三國合規更新.md` 的「需求 4」一節，請完整照做：`RegisterInputVC` 送 `register_step_1` → 簡訊頁 → 拍照、簽名 → `RegisterIDSignVC` 送 `register_step_2`，自拍欄位名改 `self`，移除舊 `API_Register`。來源照 GoPadala。做完更新 handoff（加「第四輪」段落與新流程的截圖），回 CTO 訊息「GoVN 第四輪已交付」。

## 第五輪：UI 對齊設計稿（2026-10-20）

簡報前三頁附的畫面是設計稿，第一輪沒照做。規格 `../docs/spec/三國合規更新.md` 的「需求 5」列了 GoVN 要改的：5-1（只改佔位文字樣式）、5-2、5-3。設計稿圖檔在 `../docs/design/compliance-202610/`，用它並排比對，做到肉眼看不出差異為止。功能邏輯不動。做完更新 handoff（加「第五輪」段落，每個改動畫面附「設計稿 vs 實作」截圖），回 CTO 訊息「GoVN 第五輪已交付」。

## 專案結構

- 開 `govn.xcworkspace`，scheme `govn`。CocoaPods 的 `Pods/` 已進版控，**不要跑 `pod install`**。Podfile 用的是舊的 `Firebase/Core` 寫法，本輪不要升級套件。
- 程式碼在 `govn/`。`Base/` 是共用層：`AppDefine.swift`（所有 API 端點常數與 ServerURL）、`APIHandle.swift`（回傳解析，一個大 switch，每個端點一個 case）、`CustomAlertView.swift`（彈窗）、`UtilityTool.swift`。
- 畫面在 `View/<功能>/`，storyboard 是 `Main`、`Member`、`Register` 等，部分畫面用 xib。
- 語系：`en.lproj`、`vi.lproj` 的 `Localizable.strings`（`id.lproj` 也在但 GoVN 不用印尼文）。新字串 en 與 vi 都要加，key 是英文短句。
- 全域狀態都掛在 `AppDelegate.shared()`。
- GoVN 和 GoPadala 的 `AppDelegate.swift`、`RecipientListVC.swift`、`TransactionInfoConfirmVC.swift` 差異很大，移植時只搬邏輯，**不要整檔覆蓋**。

## 後端協定（改 API 時必守）

- `POST {ServerURL}/app/remit/<action>`，`URLEncoding.default`。每支都帶 `token`、`gps_code`、`mobile_type: "iphone"`、`ip_addr`、`req_timestamp`（`Date.giveCurrentDateString()`），照既有呼叫抄。
- 回傳是純文字 `remit_reply <code> <payload>`，不是 JSON。`code` 0 成功。
- 多筆資料：列用 `AppDelegate.shared().seperatorStr`（U+001F）分，列內欄位用 `subSeperatorStr`（U+001E）分。不要寫死。
- 新端點一律：`AppDefine.swift` 加常數 → `APIHandle.swift` 加 case → 畫面呼叫。

## 環境

`Base/AppDefine.swift` 已改成 Debug 打 `TestServerURL`、Release 打 `ProdServerURL`。開發用 Debug。**`ProdServerURL` 不准改**；`TestServerURL` 由 CTO 填，不對就回報，不要自己改。

## 交付

做完寫 `../_handoff/govn-compliance-202610.md`（格式見工作流程），附模擬器截圖，然後告訴使用者可以叫 QA 驗。QA 回 FAIL 時修完再交付一次。
規格看不懂或後端行為不明，**問使用者轉 CTO**，不要猜。
