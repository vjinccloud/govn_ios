//
//  BarCodeInfoObj.swift
//  indogo
//
//  Created by mac on 2020/9/4.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class BarCodeInfoObj: NSObject {
    var ol_code_1:String! = ""
    var ol_code_2:String! = ""
    var ol_code_3:String! = ""
    var lm_time_expire:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        if orderNum == 0 {
            ol_code_1 = valueStr
        } else if orderNum == 1 {
            ol_code_2 = valueStr
        } else if orderNum == 2 {
            ol_code_3 = valueStr
        } else if orderNum == 3 {
            lm_time_expire = valueStr
        }
    }
    
    public func printSelf() {
        Dlog("ol_code_1(\(ol_code_1 ?? "")), ol_code_2(\(ol_code_2 ?? "")), ol_code_3(\(ol_code_3 ?? "")), lm_time_expire(\(lm_time_expire ?? ""))")
    }
}
