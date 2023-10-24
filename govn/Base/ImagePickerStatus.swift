
//  ImagePickerComponent.swift
//  TriggerBangIos
//
//  Created by CE on 2019/9/5.
//  Copyright © 2019 Mark. All rights reserved.
//

import Photos
import UIKit

public class ImagePicker{
    
    /****************************APP权限**************************************/
    /* .restricted     ---> 受限制，系统原因，无法访问
     * .notDetermined  ---> 系统还未知是否访问，第一次开启时
     * .authorized     ---> 允许、已授权
     * .denied         ---> 受限制，系统原因，无法访问
     */
    //MARK: 判断是否可访问相册
    //UIDevice.current.systemVersion >= 8.0
    ///相册权限---> 直接使用 <Photo方法 @available(iOS 8.0, *)>
    static func GetPhotoStatus(view:UIViewController,completion:@escaping((_ success:Bool)->Void) ){
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized) {
            completion(true)
        }
        else if (status == .restricted || status == .denied) {
  
            let alert = UIAlertController(title: "允許取用照片", message: "若要上傳照片，我們需要取用您的照片，請前往設定", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "設定", style: .default, handler:{(_)-> Void in
                completion(false)
                if let setting = URL(string: UIApplication.openSettingsURLString){
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(setting, completionHandler: {(sucess) in
                            //print(sucess)
                        })
                    } else {
                        UIApplication.shared.openURL(setting)
                    }
                }
            })
            let action2 = UIAlertAction(title: "稍後再說", style: .default, handler:{(_)->Void in
                completion(false)
            })
            alert.addAction(action2)
            alert.addAction(action1)
            view.present(alert ,animated: true,completion: nil)
        }
        else if (status == .notDetermined) {//首次使用
            PHPhotoLibrary.requestAuthorization({ (firstStatus) in
                let isTrue = (firstStatus == .authorized)
                if isTrue {
                    print("首次允许")
                    completion(true)
                } else {
                    print("首次不允许")
                    completion(false)
                }
            })
        }
    }
    
    
    //MARK: 判断是否可访问相机
    ///相机权限 ---> 直接调用
    static func GetCameraStatus(view:UIViewController,completion:@escaping((_ success:Bool)->Void) ){
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if (authStatus == .authorized) { /****已授权，可以打开相机****/
            completion(true)
        }
            
        else if (authStatus == .denied) {
            let alert = UIAlertController(title: "允許取用照片", message: "若要上傳照片，我們需要取用您的照片，請前往設定", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "設定", style: .default, handler:{(_)-> Void in
                completion(false)
                if let setting = URL(string: UIApplication.openSettingsURLString){
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(setting, completionHandler: {(sucess) in
                            //print(sucess)
                        })
                    } else {
                        UIApplication.shared.openURL(setting)
                    }
                }
            })
            let action2 = UIAlertAction(title: "稍後再說", style: .default, handler:{(_)->Void in
                completion(false)
            })
            alert.addAction(action2)
            alert.addAction(action1)
            view.present(alert ,animated: true,completion: nil)
        }
            
        else if (authStatus == .restricted) {//相机权限受限
            let alert = UIAlertController(title: "提示", message: "相機權限受限，無法使用", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "確定", style: .default, handler:{(_)-> Void in
                completion(false)
            })
            alert.addAction(action1)
            view.present(alert ,animated: true,completion: nil)
        }
            
        else if (authStatus == .notDetermined) {//首次 使用
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (statusFirst) in
                if statusFirst {
                    //用户首次允许
                    completion(true)
                } else {
                    //用户首次拒接
                    completion(false)
                }
            })
        }
    }
    
}
