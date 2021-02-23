//
//  UIViewController+TapToDissmiss.swift
//  TriggerBangIos
//
//  Created by mac on 2020/5/27.
//  Copyright © 2020 Mark. All rights reserved.
//
//這程式碼使用之後，只需在 viewDidLoad 加上
//self.setupHideKeyboardOnTap()
//便可以在點擊空白處收掉鍵盤

import UIKit
extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.closeKeyboardNow),
            name: Notification.Name("closeKeyboard"),
            object: nil)
        
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }

    /// Dismisses the keyboard from self.view
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
    
    @objc private func closeKeyboardNow(notification: NSNotification){
        //do stuff using the userInfo property of the notification object
        view.endEditing(true)
    }
}
