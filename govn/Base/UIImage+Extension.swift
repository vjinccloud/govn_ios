//
//  UIImage+Extension.swift
//  indogo
//
//  Created by mac on 2020/8/1.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func fixedOrientationToLandscape() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            // This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }

        guard let cgImage = self.cgImage else {
            // CGImage is not available
            return nil
        }

        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }

        var transform: CGAffineTransform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }

        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }

        ctx.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }

        guard let newCGImage = ctx.makeImage() else { return nil }
        //如果要改成protrait就改成 .up
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .left)
    }
    
    //壓縮圖檔
    func ImgPress(LimitInBytes dataLimit:Int) -> Data{
        let img = self
        let limit = 1200
        let newWidth:CGFloat = 1000
        let width = img.size.width
        let height = img.size.height
        let scale = width/height
        var sizeChange = CGSize()
        
        var pressData = img.jpegData(compressionQuality: 0.5)
        var pressImg = UIImage(data: pressData!)
        
        if width <= CGFloat(limit),height<=CGFloat(limit) { //圖片寬度小於時圖片尺寸保持不變,不改變圖片大小
            
        }else{
            if(scale >= 1){
                let changedWidth:CGFloat = newWidth
                let changedheight:CGFloat = height / width * newWidth
                sizeChange = CGSize(width: changedWidth, height: changedheight)
            }
            else{
                let changedWidth:CGFloat = width / height * newWidth
                let changedheight:CGFloat = newWidth
                sizeChange = CGSize(width: changedWidth, height: changedheight)
            }
            
            
            
            UIGraphicsBeginImageContext(sizeChange)
            img.draw(in: CGRect(x: 0, y: 0, width: sizeChange.width, height: sizeChange.height))
            let resizedImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            pressData = resizedImg!.jpegData(compressionQuality: 1)
            pressImg = resizedImg!
        }
        
        //最多壓縮三次
        var count=0
        while count<3, pressData!.count > dataLimit {
            count+=1
            pressData = pressImg!.jpegData(compressionQuality: 0.5)
            pressImg = UIImage(data: pressData!)!
        }
        
        print(pressImg?.size)
        return pressData!
    }
    
    /*
    //壓縮圖檔
    func ImgPress(LimitInBytes dataLimit:Int) -> Data{
        let img = self
        let limit = 800
        let width = img.size.width
        let height = img.size.height
        let scale = width/height
        var sizeChange = CGSize()
        
        var pressData = img.jpegData(compressionQuality: 0.2)
        var pressImg = UIImage(data: pressData!)
        
        if width <= CGFloat(limit),height<=CGFloat(limit) { //圖片寬度小於時圖片尺寸保持不變,不改變圖片大小
            
        }else{
            if(scale >= 1){
                let changedWidth:CGFloat = 500
                let changedheight:CGFloat = height / width * 500
                sizeChange = CGSize(width: changedWidth, height: changedheight)
            }
            else{
                let changedWidth:CGFloat = width / height * 500
                let changedheight:CGFloat = 500
                sizeChange = CGSize(width: changedWidth, height: changedheight)
            }
            
            
            
            UIGraphicsBeginImageContext(sizeChange)
            img.draw(in: CGRect(x: 0, y: 0, width: sizeChange.width, height: sizeChange.height))
            let resizedImg = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            pressData = resizedImg!.jpegData(compressionQuality: 1)
            pressImg = resizedImg!
        }
        
        //最多壓縮三次
        var count=0
        while count<3, pressData!.count > dataLimit {
            count+=1
            pressData = pressImg!.jpegData(compressionQuality: 0.2)
            pressImg = UIImage(data: pressData!)!
        }
        
        print(pressImg?.size)
        return pressData!
    }*/
}
