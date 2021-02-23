//
//  UtilityTool.swift
//  indogo
//
//  Created by mac on 2020/7/11.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import CommonCrypto
import RSBarcodes_Swift
import AVFoundation

class UtilityTool {
    static let sharedInstance = UtilityTool()
    
    init() {}
    
    //MARK: - Generate BarCode QRCode
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    func generateBarCode39(from string: String) -> UIImage? {
        return RSUnifiedCodeGenerator.shared.generateCode(string, machineReadableCodeObjectType: AVMetadataObject.ObjectType.code39.rawValue)
    }
    
    //MARK: - Date
    func transferIndogoDate(Date lm_time:String) -> String {
        var show_time = ""
        let ary = lm_time.components(separatedBy:" ")
        let arySub = ary[0].components(separatedBy:"-")
        if arySub.count >= 2 {
            show_time = arySub[2] + "-" + arySub[1] + "-" + arySub[0]
        } else {
            show_time = lm_time
        }
        
        return show_time
    }
    
    func dateStringToTime(Str isoDate:String) -> Double {
        var time:Double = -1
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: isoDate) {
          // do something with date...
            time = date.timeIntervalSince1970
        }
        
        return time
    }
    
    func dateStringToDate(Str isoDate:String) -> Date {
        var ansDate = Date.init(timeIntervalSince1970: 0)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: isoDate) {
          // do something with date...
            ansDate = date
        }
        
        return ansDate
    }
    
    //MARK: - Utility
    func searchBankObj(BankName name:String) -> BankObj {
        for i in 0..<AppDelegate.shared().bankList.count {
            let obj = AppDelegate.shared().bankList[i]
            
            if obj.bank_name.lowercased() == name.lowercased() {
                return obj
            }
        }
        
        return BankObj()
    }
    
    func searchBankObj(BankCode code:String) -> BankObj {
        for i in 0..<AppDelegate.shared().bankList.count {
            let obj = AppDelegate.shared().bankList[i]
            
            if obj.bank_code == code {
                return obj
            }
        }
        
        return BankObj()
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func MD5(string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
    
    func sha256(Code code:String) -> String {
        if let stringData = code.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }
    
    private func digest(input: NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)

        var hexString = ""
        for byte in bytes {
            hexString += String(format: "%02x", UInt8(byte))
        }

        return hexString
    }
}
