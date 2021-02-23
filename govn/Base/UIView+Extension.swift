//
//  UIView+Extension.swift
//  indogo
//
//  Created by mac on 2020/9/5.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

extension UIView {
    //對UIView做截圖
    func takeScreenshot() -> UIImage {

        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}

