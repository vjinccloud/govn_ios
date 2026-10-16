//
//  APIHandle.swift
//  indogo
//
//  Created by mac on 2020/7/11.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public enum ResponseState {
    case failed
    case ok
    case maxExceed
    case error
    case member_not_exist
    case lack_point
}

class APIHandle {

    static let sharedInstance = APIHandle()
    
    init() {}
    
    //MARK: - Basic
    //取得回傳的狀態
    func getResponseState(ResponseStr resStr:String, APIStr apiStr:String, SubStr subStr:String) -> ResponseState {
        if !resStr.hasPrefix("remit_reply") || resStr.count < 13 {
            return ResponseState.failed
        }
        
        AppDelegate.shared().apiBackContentStr = ""
        
        var resultStr = ""
        var stateStr = ""
        
        //改成自動判斷
        let endIdx = findSecondSpaceIndex(AllStr: resStr)
        if endIdx != -1 {
            var startIndex = resStr.index(resStr.startIndex, offsetBy: 12)
            var endIndex = resStr.index(resStr.startIndex, offsetBy: endIdx-1)
            stateStr = String(resStr[startIndex..<endIndex])
            
            startIndex = resStr.index(resStr.startIndex, offsetBy: endIdx)
            endIndex = resStr.endIndex
            resultStr = String(resStr[startIndex..<endIndex]).trimmingCharacters(in: .whitespaces)
        } else {
            var startIndex = resStr.index(resStr.startIndex, offsetBy: 12)
            var endIndex = resStr.index(resStr.startIndex, offsetBy: 13)
            stateStr = String(resStr[startIndex..<endIndex])
            
            startIndex = resStr.index(resStr.startIndex, offsetBy: 14)
            endIndex = resStr.endIndex
            resultStr = String(resStr[startIndex..<endIndex]).trimmingCharacters(in: .whitespaces)
        }
        
        Dlog("resultStr = \(resultStr), stateStr = -\(stateStr)-")
        
        if stateStr != "0" {
            AppDelegate.shared().apiBackContentStr = resultStr
            
            if stateStr == "15" || stateStr == "9001" || stateStr == "503" || stateStr == "702" || stateStr == "15001" || stateStr == "16001" {
                if AppDelegate.shared().hasLogin {
                    AppDelegate.shared().userLogout()
                    AppDelegate.shared().changeRootOfFunc(Type: .main)
                }
            }
            
            //特殊狀況
            if apiStr == API_CheckMemExist && stateStr == "3" {
                return ResponseState.member_not_exist
            } else if apiStr == API_AddRecipient {
                return ResponseState.error
            } else if apiStr == API_MemberRecipents && (stateStr == "509" || stateStr == "714" || stateStr == "715" || stateStr == "716") {
                if stateStr == "509" {
                    getRecipientMaxAmount(DataStr: resultStr, Is509: true)
                } else {
                    getRecipientMaxAmount(DataStr: resultStr)
                }
                
                return ResponseState.maxExceed
            } else if apiStr == API_MemberRecipentsV2 && (stateStr == "509" || stateStr == "714" || stateStr == "715" || stateStr == "716") {
                if stateStr == "509" {
                    getRecipientMaxAmount(DataStr: resultStr, Is509: true)
                } else {
                    getRecipientMaxAmount(DataStr: resultStr)
                }
                
                return ResponseState.maxExceed
            } else if apiStr == API_BankList {
                return ResponseState.failed
            } else {
                //取得最後訊息並顯示
                if apiStr == API_TransferPointFirstStep {
                    if resultStr.contains("no member") || resultStr.contains("not have this member") {
                        return ResponseState.ok
                    } else {
                        return ResponseState.error
                    }
                    
                } else {
                    //AppDelegate.shared().showAlertWithWindow(vc, Message: resultStr)
                    return ResponseState.failed
                }
                
            }
        }
        
        //根據 API 字串處理後續
        switch apiStr {
        case API_GetInfo:
            getinfo(DataStr: resultStr)
            break
        case API_Promo:
            promo(DataStr: resultStr)
            break
        case API_Login:
            login(DataStr: resultStr)
            break
        case API_CheckLogin:
            login(DataStr: resultStr)
            break
        case API_Get_province_district:
            //記住目前這份省份資料是哪一種，才知道要不要重抓
            AppDelegate.shared().provinceDataIsDoorToDoor = false
            checkProvinceListByJson(DataStr: resultStr)
            break
        case API_Get_province_districtDoorToDoor:
            AppDelegate.shared().provinceDataIsDoorToDoor = true
            checkProvinceListByJson(DataStr: resultStr)
            break
        case API_CheckMemExist:
            checkMemExist(DataStr: resultStr)
            break
        case API_SendSMS:
            sendSMS(DataStr: resultStr)
            break
        case API_Register, API_ResendRegisterSMS:
            sendRegisterSMS(DataStr: resultStr)
            break
        case API_NoticeRecordList:
            checkNoticeList(DataStr: resultStr)
            break
        case API_PointHistoryList:
            checkPointHistoryList(DataStr: resultStr)
            break
        case API_GetDoc:
            checkDocContent(DataStr: resultStr, SubStr: subStr)
            break
        case API_TransferPointFirstStep:
            checkPointTransferFirstStep(DataStr: resultStr, SubStr: subStr)
            break
        case API_MemberRecipents:
            checkRecipientList(DataStr: resultStr)
            break
        case API_MemberRecipentsV2:
            checkRecipientList(DataStr: resultStr)
            break
        case API_BankList:
            checkBankList(DataStr: resultStr)
            break
        case API_TransferHistory:
            checkTransferStateList(DataStr: resultStr)
            break
        case API_OrderCheckMuilti:
            checkTransferOrderCheckList(DataStr: resultStr)
            break
        case API_TransactionCreate:
            checkTransactionResult(DataStr: resultStr)
            break
        case API_TransactionCreateV2:
            checkTransactionResult(DataStr: resultStr)
            break
        case API_AddRecipient:
            checkAddRecipientResult(DataStr: resultStr)
            break
        case API_Check_recipient_v2:
            checkAddRecipientResultV2(DataStr: resultStr)
            break
        case API_Search_recipient:
            chectSearchRecopoentList(DataStr: resultStr)
            break
        case API_Search_recipient_ids:
            chectSearchRecopoentList(DataStr: resultStr)
            break
        case API_UpdateAddRecipient:
            updateAddRecipient(DataStr: resultStr)
            break
        case API_BarCode_711, API_BarCode_fami, API_BarCode_ok, API_BarCode_hilife:
            checkBarCode(DataStr: resultStr)
            break
        case API_TransferToday:
            checkTransferStateList(DataStr: resultStr)
            break
        case API_TransferHistoryBeforeToday:
            checkTransferStateList(DataStr: resultStr)
            break
        case API_GetQuota:
            checkQuotaResult(DataStr: resultStr)
            break
        case API_CheckDiscountCode:
            checkDiscountCodeResult(DataStr: resultStr)
        case API_GetPurpose:
            checkPurpose(DataStr: resultStr)
            break
        case API_FraudMessage:
            //整段文字直接保存（可能含換行）
            AppDelegate.shared().fraudMessageStr = resultStr
            break
        default:
            break
        }
        
        return ResponseState.ok
    }
    
