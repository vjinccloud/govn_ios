//
//  BankObj.swift
//  indogo
//
//  Created by mac on 2020/8/29.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class BankObj: NSObject {
    var bank_code:String! = ""
    var bank_name:String! = ""
    var bank_photo:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        if orderNum == 0 {
            bank_code = valueStr
        } else if orderNum == 1 {
            bank_name = valueStr
        } else if orderNum == 2 {
            bank_photo = valueStr
        }
    }
    
    public func printSelf() {
        Dlog("bank_code(\(bank_code ?? "")), bank_name(\(bank_name ?? "")), bank_photo(\(bank_photo ?? ""))")
    }
}
