//
//  TransactionResultObj.swift
//  indogo
//
//  Created by mac on 2020/9/4.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class TransactionResultObj: NSObject {
     var payment_info:String! = ""
     var family_mart_error_message:String! = ""
     var remit_point:String! = ""
     var free_service_charge:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        if orderNum == 0 {
            payment_info = valueStr
        } else if orderNum == 1 {
            family_mart_error_message = valueStr
        } else if orderNum == 2 {
            remit_point = valueStr
        } else if orderNum == 3 {
            free_service_charge = valueStr
        }
    }
    
    public func printSelf() {
        Dlog("payment_info(\(payment_info ?? "")), family_mart_error_message(\(family_mart_error_message ?? "")), remit_point(\(remit_point ?? "")), free_service_charge(\(free_service_charge ?? ""))")
    }
}
