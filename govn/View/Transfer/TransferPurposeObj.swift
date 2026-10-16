//
//  TransferPurposeObj.swift
//  govn
//
//  移植自 GoPadala（compliance-202610 匯款目的）
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit

//匯款目的：transfer_purpose 回傳的一列（id、name）
class TransferPurposeObj: NSObject {
    var idx:String! = ""
    var name:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        if orderNum == 0 {
            idx = valueStr
        } else if orderNum == 1 {
            name = valueStr
        }
    }
    
    public func printSelf() {
        Dlog("purpose_id(\(idx ?? "")), purpose_name(\(name ?? ""))")
    }
}
