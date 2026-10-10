//
//  TransfePreCountVC.swift
//  govn
//
//  Created by Wang Jen Chung on 2026/5/4.
//  Copyright © 2026 DIM. All rights reserved.
//

import Alamofire
import SwiftyJSON

class TransfePreCountVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var inputMoreSpaceView: UIView!
    @IBOutlet weak var backL: UILabel!
    
    @IBOutlet weak var topScrollView: UIScrollView!
    
    @IBOutlet weak var phoneNewTitle: UILabel!
    @IBOutlet weak var phoneNewView: UIView!
    @IBOutlet weak var phoneNewBtn: UIButton!
    @IBOutlet weak var phoneNewTextfield: UITextField!
    
    @IBOutlet weak var phoneNewWarnL: UILabel!
    @IBOutlet weak var bottomAmountL: UILabel!
    @IBOutlet weak var bottomTimeL: UILabel!
    @IBOutlet weak var bottomBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var bottomV: UIView!
    @IBOutlet weak var bottomIconV: UIImageView!
    
    @IBOutlet weak var barV: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorL: UILabel!
    
    var hasSharedCode = false
    var hasMeCode = false
    var meImg:UIImage!
    var loadOnce = false
    
    //MARK: - Text Bar
    func generateToolBar() ->UIToolbar {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextBarAction))
        
        let toolBar:UIToolbar = UIToolbar()
        toolBar.items = [flexibleSpace,done]
        toolBar.sizeToFit()
        
        return toolBar
    }
    
    @objc func nextBarAction() {
        phoneNewTextfield.resignFirstResponder()
    }
    
    //MARK: - Text Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        phoneNewTextfield.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        inputMoreSpaceView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputMoreSpaceView.isHidden = true
        
        checkNextBtnState(CheckText: true)
    }
    
    func checkNextBtnState(CheckText checkNow:Bool) {
        var pass = true
        
        if phoneNewTextfield.text == "" {
            pass = false
        }
        
        if pass {
            registerBtn.setTitleColor(.white, for: .normal)
            registerBtn.backgroundColor = Color_Main_Red
            registerBtn.isEnabled = true
            phoneNewWarnL.isHidden = true
        } else {
            registerBtn.backgroundColor = .clear
            registerBtn.setTitleColor(Color_Main_Red, for: .normal)
            registerBtn.isEnabled = false
            phoneNewWarnL.isHidden = false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else{
            return true
        }
        
        let textLength = text.count + string.count - range.length
        if textLength>20 {
            return false
        }
        
        return true

    }
    
    //MARK: - View-Life
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            return
        }
        loadOnce = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        backL.text = NSLocalizedString("Pre TransferAccount Head", comment: "")
        phoneNewTitle.text = NSLocalizedString("Pre TransferAccount Title", comment: "")
        phoneNewWarnL.text = NSLocalizedString("Pre TransferAccount Wrong", comment: "")
        
        phoneNewBtn.layer.cornerRadius = phoneNewBtn.frame.size.height/2
        phoneNewTextfield.delegate = self
        phoneNewTextfield.inputAccessoryView = generateToolBar()
        phoneNewTextfield.placeholder = NSLocalizedString("", comment: "")
        
        phoneNewWarnL.isHidden = true
        bottomBtn.layer.cornerRadius = bottomBtn.frame.size.height/2
        
        registerBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        registerBtn.setTitleColor(Color_Main_Red, for: .normal)
        registerBtn.layer.backgroundColor = UIColor.clear.cgColor
        registerBtn.layer.cornerRadius = registerBtn.frame.size.height/2
        registerBtn.layer.borderColor = Color_Main_Red.cgColor
        registerBtn.layer.borderWidth = 0.5
        checkNextBtnState(CheckText: false)
        phoneNewWarnL.isHidden = true
        bottomV.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
    }
    
    //MARK: - API
    func checkCode() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "discount_code":phoneNewTextfield.text!, "mobile_type":"iphone", "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_CheckDiscountCode;
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
                    self.phoneNewWarnL.isHidden = true
                    self.bottomV.isHidden = false
                    self.bottomAmountL.text = "\(NSLocalizedString("Pre TransferAccount Bottom Amount Pre", comment: "")) \(AppDelegate.shared().tempDiscountCodeResultAry[0]) NTD \(NSLocalizedString("Pre TransferAccount Bottom Amount", comment: ""))"
                    if AppDelegate.shared().tempDiscountCodeResultAry[1] == "2" {
                        //self.bottomTimeL.isHidden = false
                        self.bottomTimeL.text = "\(NSLocalizedString("Pre TransferAccount Bottom Time", comment: "")) \(AppDelegate.shared().tempDiscountCodeResultAry[3])"
                    } else {
                        //self.bottomTimeL.isHidden = true
                        self.bottomTimeL.text = "\(NSLocalizedString("Pre TransferAccount Bottom Time", comment: "")) \(AppDelegate.shared().tempDiscountCodeResultAry[3])"
                    }
                    
                    self.showBottomVState(state: Int(AppDelegate.shared().tempDiscountCodeResultAry[4]) ?? 0)
                
                    
                } else if result == ResponseState.failed {
                    self.phoneNewWarnL.isHidden = false
                    //AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func showBottomVState(state:Int) {
        if state == 0 {
            bottomV.alpha = 1
            bottomV.layer.backgroundColor = UIColor.white.cgColor
            bottomBtn.setTitle(NSLocalizedString("Pre TransferAccount Bottom Available", comment: ""), for: .normal)
            bottomIconV.image = UIImage.init(named: "newikon.png")
            bottomBtn.setTitleColor(.white, for: .normal)
            bottomBtn.backgroundColor = Color_Main_Red
            bottomBtn.layer.borderWidth = 0
            bottomBtn.isUserInteractionEnabled = true
            phoneNewWarnL.isHidden = true
        } else if state == 1 {
            bottomV.alpha = 1
            bottomV.layer.backgroundColor = UIColor.white.cgColor
            bottomBtn.setTitle(NSLocalizedString("Pre TransferAccount Bottom Used", comment: ""), for: .normal)
            bottomIconV.image = UIImage.init(named: "newikon.png")
            bottomBtn.layer.backgroundColor = UIColor.white.cgColor
            bottomBtn.backgroundColor = .clear
            bottomBtn.isUserInteractionEnabled = false
            bottomBtn.setTitleColor(Color_Main_Red, for: .normal)
            bottomBtn.layer.borderColor = Color_Main_Red.cgColor
            bottomBtn.layer.borderWidth = 1
            phoneNewWarnL.isHidden = false
        } else if state == 2 {
            bottomV.alpha = 0.7
            bottomV.layer.backgroundColor = UIColor.gray.cgColor
            bottomBtn.setTitle(NSLocalizedString("Pre TransferAccount Bottom Expired", comment: ""), for: .normal)
            bottomIconV.image = bottomIconV.image?.withRenderingMode(.alwaysTemplate)
            bottomIconV.tintColor = .darkGray
            bottomBtn.backgroundColor = .clear
            bottomBtn.layer.backgroundColor = UIColor.darkGray.cgColor
            bottomBtn.layer.borderWidth = 0
            bottomBtn.setTitleColor(.white, for: .normal)
            bottomBtn.isUserInteractionEnabled = false
            phoneNewWarnL.isHidden = false
        }
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        checkCode()
    }
    
    @IBAction func bottomBtnAction(_ sender: Any) {
        AppDelegate.shared().changeRootOfFunc(Type: .transaction, discountForTransfer: AppDelegate.shared().tempDiscountCodeResultAry[0], discountCode: self.phoneNewTextfield.text ?? "")
     }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