    //匯款目的：列用 seperatorStr 分，列內 id / name 用 subSeperatorStr 分
    private func checkPurpose(DataStr dataStr:String) {
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            
            let obj:TransferPurposeObj = TransferPurposeObj()
            for j in 0..<subAry.count {
                obj.setValueByOrder(Order: j, Value: subAry[j])
            }
            
            if obj.name != "" {
                Dlog("== \(i) =========")
                obj.printSelf()
                AppDelegate.shared().purposeObj.append(obj)
            }
        }
    }
    
    private func checkDiscountCodeResult(DataStr dataStr:String) {
        
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        
        for i in 0..<ary.count {
            
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            if subAry.count < 2 {
                return
            }
            for j in 0..<subAry.count {
                if j > 5 {
                    return
                }
                Dlog("checkDiscountCodeResult \(j+1). value = \(subAry[j])")
                AppDelegate.shared().tempDiscountCodeResultAry[j] = subAry[j]
            }
        }
        
    }
    
    private func checkQuotaResult(DataStr dataStr:String) {
        
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for j in 0..<ary.count {
            Dlog("checkQuotaResult \(j+1). value = \(ary[j])")
            if j==0 {
                AppDelegate.shared().transferQuotaTotal = Int(ary[0]) ?? 0
            } else if j==1 {
                AppDelegate.shared().transferQuotaLeft = Int(ary[1]) ?? 0
            }
        }
        
    }
    
    private func updateAddRecipient(DataStr dataStr:String) {
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for j in 0..<ary.count {
            if j==0 {
                AppDelegate.shared().tempRecipientObj.recipient_id = ary[0]
            } else if j==1 {
                AppDelegate.shared().tempRecipientObj.recipient_name = ary[1]
            }
        }
    }
    
    //找到第二個空白
    func findSecondSpaceIndex(AllStr str:String) -> Int {
        var ans = -1
        var spaceCount = 0
        for i in 1..<str.count {
            let startIndex = str.index(str.startIndex, offsetBy: i-1)
            let endIndex = str.index(str.startIndex, offsetBy: i)
            let stateStr = String(str[startIndex..<endIndex])
            //Dlog("stateStr = \(stateStr)")
            if stateStr == " " {
                spaceCount += 1
                if spaceCount == 2 {
                    ans = i
                    break
                }
            }
        }
        
        return ans
    }
    
    private func checkAddRecipientResult(DataStr dataStr:String) {
        //AppDelegate.shared().tempRecipientObj = RecipientObj()
        
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for j in 0..<ary.count {
            if j==0 {
                AppDelegate.shared().tempRecipientObj.recipient_id = ary[0]
            } else if j==1 {
                AppDelegate.shared().tempRecipientObj.recipient_name = ary[1]
            }
        }
        
    }
    
    private func checkAddRecipientResultV2(DataStr dataStr:String) {
        Dlog("checkAddRecipientResultV2 DataStr a = \(dataStr)")
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for j in 0..<ary.count {
            if j==1 {
                AppDelegate.shared().checkRecipientName = ary[1]
                Dlog("checkAddRecipientResultV2 DataStr b = \(AppDelegate.shared().checkRecipientName)")
            }
        }
    }
    
    private func checkTransactionResult(DataStr dataStr:String) {
        let obj:TransactionResultObj = TransactionResultObj()
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for j in 0..<ary.count {
            obj.setValueByOrder(Order: j, Value: ary[j])
        }
        
        if obj.payment_info != "" {
            obj.printSelf()
            AppDelegate.shared().tempTransactionResultObj = obj
        } else {
            AppDelegate.shared().tempTransactionResultObj = TransactionResultObj()
        }
    }
    
    private func checkBarCode(DataStr dataStr:String) {
        let obj:BarCodeInfoObj = BarCodeInfoObj()
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for j in 0..<ary.count {
            obj.setValueByOrder(Order: j, Value: ary[j])
        }
        
        if obj.lm_time_expire != "" {
            obj.printSelf()
            AppDelegate.shared().tempBarCodeInfoObj = obj
        } else {
            AppDelegate.shared().tempBarCodeInfoObj = BarCodeInfoObj()
        }
    }
    
    private func checkDocContent(DataStr dataStr:String, SubStr subStr:String) {
        if subStr == "會員服務條款" || subStr == "外籍勞工薪資結匯申報委託書" {
            let content = "<html><header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header><body>\(dataStr)</body></html>"
            AppDelegate.shared().tempAgreementHtmlContent = content
        } else if subStr == "使用者條款" {
            let content = "<html><header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header><body>\(dataStr)</body></html>"
            AppDelegate.shared().tempAgreementHtmlContent = content
        } else if subStr == "分享文案" {
            AppDelegate.shared().shareContent = dataStr
        } else if subStr == "點數轉移規則" {
            let content = "<html><header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header><body>\(dataStr)</body></html>"
            AppDelegate.shared().tempTransferAgreementHtmlContent = content
        }
        
    }
    
    private func chectSearchRecopoentList(DataStr dataStr:String) {
        
        let divStr = String(describing: UnicodeScalar(31)!)
        let divSubStr = String(describing: UnicodeScalar(30)!)
        
        AppDelegate.shared().tempSearchRecipientList = []
        
        if dataStr.count < 3 {
            return
        }
        
        let ary = dataStr.components(separatedBy: divStr)
        for i in 0..<ary.count {
            let str = ary[i]
            if str.count>=5 {
                let obj:RecipientObj = RecipientObj()
                let str1 = str
                let aryzone = str1.components(separatedBy: divSubStr)
                if aryzone.count >= 8, aryzone[0].count > 0, aryzone[1].count > 0 {
                    obj.recipient_id = aryzone[0]
                    obj.recipient_name = aryzone[1]
                    obj.id_card_no = aryzone[2]
                    obj.phone_no = aryzone[3]
                    obj.relationship = aryzone[4]
                    obj.province_id = aryzone[5]
                    obj.district_id = aryzone[6]
                    obj.address = aryzone[7]
                    AppDelegate.shared().tempSearchRecipientList.append(obj)
                }
            }
        }
    }
    
    private func checkProvinceListByJson(DataStr dataStr:String) {
        let allObj = JSON.init(parseJSON: dataStr)

        AppDelegate.shared().provinceData = []
        
        var maxValue:Int = 0
        //先找出最大的
        for (key, _) in allObj {
            if Int(key)! > maxValue {
                maxValue = Int(key)!
            }
        }
        
        for i in 0..<maxValue {
            let key = "\(i+1)"
            let subObj = allObj[key]
            if allObj[key] != JSON.null {
                let provinceObj:ProvinceObj = ProvinceObj()
                provinceObj.province_name = subObj["province_name"].stringValue
                provinceObj.province_id = key
                for j in 0..<subObj["districts"].count {
                    let zoneObj:ZoneObj = ZoneObj()
                    zoneObj.district_id = subObj["districts"][j]["district_id"].stringValue
                    zoneObj.district_name = subObj["districts"][j]["district_name"].stringValue
                    provinceObj.appendZone(Zone: zoneObj)
                }
                
                if provinceObj.allZone.count>0 { //有可能是空的
                    AppDelegate.shared().provinceData.append(provinceObj)
                }
            }
        }
    }
    
    private func checkProvinceList(DataStr dataStr:String) {
        //目前直接用zero width空格(ascii 29)
        let vinceDivStr = String(describing: UnicodeScalar(30)!) + String(describing: UnicodeScalar(31)!)
        let vinceSubDivStr = String(describing: UnicodeScalar(29)!)
        let zonDivStr = String(describing: UnicodeScalar(30)!)
        let zonDivSubStr = String(describing: UnicodeScalar(28)!)
        
        AppDelegate.shared().provinceData = []
        
        let ary = dataStr.components(separatedBy: vinceDivStr)
        for i in 0..<ary.count {
            let provinceObj:ProvinceObj = ProvinceObj()
            //切出省與區
            let str2 = ary[i]
            let ary2 = str2.components(separatedBy: vinceSubDivStr)
            //ary2 省id(29)省的名稱(29)區
            for j in 0..<ary2.count {
                //j=0 省id , j=1 省名稱
                if ary2.count>2 {
                    if j==0 {
                        provinceObj.province_id = ary2[0]
                    } else if j==1 {
                        provinceObj.province_name = ary2[1]
                    } else if j==2 {
                        let zonestr = ary2[j]
                        let zoneAry = zonestr.components(separatedBy: zonDivStr)
                        for k in 0..<zoneAry.count {
                            let zonestr2 = zoneAry[k]
                            let zoneDetailAry = zonestr2.components(separatedBy: zonDivSubStr)
                            let zoneObj:ZoneObj = ZoneObj()
                            if zoneDetailAry.count==2 {
                                zoneObj.district_id = zoneDetailAry[0]
                                zoneObj.district_name = zoneDetailAry[1]
                                provinceObj.appendZone(Zone: zoneObj)
                            }
                        }
                        
                        var speStr = ""
                        if provinceObj.allZone.count==0 {
                            speStr = " ------"
                        }
                        Dlog("Province(\(i)) zone count = \(provinceObj.allZone.count)\(speStr)")
                    }
                }
            }
            
            if provinceObj.allZone.count>0 { //有可能是空的
                AppDelegate.shared().provinceData.append(provinceObj)
            }
        }
        Dlog("Province count = \(AppDelegate.shared().provinceData.count)")
    }
    
    private func checkBankList(DataStr dataStr:String) {
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            if ary[i].count < 2 { //沒東西
                continue
            }
            
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            
            let obj:BankObj = BankObj()
            for j in 0..<subAry.count {
                obj.setValueByOrder(Order: j, Value: subAry[j])
            }
            obj.printSelf()
            AppDelegate.shared().bankList.append(obj)
        }
    }
    
    private func checkTransferStateList(DataStr dataStr:String) {
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            
            let obj:TransferStateObj = TransferStateObj()
            for j in 0..<subAry.count {
                obj.setValueByOrder(Order: j, Value: subAry[j])
            }
            
            if obj.payment_info != "" {
                Dlog("== \(i) =========")
                obj.printSelf()
                AppDelegate.shared().transferStateListObjs.append(obj)
            }
        }
    }
    
    private func checkTransferOrderCheckList(DataStr dataStr:String) {
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            
            let obj:TransferOrderCheckObj = TransferOrderCheckObj()
            for j in 0..<subAry.count {
                obj.setValueByOrder(Order: j, Value: subAry[j])
            }
            
            if obj.payment_info != "" {
                Dlog("== \(i) =========")
                obj.printSelf()
                AppDelegate.shared().transferOrderCheckListObjs.append(obj)
            }
        }
    }
    
    private func checkRecipientList(DataStr dataStr:String) {
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            if ary[i].count < 2 { //沒東西
                continue
            }
            
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            
            let obj:RecipientObj = RecipientObj()
            for j in 0..<subAry.count {
                obj.setValueByOrder(Order: j, Value: subAry[j])
            }
            if obj.recipient_type.count == 0 {
                obj.recipient_type.append(1)
            }
            obj.printSelf()
            
            //直接先濾掉不是目前範圍的 (1的話必須有銀行資料)
            if obj.compareRecipient_type(Type:AppDelegate.shared().transactionObj.recipient_type) {
                AppDelegate.shared().recipientListObjs.append(obj)
                
                if obj.is_hidden != "1" {
                    AppDelegate.shared().recipientShownListObjs.append(obj)
                }
            }
        }
    }
    
    private func sendSMS(DataStr dataStr:String) {
        AppDelegate.shared().forgotPassTempSMS = dataStr
    }
    
    private func sendRegisterSMS(DataStr dataStr:String) {
        AppDelegate.shared().forgotPassTempSMS = dataStr
    }
    
    private func checkMemExist(DataStr dataStr:String) {
        AppDelegate.shared().forgotPassTempPhone = dataStr
    }
    
    private func checkPointHistoryList(DataStr dataStr:String) {
        AppDelegate.shared().historyListObj = []
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            if i<2 { //第一個與第二個是其他東西
                continue
            }
            
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            
            let obj:PointHistorySingleObj = PointHistorySingleObj()
            for j in 0..<subAry.count {
                obj.setValueByOrder(Order: j, Value: subAry[j])
            }
            obj.printSelf()
            AppDelegate.shared().historyListObj.append(obj)
        }
    }
    
    private func checkPointTransferFirstStep(DataStr dataStr:String, SubStr subStr:String) {
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            Dlog("===\(ary[i])")
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            
            let obj:TransferMemberObj = TransferMemberObj()
            for j in 0..<subAry.count {
                if subStr == "1" { //系統會員
                    if j==0 {
                        obj.idStr = subAry[j]
                    } else if j==1 {
                        obj.name = subAry[j]
                    }
                } else if subStr == "2" { //Sho[會員
                    if j==0 {
                        obj.name = subAry[j]
                    } else if j==1 {
                        obj.phone = subAry[j]
                    }
                }
                Dlog("---\(subAry[j])")
            }
            
            var canAdd = true
            if subStr == "1" { //系統會員
                if obj.idStr == "" || obj.name == "" {
                    canAdd = false
                }
                obj.memberStyle = .normal
            } else if subStr == "2" { //Sho[會員
                if obj.name == "" || obj.phone == "" {
                    canAdd = false
                }
                obj.memberStyle = .shop
            }
            
            if canAdd {
                AppDelegate.shared().transferStepOneListObj.append(obj)
            }
            
            //obj.printSelf()
            //AppDelegate.shared().historyListObj.append(obj)
        }
    }
    
    private func checkNoticeList(DataStr dataStr:String) {
        //目前直接用zero width空格
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            //Dlog("(\(i))=====")
            let subAry = ary[i].components(separatedBy: AppDelegate.shared().subSeperatorStr)
            if subAry.count < 7 {
                continue
            }
            let obj:NoticeObj = NoticeObj()
            for j in 0..<subAry.count {
                //Dlog("---\(subAry[j])")
                obj.setValueByOrder(Order: j, Value: subAry[j])
            }
            AppDelegate.shared().noteListObjs.append(obj)
        }
    }
    
    //let API_Login = ServerURL + "/app/remit/login"    //token(31)member_name(31)kurs_value(31)kurs_lm_time(31)service_charge(31)remit_point(31)free_service_charge(31)share_id(31)app_phone_no(31)app_share_bonus(31)google_map_url(31)app_version(31)app_market(31)line_url(31)games_url
    private func login(DataStr dataStr:String) {
        /*
        //目前直接用zero width空格
        let startIndex = dataStr.index(dataStr.startIndex, offsetBy: 32)
        let endIndex = dataStr.index(dataStr.startIndex, offsetBy: 33)
        let separateStr = String(dataStr[startIndex..<endIndex])
        //AppDelegate.shared().seperatorStr = separateStr
        */
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        
        AppDelegate.shared().userLogin(TokenStr: ary[0])
        let keyAry:[String] = ["member_name","kurs_value","kurs_lm_time","service_charge","remit_point","free_service_charge","share_id","app_phone_no","app_share_bonus","google_map_url","app_version","app_market","line_url","games_url","member_id","arc_photo","arc_back_photo","signature_photo","id_card_photo","self_photo","usd_kurs_value","usd_kurs_lm_time","service_charge_2","service_charge_3"]
        for i in 0..<keyAry.count {
            var value:String = ""
            if (i+1) < ary.count {
                value = ary[i+1]
                if keyAry[i] == "kurs_lm_time" || keyAry[i] == "usd_kurs_lm_time" {
                    value = value.replacingOccurrences(of: "-", with: "/")
                }
                AppDelegate.shared().memberData[keyAry[i]] = value
            } else {
                Dlog("over loop")
            }
            Dlog("key(\(keyAry[i])) = \(value)")
        }
    }
    
    //let API_Promo = ServerURL + "/app/remit/app_photos"
    //remit_reply 0 圖片的url(31)圖片的url(31)圖片的url(31)
    private func promo(DataStr dataStr:String) {
        AppDelegate.shared().promoUrlAry = []
        
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            var str = ary[i]
            str = str.trimmingCharacters(in: .whitespaces)
            if str.count>10 {
               AppDelegate.shared().promoUrlAry.append(str)
            }
            
        }
        Dlog("promoUrlAry = \(AppDelegate.shared().promoUrlAry.count)")
    }
    
    private func getinfo(DataStr dataStr:String) {
        AppDelegate.shared().getInfoStrAry = []
        
        let ary = dataStr.components(separatedBy: AppDelegate.shared().seperatorStr)
        for i in 0..<ary.count {
            var str = ary[i]
            str = str.trimmingCharacters(in: .whitespaces)
            AppDelegate.shared().getInfoStrAry.append(str)
            
            Dlog("\(i) str = \(str)")
        }
        
        Dlog("getInfoStrAry = \(AppDelegate.shared().getInfoStrAry.count)")
    }
    
    private func getRecipientMaxAmount(DataStr dataStr:String, Is509 is509:Bool = false) {
        let ary = dataStr.components(separatedBy: AppDelegate.shared().subSeperatorStr)
        AppDelegate.shared().transferErrorIs509 = is509
        for i in 0..<ary.count {
            if i==0 {
                AppDelegate.shared().tempTransferMaxWarningStr = ary[i]
            } else if i==1 {
                let str = ary[i]
                if is509 {
                    AppDelegate.shared().tempTransferMaxAmountStr = str
                    AppDelegate.shared().tempTransferMaxAmount = Int(str) ?? 0
                } else {
                    AppDelegate.shared().tempTransferLeftAmount = Int(str) ?? 0
                }
            } else if i==2 {
                let str = ary[i]
                if is509 {
                    AppDelegate.shared().tempTransferLeftAmount = Int(str) ?? 0
                } else {
                    AppDelegate.shared().tempTransferMaxAmount = Int(str) ?? 0
                }
                
            }
        }
        
        Dlog("str = \(AppDelegate.shared().tempTransferMaxWarningStr), left = \(AppDelegate.shared().tempTransferLeftAmount), max = \(AppDelegate.shared().tempTransferMaxAmount)")
    }
}
