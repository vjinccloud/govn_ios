//
//  ViewController.swift
//  indogo
//
//  Created by mac on 2020/7/9.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase
import WebKit

class ViewController: UIViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource, UITextFieldDelegate, CustomAlertDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var accountBtn: UIButton!
    @IBOutlet weak var accountTextfield: UITextField!
    
    @IBOutlet weak var warnWebV: WKWebView!
    @IBOutlet weak var midAddressL: UILabel!
    @IBOutlet weak var midNumL: UILabel!
    @IBOutlet weak var passBtn: UIButton!
    @IBOutlet weak var passTextField: UITextField!
    
    @IBOutlet weak var introL: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var remeberBtn: UIButton!
    
    @IBOutlet weak var bottomL: UILabel!
    @IBOutlet weak var lupaBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var showPassBtn: UIButton!
    @IBOutlet weak var topScrollView: UIScrollView!
    @IBOutlet weak var promoView: UIView!
    @IBOutlet weak var promoPageCtrl: UIPageControl!
    var promoNum = 0
    var promoPageVC: NSMutableArray!
    var pageController: UIPageViewController!
    var currentPageIndex = 0
    
    var loadOnce:Bool = false
    var rememberMeState = true
    
    //MARK: - Button-Action
    @IBAction func showPassAction(_ sender: Any) {
        passTextField.isSecureTextEntry.toggle()
        
        if passTextField.isSecureTextEntry {
            showPassBtn.setBackgroundImage(UIImage.init(named: "noview_w"), for: .normal)
        } else {
            showPassBtn.setBackgroundImage(UIImage.init(named: "view_w"), for: .normal)
        }
    }
    
    @IBAction func rememberMeAction(_ sender: Any) {
        if rememberMeState {
            rememberMeState = false
            remeberBtn.setImage(UIImage.init(named: "unselect.png"), for: .normal)
        } else {
            rememberMeState = true
            remeberBtn.setImage(UIImage.init(named: "select.png"), for: .normal)
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if accountTextfield.text?.count == 0 {
            //AppDelegate.shared().showAlertWithWindow(self, Message: "請輸入帳號\n123")
            return
        }
        
        if passTextField.text?.count == 0 {
            //AppDelegate.shared().showAlertWithWindow(self, Message: "請輸入密碼")
            return
        }
        
        loginNext()
    }
    
    @IBAction func forgotPassAction(_ sender: Any) {
        Analytics.logEvent("iOS_ForgotPass", parameters: nil)
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassMainVC") as? ForgotPassMainVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func registAction(_ sender: Any) {
        Analytics.logEvent("iOS_Regist", parameters: nil)
        //RegisterAgreementVC
        //進入註冊
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterAgreementVC") as? RegisterAgreementVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
        /*
        let customAlert = CustomAlertView.init(frame: topScrollView.frame)
        customAlert.initAlert(Title: NSLocalizedString("Main Register Alert Title" , comment: ""), Content: NSLocalizedString("Main Register Alert Content" , comment: ""), NextBtn1Str: NSLocalizedString("agree" , comment: ""), CancelBtn1Str: NSLocalizedString("cancel" , comment: ""))
        self.view.addSubview(customAlert)
        customAlert.customDelegate = self
         */
    }
    
    func customAlertnextAction(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        
        //進入註冊
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterAgreementVC") as? RegisterAgreementVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    func customAlertnextActionSecond(Ref obj: CustomAlertView) {
        
    }
    
    //MARK: - API
    func checkTokenLogin() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_CheckLogin;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
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
                    AppDelegate.shared().nowBottomMenuType = AppDelegate.shared().defautBottomMenuType
                    AppDelegate.shared().changeRootOfFunc(Type: .transaction)
                    /*
                    //檢查版本
                    let appVersionFromBackend = Float(AppDelegate.shared().memberData["app_version"]!)
                    let appVersionInApp = Float((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!)
                    Dlog("appVersionFromBackend = \(appVersionFromBackend ?? 0), appVersionInApp = \(appVersionInApp ?? 0)")
                    if appVersionFromBackend! > appVersionInApp! {
                        DispatchQueue.main.async{
                            let alert = UIAlertController(title: "", message: NSLocalizedString("Please Update App", comment: ""), preferredStyle: .alert)
                            let action1 = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler:{(_)-> Void in
                                let urlString:String = AppDelegate.shared().memberData["app_market"]!
                                
                                if let phoneCallURL = URL(string: urlString) {
                                    if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                                        UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
                                    }
                                    exit(0)
                                }
                            })
                            alert.addAction(action1)
                            let window = UIApplication.shared.keyWindow
                            window?.rootViewController!.present(alert ,animated: true,completion: nil)
                        }
                        return
                    }*/
                    
                    //傳輸token
                    self.sendToken()
                    
                    //讀取未讀通知數量
                    AppDelegate.shared().getNotice()
                    URLCache.shared.removeAllCachedResponses()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().userLogout()
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func loginNext() {
        let parameters:Parameters = ["login_id":accountTextfield.text!, "login_password": UtilityTool().sha256(Code: passTextField.text!)]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_Login;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        URLCache.shared.removeAllCachedResponses()
        
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
                    //檢查版本(之後要改成新欄位)
                    /*
                    let appVersionFromBackend = Float(AppDelegate.shared().memberData["app_version"]!)
                    let appVersionInApp = Float((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!)
                    Dlog("appVersionFromBackend = \(appVersionFromBackend ?? 0), appVersionInApp = \(appVersionInApp ?? 0)")
                    if appVersionFromBackend! > appVersionInApp! {
                        DispatchQueue.main.async{
                            let alert = UIAlertController(title: "", message: NSLocalizedString("Please Update App", comment: ""), preferredStyle: .alert)
                            let action1 = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler:{(_)-> Void in
                                let urlString:String = AppDelegate.shared().memberData["app_market"]!
                                
                                if let phoneCallURL = URL(string: urlString) {
                                    if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                                        UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
                                    }
                                    exit(0)
                                }
                            })
                            alert.addAction(action1)
                            let window = UIApplication.shared.keyWindow
                            window?.rootViewController!.present(alert ,animated: true,completion: nil)
                        }
                        return
                    }*/
                    //傳輸token
                    self.sendToken()
                    
                    //會員資料編輯要顯示的
                    AppDelegate.shared().rememberAarcNo(Account: self.accountTextfield.text!)
                    //讀取未讀通知數量
                    AppDelegate.shared().getNotice()
                    if self.rememberMeState {
                        AppDelegate.shared().rememberAccount(Account: self.accountTextfield.text!, Pass: self.passTextField.text!)
                    } else {
                        AppDelegate.shared().removeSavedAccount()
                    }
                    
                    AppDelegate.shared().nowBottomMenuType = AppDelegate.shared().defautBottomMenuType
                    AppDelegate.shared().changeRootOfFunc(Type: .transaction)
                    //AppDelegate.shared().showAlertWithWindow(self, Message: "Hi, \(AppDelegate.shared().memberData["member_name"] ?? "") 登入成功")
                    URLCache.shared.removeAllCachedResponses()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func sendToken() {
        if FirebaseToken == "" {
            return
        }
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken,"device_token":FirebaseToken]
        let headers: HTTPHeaders = [:]
        
        let todoEndpoint: String = API_PhoneTokenSet;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("responseStr = \(responseStr ?? "")")
        }
    }
    
    func getPromo() {
        
        let parameters:Parameters = [:]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_Promo;
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
                    
                    self.promoNum = AppDelegate.shared().promoUrlAry.count
                    self.setController()
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func getInfo() {
        
        let parameters:Parameters = ["token":"dxeqD0g9aq/XApD3rZMJKQ==", "timestamp":"ajhkhdfs"]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_GetInfo;
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
                //Dlog("responseStr = \(responseStr ?? "")")
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    var str = ""
                    if AppDelegate.shared().getInfoStrAry.count>=8 {
                        for i in 0...3 {
                            if i>0 {
                                str += "\n"
                            }
                            str += AppDelegate.shared().getInfoStrAry[i]
                        }
                        
                        str += "\n" + AppDelegate.shared().getInfoStrAry[7]
                        str += "\n" + AppDelegate.shared().getInfoStrAry[8]
                        
                        self.midNumL.text = AppDelegate.shared().getInfoStrAry[5]
                        self.midAddressL.text = AppDelegate.shared().getInfoStrAry[4] + "\n" + AppDelegate.shared().getInfoStrAry[6]
                        self.introL.text = str
                        self.bottomL.text = AppDelegate.shared().getInfoStrAry[7] + "\n" + AppDelegate.shared().getInfoStrAry[8]
                    }
                    
                    let userDefaults = UserDefaults.standard
                    if !AppDelegate.shared().firstOpenApp, self.accountTextfield.text != "", userDefaults.value(forKey: "sessionToken") != nil {
                        self.loginNext()
                    }
                    
                    AppDelegate.shared().firstOpenApp = true
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Page
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // 取得當前頁數的 index(未翻頁前)
        let currentIndex: Int =  self.promoPageVC.index(of: viewController)
        
        // 設定上一頁的 index
        let priviousIndex: Int = currentIndex - 1
        self.promoPageCtrl.currentPage = priviousIndex < 0 ? priviousIndex : currentIndex
        // 判斷上一頁的 index 是否小於 0，若小於 0 則停留在當前的頁數
        return priviousIndex < 0 ? nil : self.promoPageVC![priviousIndex] as? PromoPageVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // 取得當前頁數的 index(未翻頁前)
        let currentIndex: Int =  self.promoPageVC.index(of: viewController)
        
        // 設定下一頁的 index
        let nextIndex: Int = currentIndex + 1
        self.promoPageCtrl.currentPage = nextIndex > self.promoPageVC.count - 1 ? nextIndex : currentIndex
        // 判斷下一頁的 index 是否大於總頁數，若大於則停留在當前的頁數
        return nextIndex > self.promoPageVC.count - 1 ? nil : self.promoPageVC![nextIndex] as? PromoPageVC
    }
    
    @objc func nextPromo(_ sender: Any) {
        let tag = (sender as! UIButton).tag
        if tag == (AppDelegate.shared().promoUrlAry.count-1) {
            endPromo()
        } else {
            self.promoPageCtrl.currentPage = tag+1
            self.pageController.setViewControllers([(self.promoPageVC![tag+1] as? PromoPageVC)!], direction: .forward, animated: true, completion: nil)
        }
    }
    
    
    func endPromo() {
        self.promoView.removeFromSuperview()
        self.topScrollView.isHidden = false
        self.promoPageCtrl.removeFromSuperview()
        AppDelegate.shared().setHasReadPromo()
        AppDelegate.shared().showTopButton()
    }
    
    func setController() {
        promoPageVC = NSMutableArray()
        let scenseView = UIStoryboard(name: "Main", bundle: nil)
        
        promoNum = 0
        for str in AppDelegate.shared().promoUrlAry {
            if let page = scenseView.instantiateViewController(withIdentifier: "PromoPageVC") as? PromoPageVC{
                page.view.tag = promoNum
                page.view.backgroundColor = .black
                page.promoUrl = str
                promoPageVC.add(page)
                page.setImage()
                
                page.endBtn.isHidden = false
                page.endBtn.tag = promoNum
                page.endBtn.addTarget(self, action: #selector(nextPromo(_:)), for: .touchUpInside)
                
                /*
                if promoNum == (AppDelegate.shared().promoUrlAry.count-1) { //最後一頁
                    page.endBtn.isHidden = false
                    page.endBtn.tag = promoNum
                    page.endBtn.addTarget(self, action: #selector(nextPromo(_:)), for: .touchUpInside)
                }*/
            }
            promoNum += 1
        }
        
        print("promoNum = \(promoPageVC.count)")
        
        if promoNum == 0 {
            return
        } else {
            self.promoView.isHidden = false
            self.promoPageCtrl.isHidden = false
            
            self.topScrollView.isHidden = true
        }
        
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageController.view.frame = CGRect(x: 0, y: 0, width: promoView.frame.size.width, height: promoView.frame.size.height)
        self.pageController.setViewControllers([promoPageVC.object(at: currentPageIndex) as! PromoPageVC],                                                         direction: .forward,                                                         animated: false) {(isFinished:Bool) -> Void in
        }
        self.pageController.delegate = self
        self.pageController.dataSource = self
        self.addChild(self.pageController)
        promoView.addSubview(self.pageController.view)
        
        self.promoPageCtrl.numberOfPages = promoNum
        self.promoPageCtrl.currentPage = currentPageIndex
        
        AppDelegate.shared().hideTopButton()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        Analytics.logEvent("iOS_Login", parameters: nil)
        
        promoView.isHidden = true
        promoPageCtrl.isHidden = true
        
        bottomL.isHidden = true
        midNumL.textColor = Color_Main_Red
        
        accountBtn.layer.cornerRadius = accountBtn.frame.height/2
        passBtn.layer.cornerRadius = passBtn.frame.height/2
        loginBtn.layer.cornerRadius = loginBtn.frame.height/2
        
        lupaBtn.layer.cornerRadius = lupaBtn.frame.height/2
        lupaBtn.layer.borderColor = UIColor.white.cgColor
        lupaBtn.layer.borderWidth = 0.5
        
        accountBtn.layer.borderColor = UIColor.white.cgColor
        accountBtn.layer.borderWidth = 0.5
        
        passBtn.layer.borderColor = UIColor.white.cgColor
        passBtn.layer.borderWidth = 0.5
        
        accountTextfield.keyboardType = .asciiCapable
        passTextField.keyboardType = .asciiCapable
        
        accountTextfield.autocapitalizationType = .allCharacters
        
        accountTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("account", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        passTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("passcode", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        loginBtn.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
        lupaBtn.setTitle(NSLocalizedString("recover passcode", comment: ""), for: .normal)
        registerBtn.setTitle(NSLocalizedString("register", comment: ""), for: .normal)
        
        //let bnumber = Bundle.main.buildNumber
        //remeberBtn.setTitle(" " + NSLocalizedString("remmber me", comment: "") + " " + bnumber, for: .normal)
        remeberBtn.setTitle(" " + NSLocalizedString("remmber me", comment: ""), for: .normal)
        
        passTextField.isSecureTextEntry = true
        registerBtn.layer.cornerRadius = registerBtn.frame.height/2
        
        accountTextfield.text = AppDelegate.shared().getRemeberedAccount()
        passTextField.text = AppDelegate.shared().getRemeberedPassword()
        
        accountTextfield.delegate = self
        passTextField.delegate = self
        
        if DevMode {
            accountTextfield.text = "ZD66666666" //XX00000026
            passTextField.text = "123456"
        }
        
        AppDelegate.shared().rootController = self
        
        bottomL.adjustsFontSizeToFitWidth = true
        bottomL.text = "Địa chỉ: 4F., No.501, Sec. 6, Nanjing E. Rd., Neihu Dist., Taipei City 114057, Taiwan (R.O.C.) Số điện thoại: 02-2795 5959 "
        
        introL.text = "Digital Idea Multi-Media Co., Ltd.\nSố Giấy phép kinh doanh: xxxxxx\nThời hạn: dd/mm/yyyy\nNgân hàng bảo lãnh: Ngân hàng Thương mại Yuanta\nTỷ giá USD và NTD tham khảo theo giá niêm yết của ngân hàng Đài Loan\nTỷ giá USD và VND tham khảo theo giá niêm yết của ngân hàng Sacombank"
        introL.adjustsFontSizeToFitWidth = true
        if let url = URL(string: "https://govnprod.indogo.link/anti_fraud.php") {
            let request = URLRequest(url: url)
            warnWebV.navigationDelegate = self
            warnWebV.load(request)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.shared().clearAllSetup()
        
        if loadOnce {
            AppDelegate.shared().showTopButton()
            return
        }
        
        //寬度少於380，或長寬比接近3:4
        let ratio = self.view.frame.size.width/self.view.frame.size.height
        Dlog("ratioratio=\(ratio) \(self.view.frame.size.width) \(self.view.frame.size.height)")
        
        if self.view.frame.size.width < 380 || (ratio<0.57 && ratio>0.56)  {
            AppDelegate.shared().deviceSmall = true
            let bnumber = Bundle.main.buildNumber
            //remeberBtn.setTitle(" " + NSLocalizedString("remmber me", comment: "") + " " + bnumber + "", for: .normal)
            remeberBtn.setTitle(" " + NSLocalizedString("remmber me", comment: ""), for: .normal)
        }
        
        loadOnce = true
        
        //頂部兩個按鈕
        AppDelegate.shared().topMargin = self.view.safeAreaInsets.top
        AppDelegate.shared().addTopButton()
        
        //AppDelegate.shared().floatingButtonController = FloatingButtonController()
        //AppDelegate.shared().floatingButtonController?.button.addTarget(self, action: #selector(AppDelegate.floatingButtonWasTapped), for: .touchUpInside)
        AppDelegate.shared().addFloatingBtn()
        
        //取得Promo
        if AppDelegate.shared().getHasReadPromo() == "" {
           getPromo()
        }
        getInfo()
        
        //自動登入(取消)
        /*
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: "sessionToken") != nil {
            AppDelegate.shared().sessionToken = userDefaults.value(forKey: "sessionToken") as! String
            checkTokenLogin()
        }*/
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else{
            return true
        }
        
        if !string.checkAlphabetDigit() {
            return false
        }
        
        let textLength = text.count + string.count - range.length
        if textLength>20 {
            return false
        }
        
        return true
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        let scheme = url.scheme?.lowercased() ?? ""
        // Only intercept user-tapped HTTP/HTTPS links; allow initial load and programmatic navigations.
        if (scheme == "http" || scheme == "https"),
           navigationAction.navigationType == .linkActivated {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

