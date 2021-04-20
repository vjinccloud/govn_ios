//
//  PointHistorySingleObj.swift
//  indogo
//
//  Created by mac on 2020/8/19.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class PointHistorySingleObj: NSObject {
    var lm_time:String! = ""
    var show_time:String! = ""
    var remit_point:String! = ""
    var reason_id:String! = ""
    var friend_name:String! = ""
    var reason_desc:String! = ""
    var reason_show:String! = ""
    var show_point = 0
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        if orderNum == 0 {
            lm_time = valueStr
            let ary = lm_time.components(separatedBy:" ")
            let arySub = ary[0].components(separatedBy:"-")
            if arySub.count >= 2 {
                show_time = arySub[2] + "/" + arySub[1] + "/" + arySub[0]
            } else {
                show_time = valueStr
            }
            
        } else if orderNum == 1 {
            remit_point = valueStr
        } else if orderNum == 2 {
            reason_id = valueStr
            switch reason_id {
            case "1" : reason_show = NSLocalizedString("reason_show1", comment: "")//"app download bonus"
            case "2" : reason_show = NSLocalizedString("reason_show2", comment: "")//"app share bonus"
            case "3" : reason_show = NSLocalizedString("reason_show3", comment: "")//"app create invoice bonus"
            case "4" : reason_show = NSLocalizedString("reason_show4", comment: "")//"redeem point for free service charge"
            case "5" : reason_show = NSLocalizedString("reason_show5", comment: "")//"manual"
            case "6" : reason_show = NSLocalizedString("reason_show6", comment: "")//"bonus for each 100 remit transactions"
            case "7" : reason_show = NSLocalizedString("reason_show7", comment: "")//"bonus for each 50 friends invited"
            case "8" : reason_show = NSLocalizedString("reason_show8", comment: "")//"birthday bonus"
            case "9" : reason_show = NSLocalizedString("reason_show9", comment: "")//"special occassion bonus"
            case "10" : reason_show = NSLocalizedString("reason_show10", comment: "")//"create invoice"
            case "11" : reason_show = NSLocalizedString("reason_show11", comment: "")//"scrap invoice"
            case "12" : reason_show = NSLocalizedString("reason_show12", comment: "")//"roulette"
            case "13" : reason_show = NSLocalizedString("reason_show13", comment: "")//"transfer point to remit system member"
            case "14" : reason_show = NSLocalizedString("reason_show14", comment: "")//"transfer point to web shop member"
            default : reason_show = ""
            }
            
        } else if orderNum == 3 {
            friend_name = valueStr
        } else if orderNum == 4 {
            reason_desc = valueStr
        }
    }
    
    public func printSelf() {
        Dlog("lm_time(\(lm_time ?? "")), remit_point(\(remit_point ?? "")), reason_id(\(reason_id ?? "")), friend_name(\(friend_name ?? "")), reason_desc(\(reason_desc ?? ""))")
    }
}
