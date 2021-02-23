//
//  TransferStateObj.swift
//  indogo
//
//  Created by mac on 2020/8/31.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class TransferStateObj: NSObject {
    var payment_info:String! = ""
    var transfer_status_id:String! = ""
    var transfer_status_name:String! = ""
    var recipient_name:String! = ""
    var total:String! = ""
    var lm_time_pending:String! = ""
    var transfer_amount_idr:String! = ""
    var to_acc:String! = ""
    var from_acc:String! = ""
    var lm_time_transfer:String! = ""
    var kurs_value:String! = ""
    var exchange_id:String! = ""
    var old_kurs_value:String! = ""
    var diff_kurs_value:String! = ""
    var lm_time_paid:String! = ""
    var bank_code:String! = ""
    var recipient_id:String! = ""
    var mini_mart_id:String! = ""
    var lm_time_fail:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        
        if orderNum == 0 {
            payment_info = valueStr
        } else if orderNum == 1 {
            transfer_status_id = valueStr
        } else if orderNum == 2 {
            transfer_status_name = valueStr
        } else if orderNum == 3 {
            recipient_name = valueStr
        } else if orderNum == 4 {
            total = valueStr
        } else if orderNum == 5 {
            lm_time_pending = valueStr
        } else if orderNum == 6 {
            transfer_amount_idr = valueStr
        } else if orderNum == 7 {
            to_acc = valueStr
        } else if orderNum == 8 {
            from_acc = valueStr
        } else if orderNum == 9 {
            lm_time_transfer = valueStr
        } else if orderNum == 10 {
            kurs_value = valueStr
        } else if orderNum == 11 {
            exchange_id = valueStr
        } else if orderNum == 12 {
            old_kurs_value = valueStr
        } else if orderNum == 13 {
            diff_kurs_value = valueStr
        } else if orderNum == 14 {
            lm_time_paid = valueStr
        } else if orderNum == 15 {
            bank_code = valueStr
        } else if orderNum == 16 {
            recipient_id = valueStr
        } else if orderNum == 17 {
            mini_mart_id = valueStr
        } else if orderNum == 18 {
            lm_time_fail = valueStr
        } 
    }
    
    public func printSelf() {
        Dlog("payment_info(\(payment_info ?? "")), transfer_status_id(\(transfer_status_id ?? "")), transfer_status_name(\(transfer_status_name ?? "")), recipient_name(\(recipient_name ?? "")), total(\(total ?? "")), lm_time_pending(\(lm_time_pending ?? "")), transfer_amount_idr(\(transfer_amount_idr ?? "")), to_acc(\(to_acc ?? "")), from_acc(\(from_acc ?? "")), lm_time_transfer(\(lm_time_transfer ?? "")), kurs_value(\(kurs_value ?? "")), exchange_id(\(exchange_id ?? "")), old_kurs_value(\(old_kurs_value ?? "")), diff_kurs_value(\(diff_kurs_value ?? "")), lm_time_paid(\(lm_time_paid ?? "")), bank_code(\(bank_code ?? "")), recipient_id(\(recipient_id ?? "")), mini_mart_id(\(mini_mart_id ?? "")), lm_time_fail(\(lm_time_fail ?? ""))")
    }
}
