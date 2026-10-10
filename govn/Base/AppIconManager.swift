//
//  AppIconManager.swift
//  govn
//
//  後台控制 App icon。
//  後台 API：POST https://govnprod.indogo.link/app/getLauncherIcon.php （免參數）
//  回傳格式：remit_reply 0 <icon 名稱>     例如：remit_reply 0 Default
//
//  注意：iOS 只能在「編譯時打包進 App 的替代圖示」之間切換，
//  圖檔已放在 Assets.xcassets 內的各個 *.appiconset，
//  並在 Info.plist 的 CFBundleAlternateIcons 註冊。
//

import UIKit
import Alamofire

class AppIconManager {

    static let shared = AppIconManager()
    private init() {}

    /// 後台回傳名稱 -> Assets/Info.plist 註冊的 alternate icon 名稱
    /// nil = 切回主圖示
    private let iconMap: [String: String?] = [
        "Default":            nil,        // 後台預設值 -> 切回主圖示
        "Christmas1": "Christmas1",
        "Christmas2": "Christmas2",
        "Christmas3": "Christmas3",
        "Christmas4": "Christmas4",
        "Christmas5": "Christmas5",
        "Christmas6": "Christmas6",
        "DragonBoatFestival1": "DragonBoatFestival1",
        "DragonBoatFestival2": "DragonBoatFestival2",
        "DragonBoatFestival3": "DragonBoatFestival3",
        "Halloween1": "Halloween1",
        "Halloween2": "Halloween2",
        "Halloween3": "Halloween3",
        "Halloween4": "Halloween4",
        "IndependenceDay1": "IndependenceDay1",
        "IndependenceDay2": "IndependenceDay2",
        "IndependenceDay3": "IndependenceDay3",
        "IndependenceDay4": "IndependenceDay4",
        "IndependenceDay5": "IndependenceDay5",
        "IndependenceDay6": "IndependenceDay6",
        "LunarNewyear1": "LunarNewyear1",
        "LunarNewyear2": "LunarNewyear2",
        "LunarNewyear3": "LunarNewyear3",
        "LunarNewyear4": "LunarNewyear4",
        "MidAutumnFestival1": "MidAutumnFestival1",
        "MidAutumnFestival2": "MidAutumnFestival2",
        "MidAutumnFestival3": "MidAutumnFestival3",
        "MidAutumnFestival4": "MidAutumnFestival4",
        "Original": "Original",
        "ReunificationDay1": "ReunificationDay1",
        "ReunificationDay2": "ReunificationDay2",
        "ReunificationDay3": "ReunificationDay3",
        "ReunificationDay4": "ReunificationDay4",
        "Sport": "Sport",
        "TaiwanNationalDay1": "TaiwanNationalDay1",
        "TaiwanNationalDay2": "TaiwanNationalDay2",
        "TaiwanNationalDay3": "TaiwanNationalDay3",
        "WorldCup1": "WorldCup1",
        "WorldCup2": "WorldCup2",
        "WorldCup3": "WorldCup3"
    ]

    // MARK: - 對外入口

    /// 向後台查詢目前該使用哪個 App icon，並自動切換
    func fetchAndApplyIcon() {
        let todoEndpoint: String = API_LauncherIcon
        let parameters: Parameters = [:]      // 不需任何參數
        let headers: HTTPHeaders = [:]

        Dlog("fetchLauncherIcon todoEndpoint=\(todoEndpoint)")

        AppDelegate.shared().alamofireManagerWithTimeout
            .requestWithoutCache(todoEndpoint, method: .post,
                                 parameters: parameters,
                                 encoding: URLEncoding.default, headers: headers)
            .responseString(encoding: String.Encoding.utf8) { [weak self] response in

                guard response.result.error == nil, let data = response.data else {
                    Dlog("fetchLauncherIcon error on \(todoEndpoint)")
                    return
                }

                // 後台回應結尾可能夾帶控制字元(如 0x1F)，需一併清除
                let responseStr = (String(data: data, encoding: .utf8) ?? "")
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.controlCharacters))
                Dlog("fetchLauncherIcon responseStr = \(responseStr)")
                // 例：remit_reply 0 Default

                // 解析格式：remit_reply <state> <icon 名稱(可含空白)>
                let parts = responseStr.components(separatedBy: " ")
                guard parts.count >= 3, parts[0] == "remit_reply", parts[1] == "0" else {
                    Dlog("fetchLauncherIcon 格式不符或狀態非 0")
                    return
                }
                // 第 2 個空白之後全部是名稱（保留中間空白）
                let iconName = parts[2...].joined(separator: " ")

                self?.changeIcon(to: iconName)
            }
    }

    /// 依名稱直接切換 App icon（可單獨呼叫）
    func changeIcon(to backendName: String) {
        // 後台回傳結尾可能夾帶控制字元(如 0x1F)，需一併清除，否則對不到表
        let trimSet = CharacterSet.whitespacesAndNewlines.union(.controlCharacters)
        let key = backendName.trimmingCharacters(in: trimSet)

        guard UIApplication.shared.supportsAlternateIcons else {
            Dlog("此裝置不支援替代圖示")
            return
        }
        guard let iconName = iconMap[key] else {
            Dlog("找不到對應的 icon = \(key)")
            return
        }
        // 已是目前 icon 就不重設（避免重複彈出系統提示）
        if UIApplication.shared.alternateIconName == iconName {
            Dlog("App icon 已經是 \(key)，略過")
            return
        }

        DispatchQueue.main.async {
            UIApplication.shared.setAlternateIconName(iconName) { error in
                if let error = error {
                    Dlog("切換 App icon 失敗：\(error.localizedDescription)")
                } else {
                    Dlog("App icon 已切換為 \(key)")
                }
            }
        }
    }
}
