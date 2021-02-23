//
//  TransferOrderCheckObj.swift
//  indogo
//
//  Created by mac on 2020/8/31.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class TransferOrderCheckObj: NSObject {
    var payment_info:String! = ""
    var order_status:String! = ""
    var lm_time_process:String! = ""
    var server_time:String! = ""
    var lm_time_pending:String! = ""
    var lm_time_transfer:String! = ""
    var lm_time_paid:String! = ""
    var mini_mart_id:String! = ""
    var lm_time_failed:String! = ""
    var lm_time_expire:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        
        if orderNum == 0 {
            payment_info = valueStr
        } else if orderNum == 1 {
            order_status = valueStr
        } else if orderNum == 2 {
            lm_time_pending = valueStr
        } else if orderNum == 3 {
            lm_time_paid = valueStr
        } else if orderNum == 4 {
            lm_time_process = valueStr
        } else if orderNum == 5 {
            lm_time_transfer = valueStr
        } else if orderNum == 6 {
            server_time = valueStr
        } else if orderNum == 7 {
            lm_time_expire = valueStr
        } else if orderNum == 8 {
            mini_mart_id = valueStr
        } else if orderNum == 9 {
            lm_time_failed = valueStr
        }
    }
    
    public func printSelf() {
        Dlog("payment_info(\(payment_info ?? "")), order_status(\(order_status ?? "")), lm_time_pending(\(lm_time_pending ?? "")), lm_time_paid(\(lm_time_paid ?? "")), lm_time_process(\(lm_time_process ?? "")), lm_time_transfer(\(lm_time_transfer ?? "")), server_time(\(server_time ?? "")), lm_time_expire(\(lm_time_expire ?? "")), mini_mart_id(\(mini_mart_id ?? "")), lm_time_failed(\(lm_time_failed ?? ""))")
    }
}
