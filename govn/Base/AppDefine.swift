//
//  AppDefine.swift
//  GISWork
//
//  Created by askAir on 2018/10/7.
//  Copyright © 2018年 TrendGo. All rights reserved.
//

import Foundation
import UIKit

//測試開關部分
var Para_simulaotroBanc = "19032945890010"
var Para_isTestForBcc = false

//尺寸
var AppWidth:CGFloat = 320.0
var AppTotalHeight:CGFloat = 960.0
var AppTopBarHeight:CGFloat = 50.0
var AppEmptyHeight:CGFloat = 800.0
var FirebaseToken = ""

var ImageLimitInBytes:Int = 300000

//顏色
public let Color_Main_Bule = UtilityTool().hexStringToUIColor(hex: "#2a65ec")
public let Color_Main_Red = UtilityTool().hexStringToUIColor(hex: "#b20808")
public let Color_Main_LightGray = UtilityTool().hexStringToUIColor(hex: "#d6d7d8")
public let Color_Main_DarkGray = UtilityTool().hexStringToUIColor(hex: "#3b3f47")

//開發階段
let DevMode = true
let Lang_APIDecodeFail = NSLocalizedString("API DecodeFail", comment: "伺服器忙線中，請稍候再試")

let AppVersion = "1.0"
let AppId = 1
//正式
let ServerURL = "https://govnprod.indogo.link"
//測試機
//let ServerURL = "http://govndev.indogo.link"

//訂票時限
let orderTicketTimeLimitSecs:Double = 300

//API後續網址設定
let API_Promo = ServerURL + "/app/remit/app_photos"
let API_Login = ServerURL + "/app/remit/login"
let API_CheckLogin = ServerURL + "/app/remit/check_token"
let API_CheckMemExist = ServerURL + "/app/remit/check_mem_exists"
let API_SendSMS = ServerURL + "/app/remit/password_forget_sms"
let API_Register = ServerURL + "/app/remit/register"
let API_ResendRegisterSMS = ServerURL + "/app/remit/request_sms_code"
let API_VerifyRegisterSMS = ServerURL + "/app/remit/verify_sms_code"
let API_NoticeRecordList = ServerURL + "/app/remit/notification_record"
let API_PointHistoryList = ServerURL + "/app/remit/point_history"
let API_GetDoc = ServerURL + "/app/remit/doc_get"
let API_TransferPointFirstStep = ServerURL + "/app/remit/point_transfer_check"
let API_TransferPointSecondStep = ServerURL + "/app/remit/point_transfer"
let API_MemberRecipents = ServerURL + "/app/remit/member_recipients"
let API_MemberHideRecipent = ServerURL + "/app/remit/hide_recipient"
let API_BankList = ServerURL + "/app/remit/bank_list"
let API_AddRecipient = ServerURL + "/app/remit/add_recipient_v2"
let API_UpdateAddRecipient = ServerURL + "/app/remit/add_recipient_v2_update"
let API_TransferHistory = ServerURL + "/app/remit/money_transfer_history"
let API_OrderCheckSingle = ServerURL + "/app/remit/order_check"
let API_OrderCheckMuilti = ServerURL + "/app/remit/orders_check"
let API_TransactionCreate = ServerURL + "/app/remit/create"
let API_BarCode_711 = ServerURL + "/app/remit/ibon_barcode"
let API_BarCode_fami = ServerURL + "/app/remit/fami_barcode"
let API_BarCode_ok = ServerURL + "/app/remit/ok_barcode"
let API_BarCode_hilife = ServerURL + "/app/remit/hilife_barcode"
let API_NotificationRead = ServerURL + "/app/remit/notification_read"
let API_UpdateARC = ServerURL + "/app/remit/update_arc"
let API_UpdateID = ServerURL + "/app/remit/update_id_card"
let API_PassUpdate = ServerURL + "/app/remit/password_update"
let API_PhoneTokenSet = ServerURL + "/app/remit/phone_token_set"
let API_Search_recipient = ServerURL + "/app/remit/search_recipient"
let API_Get_province_district = ServerURL + "/app/remit/get_province_district"

public enum TransferMemberStyle {
    case normal
    case shop
}

enum ScanParentType {
    case forgotPass
    case register
}

enum PhotoIDType {
    case normal
    case front
    case back
    case faceAndId
    case passport
    case sign
    case normalFromEdit
    case frontFromEdit
    case backFromEdit
    case faceAndIdFromEdit
    case passportFromEdit
    case signFromEdit
}

enum LoginFuncType {
    case main
    case member
    case transState
    case transaction
    case sharing
    case notice
}

enum StoreType {
    case sevenEleven
    case familymart
    case ok
    case hiLife
}

enum BottomMenuType {
    case transaction
    case transState
    case sharing
    case notice
    case profile
}
