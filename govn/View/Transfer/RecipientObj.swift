//
//  RecipientObj.swift
//  indogo
//
//  Created by mac on 2020/8/29.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

//recipient_id(30)recipient_name(30)bank_acc(30)bank_name(30)is_hidden
class RecipientObj: NSObject {
    var recipient_id:String! = ""
    var recipient_type:[Int] = []
    var recipient_name:String! = ""
    var id_card_no:String! = ""
    var phone_no:String! = ""
    var relationship:String! = ""
    var province_id:String! = ""
    var district_id:String! = ""
    var address:String! = ""
    var bank_acc:String! = ""
    var bank_code:String! = ""
    var bank_name:String! = ""
    var is_hidden:String! = ""
    
    public func getIdenticalFromObjExceptHidden(Obj obj:RecipientObj, AddBank addbank:Bool) {
        recipient_id = obj.recipient_id
        recipient_type = []
        for i in 0..<obj.recipient_type.count {
            recipient_type.append(obj.recipient_type[i])
        }
        recipient_name = obj.recipient_name
        id_card_no = obj.id_card_no
        phone_no = obj.phone_no
        relationship = obj.relationship
        province_id = obj.province_id
        district_id = obj.district_id
        address = obj.address
        if addbank {
            bank_acc = obj.bank_acc
            bank_code = obj.bank_code
            bank_name = obj.bank_name
        }
    }
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        if orderNum == 0 {
            recipient_id = valueStr
        } else if orderNum == 1 {
            recipient_name = valueStr
        } else if orderNum == 2 {
            bank_acc = valueStr
        } else if orderNum == 3 {
            bank_name = valueStr
        } else if orderNum == 4 {
            is_hidden = valueStr
        } else if orderNum == 5 {
            let ary = valueStr.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ",")
            for i in 0..<ary.count {
                let str = ary[i].trimmingCharacters(in: .whitespacesAndNewlines)
                if str == "1" || str == "2" || str == "3" {
                    recipient_type.append(Int(str)!)
                }
            }
        }
    }
    
    public func compareRecipient_type(Type type:Int) -> Bool {
        for i in 0..<recipient_type.count {
            let value = recipient_type[i]
            if value == type {
                return true
            }
        }
        
        return false
    }
    
    public func printSelf() {
        Dlog("recipient_id(\(recipient_id ?? "")), recipient_name(\(recipient_name ?? "")), bank_acc(\(bank_acc ?? "")), bank_name(\(bank_name ?? "")), is_hidden(\(is_hidden ?? "")), id_card_no(\(id_card_no ?? "")), phone_no(\(phone_no ?? "")))")
    }
}
