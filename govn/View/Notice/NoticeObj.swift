//
//  NoticeObj.swift
//  indogo
//
//  Created by mac on 2020/8/17.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class NoticeObj: NSObject {
    var idStr:String! = ""
    var title:String! = ""
    var content:String! = ""
    var readable:String! = ""
    var tpyeStr:String! = ""
    var createTime:String! = ""
    var photo:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        if orderNum == 0 {
            idStr = valueStr
        } else if orderNum == 1 {
            title = valueStr
        } else if orderNum == 2 {
            content = valueStr
        } else if orderNum == 3 {
            readable = valueStr
        } else if orderNum == 4 {
            tpyeStr = valueStr
        } else if orderNum == 5 {
            createTime = valueStr
        } else if orderNum == 6 {
            photo = valueStr
        }
    }
    
}
