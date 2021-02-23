//
//  Log.swift
//  BayPay
//
//  Created by mac on 2020/3/25.
//  Copyright © 2020 BayPay. All rights reserved.
//

import UIKit

/*
//取代原先的print，只在Debug模式印出資料
func Dlog(items: Any..., separator: String = " ", terminator: String = "\n") {

    #if DEBUG

    var idx = items.startIndex
    let endIdx = items.endIndex

    repeat {
        Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
        idx += 1
    }
    while idx < endIdx
    #endif
}
*/

//取代原先的print，只在Debug模式印出資料
func Dlog(_ item: @autoclosure () -> Any, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    
    #if DEBUG
    print("\(Date()) [\((file as NSString).lastPathComponent):\(line) \(function)] \(item())")
    #endif
    
}


