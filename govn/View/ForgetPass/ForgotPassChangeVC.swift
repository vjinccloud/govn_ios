//
//  ForgotPassChangeVC.swift
//  indogo
//
//  Created by mac on 2020/7/18.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ForgotPassChangeVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var warnL: UILabel!
    @IBOutlet weak var warn2L: UILabel!
    @IBOutlet weak var passBtn: UIButton!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var showPassBtn: UIButton!
    @IBOutlet weak var repassBtn: UIButton!
    @IBOutlet weak var repassTextField: UITextField!
    @IBOutlet weak var showRePassBtn: UIButton!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    //MARK: - Utility
    func checkState() {
        if passTextField.text!.count>0, repassTextField.text!.count>0 {
            nextBtn.isEnabled = true
            nextBtn.backgroundColor = Color_Main_Red
        } else {
            nextBtn.isEnabled = false
            nextBtn.backgroundColor = .clear
        }
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        
        if passTextField.text != repassTextField.text {
            AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("Register Error Pass Not match", comment: ""))
            return
        }
        
        if passTextField.text!.count < 4 {
            AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("Register Error Pass", comment: ""))
            return
        }
        
        let parameters:Parameters = ["arc_no":AppDelegate.shared().forgotPassTempMemID, "password":UtilityTool().sha256(Code: passTextField.text!), "sms_code":AppDelegate.shared().forgotPassTempEnterCode]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_PassUpdate;
        AppDelegate.shared().alamofireManagerWithTimeout.request(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
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
                
                if result == ResponseState.ok {
                    self.navigationController?.popToRootViewController(animated: true)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showPassAction(_ sender: Any) {
        passTextField.isSecureTextEntry.toggle()
        
        if passTextField.isSecureTextEntry {
            showPassBtn.setBackgroundImage(UIImage.init(named: "noview_b"), for: .normal)
        } else {
            showPassBtn.setBackgroundImage(UIImage.init(named: "view_w"), for: .normal)
        }
    }
    
    @IBAction func showRePassAction(_ sender: Any) {
        repassTextField.isSecureTextEntry.toggle()
        
        if repassTextField.isSecureTextEntry {
            showRePassBtn.setBackgroundImage(UIImage.init(named: "noview_b"), for: .normal)
        } else {
            showRePassBtn.setBackgroundImage(UIImage.init(named: "view_w"), for: .normal)
        }
    }
    
    //MARK: - Text Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == passTextField {
            passBtn.backgroundColor = Color_Main_LightGray
            warnL.isHidden = false
        } else if textField == repassTextField {
            repassBtn.backgroundColor = Color_Main_LightGray
            warn2L.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == passTextField {
            passBtn.backgroundColor = Color_Main_DarkGray
            warnL.isHidden = true
        } else if textField == repassTextField {
            repassBtn.backgroundColor = Color_Main_DarkGray
            warn2L.isHidden = true
        }
        checkState()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        backL.text = NSLocalizedString("TFFRHP Change Title", comment: "")
        passBtn.layer.cornerRadius = passBtn.frame.size.height/2
        repassBtn.layer.cornerRadius = repassBtn.frame.size.height/2
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        
        passTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("passcode", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        repassTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("TFFRHP Change placehold2", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        nextBtn.setTitle(NSLocalizedString("submit Upper", comment: ""), for: .normal)
        nextBtn.backgroundColor = .clear
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        nextBtn.layer.borderWidth = 0.5
        
        nextBtn.isEnabled = false
        passTextField.isSecureTextEntry = true
        repassTextField.isSecureTextEntry = true
        
        passTextField.delegate = self
        repassTextField.delegate = self
        
        warnL.text = NSLocalizedString("TFFRHP Change warn", comment: "")
        warn2L.text = NSLocalizedString("TFFRHP Change warn2", comment: "")
        warnL.isHidden = true
        warn2L.isHidden = true
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
