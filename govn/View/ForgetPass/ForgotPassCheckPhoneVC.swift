//
//  ForgotPassCheckPhoneVC.swift
//  indogo
//
//  Created by mac on 2020/7/16.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation
import Alamofire

class ForgotPassCheckPhoneVC: UIViewController {
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var introL: UILabel!
    @IBOutlet weak var memIDL: UILabel!
    @IBOutlet weak var msgL: UILabel!
    @IBOutlet weak var downBtn: UIButton!
    @IBOutlet weak var upBtn: UIButton!
    
    public var checkType:Int = 0
    
    //MARK: - API
    func sendSMS() {
        let parameters:Parameters = ["arc_no":AppDelegate.shared().forgotPassTempMemID, "phone_no":AppDelegate.shared().forgotPassTempPhone]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_SendSMS;
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
                
                if result == ResponseState.ok {
                    let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassEnterCodeVC") as? ForgotPassEnterCodeVC
                    self.navigationController?.pushViewController(nextVC!, animated: true)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func upAction(_ sender: Any) {
        if checkType == 0 { //忘記密碼下一步
            sendSMS()
        } else if checkType == 1 { //再次掃描(回上一頁)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func downAction(_ sender: Any) {
        if checkType == 0 { //取消回上一頁
            self.navigationController?.popViewController(animated: true)
        } else if checkType == 1 { //註冊
            AppDelegate.shared().hasArcResultAndGotoRegister = true
            AppDelegate.shared().arcScanReulstForRegister = AppDelegate.shared().forgotPassTempMemID
            let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterAgreementVC") as? RegisterAgreementVC
            self.navigationController?.pushViewController(nextVC!, animated: true)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("TFFRHP Msg Register Title", comment: "")
        introL.text = NSLocalizedString("top for forget result has phone", comment: "")
        memIDL.text = AppDelegate.shared().forgotPassTempMemID
        memIDL.adjustsFontSizeToFitWidth = true
        
        upBtn.layer.cornerRadius = upBtn.frame.size.height/2
        downBtn.layer.cornerRadius = downBtn.frame.size.height/2
        
        
        if checkType == 0 { //電話
            msgL.text = NSLocalizedString("TFFRHP Msg Top", comment: "") + "\n\n" + AppDelegate.shared().forgotPassTempPhone + "\n\n" + NSLocalizedString("TFFRHP Msg End", comment: "")
            
            upBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
            downBtn.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
            
            upBtn.backgroundColor = Color_Main_Red
            upBtn.setTitleColor(.white, for: .normal)
            
            downBtn.backgroundColor = .clear
            downBtn.setTitleColor(.white, for: .normal)
            downBtn.layer.borderWidth = 0.5
            downBtn.layer.borderColor = Color_Main_Red.cgColor
            
        } else if checkType == 1 { //可以註冊
            msgL.text = NSLocalizedString("TFFRHP Msg Register Top", comment: "")
            upBtn.setTitle(NSLocalizedString("scan again", comment: ""), for: .normal)
            downBtn.setTitle(NSLocalizedString("register Upper", comment: ""), for: .normal)
            
            upBtn.backgroundColor = .clear
            upBtn.layer.borderWidth = 0.5
            upBtn.layer.borderColor = Color_Main_Red.cgColor
            upBtn.setTitleColor(.white, for: .normal)
            
            downBtn.setTitleColor(.black, for: .normal)
            downBtn.backgroundColor = .white
        }
        
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
