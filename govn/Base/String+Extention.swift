//
//  String+Extention.swift
//  indogo
//
//  Created by mac on 2020/8/17.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

extension String {
    func utf8DecodedString()-> String {
        let data = self.data(using: .utf8)
        if let message = String(data: data!, encoding: .nonLossyASCII){
            return message
        }
        return ""
    }
    
    //取得限定範圍的字串(endIdex不含)
    func getSubString(Start startIndex:Int, EndNotInclude endIndex:Int)-> String {
        if startIndex >= self.count || endIndex > self.count {
            return ""
        }
        let start = self.index(self.startIndex, offsetBy: startIndex)
        let end = self.index(self.startIndex, offsetBy: endIndex)
        let sub_ans = String(self[start..<end])
        
        return sub_ans
    }
    
    func utf8EncodedString()-> String {
        let messageData = self.data(using: .nonLossyASCII)
        let text = String(data: messageData!, encoding: .utf8)!
        return text
    }
    
    //將字串轉成千分位含小數兩點的數字再回傳字傳
    func stringToDecimalString() -> String {
        let oriStr = self
        
        if oriStr == "null" {
            return ""
        }
        //先去掉逗號
        let str = oriStr.replacingOccurrences(of: ",", with: "")
        
        var strB = str
        if str.count==0 {
            strB = "0"
        }
        
        return stringToTwoFloatDecimalString(Number: (strB as NSString).doubleValue)
        
    }
    
    //將數字轉成千分位含小數兩點的數字再回傳字傳
    func stringToTwoFloatDecimalString(Number num:Double) -> String {
        
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.positiveFormat = "#,##0.00"
        //let formattedStr: String = formatter.string(from: NSNumber(value: Double(num)))!
        let formattedStr: String = formatter.string(for: num)!
        
        return formattedStr
    }
    
    //將字串轉成整數字再回傳字傳
    func stringToIntDecimalString() -> String {
        let oriStr = self
        
        if oriStr == "null" {
            return ""
        }
        //先去掉逗號
        let str = oriStr.replacingOccurrences(of: ",", with: "")
        
        var strB = str
        if str.count==0 {
            strB = "0"
        }
        
        return stringToIntDecimalString(Number: (strB as NSString).doubleValue)
        
    }
    
    //將數字轉成千分位含小數兩點的數字再回傳字傳 (這個版本是正確的)
    func stringToIntDecimalString(Number num:Double) -> String {
        
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.positiveFormat = "#,##0"
        //let formattedStr: String = formatter.string(from: NSNumber(value: Double(num)))!
        let formattedStr: String = formatter.string(for: num)!
        
        return formattedStr
    }
}
