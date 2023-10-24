//
//  ProvinceObj.swift
//
//  Created by mac on 2021/1/1.
//  Copyright © 2021 DIM. All rights reserved.
//

import UIKit

class ProvinceObj: NSObject {
    var province_id:String! = ""
    var province_name:String! = ""
    var allZone:[ZoneObj] = []
    
    public func appendZone(Zone obj:ZoneObj) {
        allZone.append(obj)
    }
}

class ZoneObj: NSObject {
    var district_id:String! = ""
    var district_name:String! = ""
}
