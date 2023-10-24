//
//  ARCInputVC.swift
//
//  Created by mac on 2020/11/25.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation
import Alamofire

class ARCInputVC: UIViewController, UITextFieldDelegate, CustomAlertDelegate {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var allCodeTextField: UITextField!
    @IBOutlet weak var textBackV: UIView!
    
    public var fromType:ScanParentType = ScanParentType.forgotPass
    
    //MARK: - Utility
    func customAlertnextAction(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
    }
    
    func customAlertnextActionSecond(Ref obj: CustomAlertView) {
        
    }
    
    func scanNext(Code code:String) {
        
        //檢查限制為 C,D,8,9 其餘跳出格式錯誤
        //"scan format wrong"
        var checkedWrong = true
        if code.count < 2 {
            checkedWrong = true
        } else {
            
            if code.count != 10 {
                checkedWrong = true
            } else {
                let singleWord = code.getSubString(Start: 1, EndNotInclude: 2).lowercased()
                Dlog("singleWord = \(singleWord)")
                if singleWord == "c" || singleWord == "d" || singleWord == "8" || singleWord == "9" {
                    checkedWrong = false
                }
            }
        }
        
        if checkedWrong {
            
            let window = UIApplication.shared.keyWindow
            let customAlert = CustomAlertView.init(frame: self.view.frame)
            customAlert.initSimpleAlert(Title: "", Content: NSLocalizedString("scan format wrong" , comment: ""), NextBtn1Str: NSLocalizedString("ok2" , comment: ""))
            window!.addSubview(customAlert)
            customAlert.customDelegate = self
            return
        }
        
        let parameters:Parameters = ["arc_no":code]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_CheckMemExist;
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("responseStr = \(responseStr ?? "")")
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                AppDelegate.shared().forgotPassTempMemID = code
                if result == ResponseState.ok {
                    if self.fromType == .register { //回登入畫面帶入帳密？
                        AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("Register Member Exist" , comment: ""))
                        self.navigationController?.popToRootViewController(animated: true)
                    } else if self.fromType == .forgotPass {
                        //有電話
                        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassCheckPhoneVC") as? ForgotPassCheckPhoneVC
                        nextVC?.checkType = 0
                        self.navigationController?.pushViewController(nextVC!, animated: true)
                    }
                    
                } else if result == ResponseState.member_not_exist {
                    //會員不存在，註冊
                    if self.fromType == .register { //回到註冊畫面
                        guard let viewControllers = self.navigationController?.viewControllers else {
                            return
                        }

                        for firstViewController in viewControllers {
                            if firstViewController is RegisterInputVC {
                                let nextVC = firstViewController as! RegisterInputVC
                                nextVC.setArcCodeString(Code: code)
                                self.navigationController?.popToViewController(nextVC, animated: true)
                                break
                            }
                        }
                        
                        return
                    } else if self.fromType == .forgotPass {
                        //要顯示錯誤
                        let alert = UIAlertController(title: NSLocalizedString("Incorrect ARC Number", comment: ""), message: NSLocalizedString("Please input Your ARC number correctly", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("ok2", comment: ""), style: .default) { action in
                        })
                        self.present(alert, animated: true)
                        
                        /*
                        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassCheckPhoneVC") as? ForgotPassCheckPhoneVC
                        nextVC?.checkType = 1
                        self.navigationController?.pushViewController(nextVC!, animated: true)*/
                    }
                    
                    /*
                    let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassCheckPhoneVC") as? ForgotPassCheckPhoneVC
                    nextVC?.checkType = 1
                    self.navigationController?.pushViewController(nextVC!, animated: true)*/
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        if allCodeTextField.text == "" {
            AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("Please Enter Number", comment: ""))
            return
        }
        scanNext(Code: allCodeTextField.text!)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Text Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = Color_Main_Red
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = Color_Main_DarkGray
    }
    
    /*
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else{
            return true
        }
        let textLength = text.count + string.count - range.length
        if string.count == 1 {
            if textField == codeT1 {
                codeT1.text = string
                codeT1.resignFirstResponder()
                codeT2.becomeFirstResponder()
            } else if textField == codeT2 {
                codeT2.text = string
                codeT2.resignFirstResponder()
                codeT3.becomeFirstResponder()
            } else if textField == codeT3 {
                codeT3.text = string
                codeT3.resignFirstResponder()
                codeT4.becomeFirstResponder()
            } else if textField == codeT4 {
                codeT4.text = string
                codeT4.resignFirstResponder()
            }
            return false
        } else {
        }
    
        return textLength <= 1
    }
    */
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        backL.text = NSLocalizedString("back", comment: "")
        nextBtn.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.height/2
        titleL.text = NSLocalizedString("Please input Your ARC number", comment: "")
        
        textBackV.layer.cornerRadius = textBackV.frame.height/2
        allCodeTextField.keyboardType = .asciiCapable
        
        /*
        codeT1.backgroundColor = Color_Main_DarkGray
        codeT1.keyboardType = .numberPad
        codeT1.textColor = .white
        codeT1.delegate = self
        codeT2.backgroundColor = Color_Main_DarkGray
        codeT2.keyboardType = .numberPad
        codeT2.delegate = self
        codeT3.backgroundColor = Color_Main_DarkGray
        codeT3.keyboardType = .numberPad
        codeT3.delegate = self
        codeT4.backgroundColor = Color_Main_DarkGray
        codeT4.keyboardType = .numberPad
        codeT4.delegate = self
        */
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
