//
//  AppDelegate.swift
//  indogo
//
//  Created by mac on 2020/7/9.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import UserNotifications
import PKHUD
import CommonCrypto
import Firebase
import FirebaseMessaging
import WebKit
import ZKProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WKNavigationDelegate {
    
    var floatingButton: UIButton!
    var floatingContainer: UIView!
    var window: UIWindow?
    var topMargin: CGFloat!
    var shopWebView:WKWebView!
    var shopWebBgV:UIView!
    var blackWindow:UIView!
    var callUrlOnce = false
    
    //var topContainer:UIView!
    var normalPageBtn:UIButton!
    var shopPageBtn:UIButton!
    //var topLine:UIView!
    var nowPage = 0
    
    var alertViewContainer:UIView!
    
    var hasLogin = false
    //是否有省份資料
    var hasProvinceData = false
    //目前快取的省份資料是不是宅配到府那一份，兩種清單內容不同
    var provinceDataIsDoorToDoor = false
    var floatingBtnBackFrame:CGRect!
    var hasFloatingBtn = false
    var deviceSmall = false
    
    public var promoUrlAry:[String] = []
    public var sessionToken:String = ""
    public var memberData:[String:String] = [:]
    
    var tempTransferMaxWarningStr = ""
    var tempTransferMaxAmount = 0
    var tempTransferMaxAmountStr = ""
    var tempTransferLeftAmount = 0
    var transferErrorIs509:Bool = false
    
    public var forgotPassTempMemID:String = ""
    public var forgotPassTempPhone:String = ""
    public var forgotPassTempSMS:String = ""
    public var forgotPassTempEnterCode:String = ""
    
    public var tempRegisterObj:RegisterDataObj = RegisterDataObj()
    
    var noteListObjs:[NoticeObj] = []
    var historyListObj:[PointHistorySingleObj] = []
    var transferFriendListObj:[TransferMemberObj] = []
    var transferStepOneListObj:[TransferMemberObj] = []
    var recipientListObjs:[RecipientObj] = []
    var recipientShownListObjs:[RecipientObj] = []
    var transferStateListObjs:[TransferStateObj] = []
    var transferOrderCheckListObjs:[TransferOrderCheckObj] = []
    var provinceData:[ProvinceObj] = []
    var tempSearchRecipientList:[RecipientObj] = []
    var tempTransferChoseMode = false
    
    var tempTransactionResultObj:TransactionResultObj!
    var tempBarCodeInfoObj:BarCodeInfoObj!
    
    var seperatorStr:String = ""
    var subSeperatorStr:String = ""
    var bottomMenu:BottomMenuView!
    var hasBottomMenu = false
    var bottomPadding:CGFloat!
    var firstOpenApp = false
    
    var wholeAddress = ""
    
    var defautBottomMenuType:BottomMenuType = .transaction
    var nowBottomMenuType:BottomMenuType = .transaction
    
    var hasBankList = false
    var bankList:[BankObj] = []
    var getInfoStrAry:[String] = []
    
    var pointRootShowHistory = false
    var tempAgreementHtmlContent:String = ""
    var tempTransferAgreementHtmlContent:String = ""
    var tempErrorStr:String = ""
    var shareContent = ""
    
    var apiBackContentStr = ""
    
    var transactionObj:TransactionObj = TransactionObj()
    var noticeNotReadNum = 0
    
    //不能超過三次
    var bankListTimes = 0
    
    //此項作為若掃描ARC有結果，導去註冊的頁面
    var hasArcResultAndGotoRegister = false
    var arcScanReulstForRegister = ""
    
    var tempRecipientObj:RecipientObj = RecipientObj()
    var lastUrl = URL.init(string: "")
    var tempType:LoginFuncType!
    var rootController:ViewController!
    
    var checkRecipientName = ""
    
    var transferQuotaTotal:Int = 0
    var transferQuotaLeft:Int = 0
    
    var tempShareMemberId = ""
    
    var tempDiscountCodeResultAry:[String] = ["","","","",""]
    var discountForTransfer:String = ""
    var discountCode:String = ""
    
    //MARK: - Web Delegate
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        Dlog("Start loading")
        lastUrl = webView.url
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Dlog("End loading")
        lastUrl = webView.url
    }
    
    //MARK: - App Life
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //addTopButton()
        //檢查版本
        checkAppStoreVersion()
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        loadCookie()
        
        //指定分隔字元
        AppDelegate.shared().seperatorStr = NSLocalizedString("leading space", comment: "")
        AppDelegate.shared().subSeperatorStr = NSLocalizedString("leading sub space", comment: "")
        self.getBankList()
        //後台控制 App icon
        AppIconManager.shared.fetchAndApplyIcon()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        saveCookie()
    }
    
    //回首頁時清除所有設定
    func clearAllSetup() {
        AppDelegate.shared().hasArcResultAndGotoRegister = false
        AppDelegate.shared().arcScanReulstForRegister = ""
    }

    //iOS 13以下沒有SceneDelegate，這裡補上強制更新的再檢查
    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 13.0, *) {
            return
        }
        presentForceUpdateAlert()
    }

    //MARK: - Notification
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void
        ) {
        
        Dlog("userInfo=\(userInfo)")
        
        let dic1 = (userInfo["aps"] as! NSDictionary)
        let strTitle = (dic1["alert"] as! NSDictionary)
        let title = strTitle.value(forKey: "title")
        let body = strTitle.value(forKey: "body")
        
        let window = UIApplication.shared.keyWindow
        
        if application.applicationState == .active{
            
            
            let alert = UIAlertController(title: "\(title!)", message: "\(body!)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default) { action in
            })
            window?.rootViewController?.present(alert, animated: true)
        }else if application.applicationState == .background{
            /*
            let alert = UIAlertController(title: "\(title!)", message: "\(body!)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default) { action in
            })
            window?.rootViewController?.present(alert, animated: true)
            */
        }else{
            /*
            let alert = UIAlertController(title: "\(title!)", message: "\(body!)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default) { action in
            })
            window?.rootViewController?.present(alert, animated: true)
            */
        }
        /*
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        
        let apsdic = userInfo["aps"] as? Dictionary
        let vc = UIAlertController(title:"", message:"\(apsdic["alert"] as String)", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "確定", style: .default, handler: { action in
            
        }))
        self.window?.rootViewController?.present(vc, animated: true, completion: nil)
        */
        
    }
    
    //MARK: - Bottom Menu
    func showBottomMenu() {
        bottomMenu.isHidden = false
        bottomMenu.paintMenu()
    }
    
    func hideBottomMenu() {
        bottomMenu.isHidden = true
    }
    
    func setBottomNotReadNum() {
        if bottomMenu == nil {
            return
        }
        
        bottomMenu.setReadNum()
    }
    
    func addBttomMenu() {
        let window = UIApplication.shared.keyWindow
        
        bottomPadding = window?.safeAreaInsets.bottom
        
        bottomMenu = BottomMenuView()
        bottomMenu.frame = CGRect.init(x: 0, y: (window?.frame.size.height)!-(bottomPadding+50), width: (window?.frame.size.width)!, height: bottomPadding+50)
        bottomMenu.initFirst(RealHeight: 50)
        window?.addSubview(bottomMenu)
        
        //把浮動按鈕拉到最上面
        if hasFloatingBtn {
            window?.bringSubviewToFront(floatingButton)
        }
        
        //先隱藏
        bottomMenu.isHidden = true
        
        hasBottomMenu = true
    }

    //MARK: - Floating Button
    func saveFloatingButtonPosition() {
        floatingBtnBackFrame = floatingButton.frame
    }
    
    func reStoreFloatingButtonPosition() {
        floatingButton.frame = floatingBtnBackFrame
    }
    
    func showFloatingBtn() {
        if hasFloatingBtn {
            let window = UIApplication.shared.keyWindow
            window?.bringSubviewToFront(floatingButton)
        }
    }
    
    func addFloatingBtn() {
        if hasFloatingBtn {
            saveFloatingButtonPosition()
            if floatingButton != nil {
                floatingButton.removeFromSuperview()
            }
        }
        
        let window = UIApplication.shared.keyWindow
        
        floatingButton = UIButton(type: .custom)
        floatingButton.frame = CGRect(origin: CGPoint(x: (window?.frame.size.width)!-65, y: (window?.frame.size.height)!-132), size: CGSize(width: 55, height: 55))
        floatingButton.imageView?.contentMode = .scaleToFill
        //floatingButton.setImage(UIImage.init(named: "question.png"), for: .normal)
        floatingButton.setBackgroundImage(UIImage.init(named: "service_phone.png"), for: .normal)
        floatingButton.backgroundColor = UIColor.clear
        floatingButton.layer.shadowColor = UIColor.black.cgColor
        floatingButton.layer.shadowRadius = 3
        floatingButton.layer.shadowOpacity = 0.8
        floatingButton.layer.shadowOffset = CGSize.zero
        
        window?.addSubview(floatingButton)
        
        let panner = UIPanGestureRecognizer(target: self, action: #selector(panDidFire(panner:)))
        floatingButton.addGestureRecognizer(panner)
        floatingButton.addTarget(self, action: #selector(floatingButtonWasTapped), for: .touchUpInside)
        
        if hasFloatingBtn {
            reStoreFloatingButtonPosition()
        }
        
        hasFloatingBtn = true
        
    }
    
    @objc func panDidFire(panner: UIPanGestureRecognizer) {
        let window = UIApplication.shared.keyWindow
        
        let offset = panner.translation(in: window)
        panner.setTranslation(CGPoint.zero, in: window)
        var center = floatingButton.center
        center.x += offset.x
        center.y += offset.y
        floatingButton.center = center

        if panner.state == .ended || panner.state == .cancelled {
            UIView.animate(withDuration: 0.3) {
                self.snapButtonToSocket()
            }
        }
    }

    private func snapButtonToSocket() {
        let center = floatingButton.center
        let window = UIApplication.shared.keyWindow
        
     if center.y < (50 + floatingButton.frame.size.height*0.5) {
            floatingButton.center.y = (50+30)
        } else if center.y > ( (window?.frame.size.height)! - floatingButton.frame.size.height*0.5 - 60) {
            floatingButton.center.y = (window?.frame.size.height)! - floatingButton.frame.size.height*0.5 - 60
        }
        
        if center.x < ( 10 + floatingButton.frame.size.width*0.5) {
            floatingButton.center.x = 10 + floatingButton.frame.size.width*0.5
        } else if center.x > ( (window?.frame.size.width)! - floatingButton.frame.size.width*0.5 - 10) {
            floatingButton.center.x = (window?.frame.size.width)! - floatingButton.frame.size.width*0.5 - 10
        }
    }
    
    @objc func floatingButtonWasTapped() {
        showFloatingContainer()
    }
    
    func showFloatingContainer() {
        
        if floatingContainer != nil {
            removeFloatingContainer()
            return
        }
        
        let window = UIApplication.shared.keyWindow

        let boxHeight:CGFloat = 200
        
        floatingContainer = UIView(frame: CGRect.init(x: 0, y: 0, width: window!.bounds.width, height: window!.bounds.height))
        window!.addSubview(floatingContainer);
        floatingContainer.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        let btn = UIButton.init(frame: floatingContainer.frame)
        floatingContainer.addSubview(btn)
        btn.addTarget(self, action: #selector(removeFloatingContainer), for: .touchUpInside)
        
        let alertViewBg = UIView.init(frame: CGRect.init(x: 25, y: window!.bounds.height/2 - 20 - boxHeight/2, width: window!.bounds.width - 50, height: boxHeight))
        floatingContainer.addSubview(alertViewBg)
        
        alertViewBg.backgroundColor = .white
        alertViewBg.layer.cornerRadius = 10
        alertViewBg.clipsToBounds = true
        
        //頂部紅色條
        let topView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: alertViewBg.frame.size.width, height: 50))
        topView.backgroundColor = Color_Main_Red
        alertViewBg.addSubview(topView)
        
        //字
        let titelL = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: topView.frame.size.width, height: topView.frame.size.height))
        titelL.font = UIFont.systemFont(ofSize: 20)
        titelL.textAlignment = .center
        topView.addSubview(titelL)
        titelL.text = NSLocalizedString("Floating Title", comment: "")
        titelL.textColor = .white
        
        let divs:CGFloat = (alertViewBg.frame.size.width - 3*85)/4
        let ary:[String] = ["phone-1.png","line.png","messenger.png"] //phone-1.png
        let strAry:[String] = [NSLocalizedString("telephone", comment: ""),NSLocalizedString("line", comment: ""),NSLocalizedString("messenger", comment: "")]
        for i in 0..<3 {
            let x = divs + (divs + 85) * CGFloat(i)
            let btn = UIButton.init(frame: CGRect.init(x: x, y: 65, width: 85, height: 85))
            btn.setImage(UIImage.init(named: ary[i]), for: .normal)
            alertViewBg.addSubview(btn)
            
            if i==0 {
                btn.addTarget(self, action: #selector(callPhone), for: .touchUpInside)
            } else if i==1 {
                btn.addTarget(self, action: #selector(callLine), for: .touchUpInside)
            } else if i==2 {
                btn.addTarget(self, action: #selector(callMessenger), for: .touchUpInside)
            }
            
            let label = UILabel.init(frame: CGRect.init(x: x, y: btn.frame.origin.y + btn.frame.size.height + 10, width: btn.frame.size.width, height: 20))
            label.text = strAry[i]
            label.textAlignment = .center
            alertViewBg.addSubview(label)
        }
        
        
        //把浮動按鈕拉到最上面
        window?.bringSubviewToFront(floatingContainer)
        window?.bringSubviewToFront(floatingButton)
    }
    
    @objc func callPhone() {
        if floatingContainer != nil {
            removeFloatingContainer()
        }
        /*
        let phone = "0287928773"
        let cleanPhoneNumber = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        let urlString:String = "tel://\(cleanPhoneNumber)"

        if let phoneCallURL = URL(string: urlString) {
            if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }*/
        
        let phone = "0287925880"
        //let extensionNum = "2211"
        let cleanPhoneNumber = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        //let urlString:String = "tel://\(cleanPhoneNumber),\(extensionNum)"
        let urlString:String = "tel://\(cleanPhoneNumber)"

        if let phoneCallURL = URL(string: urlString) {
            if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func callLine() {
        if floatingContainer != nil {
            removeFloatingContainer()
        }
        
        let urlString:String = "https://line.me/R/ti/p/%40vbo9560f"

        if let openURL = URL(string: urlString) {
            if (UIApplication.shared.canOpenURL(openURL)) {
                UIApplication.shared.open(openURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func callMessenger() {
        if floatingContainer != nil {
            removeFloatingContainer()
        }
        
        let urlString:String = "https://m.me/govndailoan"

        if let openURL = URL(string: urlString) {
            if (UIApplication.shared.canOpenURL(openURL)) {
                UIApplication.shared.open(openURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func removeFloatingContainer() {
        floatingContainer.removeFromSuperview()
        floatingContainer = nil
    }
    
    //MARK: -  Alamofire 設置為全局變量
    var alamofireManagerWithTimeout:Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        //請求超時時間15秒
        configuration.timeoutIntervalForRequest = 15
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        
        //let serverTrustPolicies: [String: ServerTrustPolicy] = ["prod.indogo.com.tw": .disableEvaluation]
        let serverTrustPolicies: [String: ServerTrustPolicy] = [:]
        let servertrustManager = ServerTrustPolicyManager(policies: serverTrustPolicies)
        
        return Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: servertrustManager)
    }()
    
    /*
    var alamofireManagerWithTimeout:Alamofire.SessionManager = {
    let configuration = URLSessionConfiguration.default
         //請求超時時間15秒
         configuration.timeoutIntervalForRequest = 15
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringCacheData
         return Alamofire.SessionManager(configuration: configuration)
     }()
    */
    //MARK: - API
    func getNotice() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "page":1, "limit":9]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().noteListObjs = []
        
        let todoEndpoint: String = API_NoticeRecordList;
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    //AppDelegate.shared().showAlertView(Message: NSLocalizedString("API Timeout", comment: ""))
                    AppDelegate.shared().showAlertView(Message: NSLocalizedString("API Timeout", comment: ""), ConfrimStr: NSLocalizedString("cancelForError", comment: ""))
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("todoEndpoint = \(todoEndpoint),responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                
                if result == ResponseState.ok {
                    //let newCount = AppDelegate.shared().noteListObjs.count
                    var count = 0
                    for i in 0..<AppDelegate.shared().noteListObjs.count {
                        let data = AppDelegate.shared().noteListObjs[i]
                        if data.readable == "0" {
                            count += 1
                        }
                    }
                    AppDelegate.shared().noticeNotReadNum = count
                    AppDelegate.shared().setBottomNotReadNum()
                    
                } else if result == ResponseState.failed {
                }
        }
    }
    
    func getBankList() {
        if AppDelegate.shared().hasBankList {
            return
        }
        
        //重複呼叫自己
        if self.bankListTimes < 3 {
            self.bankListTimes += 1
        } else {
            self.bankListTimes = 0
            return
        }
        
        let parameters:Parameters = [:]
        let headers: HTTPHeaders = [:]
        
        let todoEndpoint: String = API_BankList;
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    
                    //重複呼叫自己
                    self.getBankList()
                    
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("responseStr = \(responseStr ?? "")")
                
                AppDelegate.shared().bankList = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.bankListTimes = 0
                    self.hasBankList = true
                } else if result == ResponseState.failed {
                    //重複呼叫自己
                    self.getBankList()
                }
        }
    }
    
    //取得省份與行政區資料
    //原本只有TransferMainVC有這支，從會員專區進去新增受款人就拿不到資料，所以移到這裡共用
    func getProvinceData(RecipientType recipientType:Int, Completion completion:((Bool) -> Void)? = nil) {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "mode":"json"]
        let headers: HTTPHeaders = [:]

        //宅配到府的省份清單和另外兩種不一樣
        let todoEndpoint: String = (recipientType == 3) ? API_Get_province_districtDoorToDoor : API_Get_province_district

        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")

        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in

                guard response.result.error == nil else {
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    completion?(false)
                    return
                }

                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("province responseStr = \(responseStr ?? "")")

                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    AppDelegate.shared().hasProvinceData = true
                    URLCache.shared.removeAllCachedResponses()
                    completion?(true)
                } else {
                    completion?(false)
                }
        }
    }

    //App上架台灣和越南商店，lookup不帶country會查美國商店而回傳空陣列
    let appStoreFallbackCountry = "vn"
    //檢查到需要強制更新，回到App時要再擋一次
    var needForceUpdate = false

    func checkAppStoreVersion() {
        let bundleId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
        let country = Locale.current.regionCode ?? appStoreFallbackCountry

        //先用裝置所在地區查，查不到再用上架地區補查一次
        lookupAppStoreVersion(BundleId: bundleId, Country: country) { appStoreVersion in
            if let appStoreVersion = appStoreVersion {
                self.showUpdateAlertIfNeeded(AppStoreVersion: appStoreVersion)
                return
            }

            if country.lowercased() == self.appStoreFallbackCountry {
                Dlog("checkAppStoreVersion 查無資料, bundleId = \(bundleId), country = \(country)")
                return
            }

            self.lookupAppStoreVersion(BundleId: bundleId, Country: self.appStoreFallbackCountry) { appStoreVersion in
                guard let appStoreVersion = appStoreVersion else {
                    Dlog("checkAppStoreVersion 查無資料, bundleId = \(bundleId), country = \(country)/\(self.appStoreFallbackCountry)")
                    return
                }
                self.showUpdateAlertIfNeeded(AppStoreVersion: appStoreVersion)
            }
        }
    }

    func lookupAppStoreVersion(BundleId bundleId:String, Country country:String, Completion completion:@escaping (String?) -> Void) {
        Alamofire.request("https://itunes.apple.com/lookup?bundleId=\(bundleId)&country=\(country)").responseJSON { response in
            guard let json = response.result.value as? NSDictionary, let results = json["results"] as? NSArray, let entry = results.firstObject as? NSDictionary, let appStoreVersion = entry["version"] as? String else {
                completion(nil)
                return
            }
            completion(appStoreVersion)
        }
    }

    func showUpdateAlertIfNeeded(AppStoreVersion appStoreVersion:String) {
        let appVersionInApp = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!
        Dlog("appStoreVersion = \(appStoreVersion), appVersionInApp = \(appVersionInApp)")

        //只有商店版本比較新才擋，避免開發中的版本被自己的更新視窗擋住
        guard appStoreVersion.compare(appVersionInApp, options: .numeric) == .orderedDescending else {
            needForceUpdate = false
            return
        }

        needForceUpdate = true
        presentForceUpdateAlert()
    }

    //回到App時再擋一次，取代原本的exit(0)
    func presentForceUpdateAlert() {
        guard needForceUpdate else { return }

        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            Dlog("presentForceUpdateAlert 找不到rootViewController")
            return
        }

        //找到最上層的VC，並避免重複present
        var topVC = rootVC
        while let presentedVC = topVC.presentedViewController {
            if presentedVC is UIAlertController {
                return
            }
            topVC = presentedVC
        }

        let alert = UIAlertController(title: "", message: NSLocalizedString("Please Update App", comment: ""), preferredStyle: .alert)
        let action1 = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler:{(_)-> Void in
            self.getToAppStore() { success in
                //沒開成App Store就馬上再擋一次，開成了則等回到App時由becomeActive再擋
                if !success {
                    self.presentForceUpdateAlert()
                }
            }
        })
        alert.addAction(action1)
        topVC.present(alert ,animated: true,completion: nil)
    }

    func getToAppStore(Completion completion:((Bool) -> Void)? = nil) {
        let appId = "1542021003" //GoVn 的 App Store ID
        let country = Locale.current.regionCode?.lowercased() ?? appStoreFallbackCountry

        //依序試到開得起來為止，最後一個https網址由iOS轉交App Store App
        let urlStrAry = ["itms-apps://apps.apple.com/\(country)/app/id\(appId)",
                         "itms-apps://apps.apple.com/app/id\(appId)",
                         "itms-apps://itunes.apple.com/app/id\(appId)",
                         "https://apps.apple.com/\(country)/app/id\(appId)"]
        openAppStoreURL(URLStrAry: urlStrAry, Index: 0, Completion: completion)
    }

    //模擬器沒有安裝App Store，所有itms-apps網址都會失敗，要在實機測試
    func openAppStoreURL(URLStrAry urlStrAry:[String], Index index:Int, Completion completion:((Bool) -> Void)?) {
        guard index < urlStrAry.count, let appURL = URL.init(string: urlStrAry[index]) else {
            Dlog("getToAppStore 全部網址都開不起來")
            completion?(false)
            return
        }

        UIApplication.shared.open(appURL, options:[.universalLinksOnly : false]) { (success) in
            Dlog("getToAppStore success = \(success), url = \(urlStrAry[index])")
            if success {
                completion?(true)
            } else {
                self.openAppStoreURL(URLStrAry: urlStrAry, Index: index + 1, Completion: completion)
            }
        }
    }
    
    //MARK: - login
    public func userLogin(TokenStr str:String) {
        sessionToken = str
        hasLogin = true
        //存起來
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(str, forKey: "sessionToken")
        userDefaults.synchronize()
    }
    
    func aesWord(OriStr str:String, IsEncode encode:Bool) -> String {
        var answerStr = ""
        do {
            
            let password = SecurePSStr
            let salt = SecureSaltStr.data(using: .utf8)! //AES256Crypter.randomSalt()
            let iv = SecureIvStr.data(using: .utf8)!
            //AES256Crypter.randomIv()
            
            let key = try AES256Crypter.createKey(password: password.data(using: .utf8)!, salt: salt)
            let aes = try AES256Crypter(key: key, iv: iv)
            
            if encode {
                let sourceData = str.data(using: .utf8)!
                let encryptedData = try aes.encrypt(sourceData)
                answerStr = encryptedData.base64EncodedString()
                //String.init(data: encryptedData, encoding: .utf8)!
            } else {
                //let nowData = str.data(using: .utf8)!
                let nowData = Data(base64Encoded: str, options: .ignoreUnknownCharacters)!
                let decryptedData = try aes.decrypt(nowData)
                answerStr = String.init(data: decryptedData, encoding: .utf8)!
            }
            
            Dlog("Decrypted hex string: \(answerStr)")
        } catch {
            Dlog("Failed")
            return ""
        }
        
        return answerStr
    }
    
    public func rememberAccount(Account account:String, Pass pass:String) {
        Dlog("rememberAccount = \(account)")
        let userDefaults = UserDefaults.standard
        
        let convertStr = aesWord(OriStr: account, IsEncode: true)
        let convertPassStr = aesWord(OriStr: pass, IsEncode: true)
        
        userDefaults.setValue(convertStr, forKey: "remeberAccount")
        userDefaults.setValue(convertPassStr, forKey: "remeberPass")
        userDefaults.synchronize()
        /*
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(account, forKey: "remeberAccount")
        userDefaults.setValue(pass, forKey: "remeberPass")
        userDefaults.synchronize()
         */
    }
    
    public func getRemeberedAccount() -> String {
        let userDefaults = UserDefaults.standard
        if userDefaults.string(forKey: "remeberAccount") != nil {
            let str = userDefaults.string(forKey: "remeberAccount")!
            let ansStr = aesWord(OriStr: str, IsEncode: false)
            return ansStr
        } else {
            return ""
        }
        
        /*
        let userDefaults = UserDefaults.standard
        if userDefaults.string(forKey: "remeberAccount") != nil {
            return userDefaults.string(forKey: "remeberAccount")!
        } else {
            return ""
        }*/
    }
    
    public func getRemeberedPassword() -> String {
        let userDefaults = UserDefaults.standard
        if userDefaults.string(forKey: "remeberPass") != nil {
            let str = userDefaults.string(forKey: "remeberPass")!
            let ansStr = aesWord(OriStr: str, IsEncode: false)
            return ansStr
        } else {
            return ""
        }
        /*
        let userDefaults = UserDefaults.standard
        if userDefaults.string(forKey: "remeberPass") != nil {
            return userDefaults.string(forKey: "remeberPass")!
        } else {
            return ""
        }*/
    }
    
    public func removeSavedAccount() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "remeberAccount")
        userDefaults.removeObject(forKey: "remeberPass")
        userDefaults.synchronize()
    }
    
    public func userLogout() {
        hasLogin = false
        sessionToken = ""
        //removeSavedAccount()
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "sessionToken")
        userDefaults.removeObject(forKey: "bioState")
        userDefaults.synchronize()
        
        if hasBottomMenu {
            bottomMenu.removeFromSuperview()
        }
        hasBottomMenu = false
    }
    
    public func rememberAarcNo(Account account:String) {
        let userDefaults = UserDefaults.standard
        let convertStr = aesWord(OriStr: account, IsEncode: true)
        userDefaults.setValue(convertStr, forKey: "remeberArcNo")
        userDefaults.synchronize()
    }
    
    public func getRemeberedAarcNo() -> String {
        let userDefaults = UserDefaults.standard
        if userDefaults.string(forKey: "remeberArcNo") != nil {
            let str = userDefaults.string(forKey: "remeberArcNo")!
            let ansStr = aesWord(OriStr: str, IsEncode: false)
            return ansStr
        } else {
            return ""
        }
    }
    
    /*
    public func rememberAarcNo(Account account:String) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(account, forKey: "remeberArcNo")
        userDefaults.synchronize()
    }
    
    public func getRemeberedAarcNo() -> String {
        let userDefaults = UserDefaults.standard
        if userDefaults.string(forKey: "remeberArcNo") != nil {
            return userDefaults.string(forKey: "remeberArcNo")!
        } else {
            return ""
        }
    }*/
    
    public func setHasReadPromo () {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue("1", forKey: "hasReadPromo")
        userDefaults.synchronize()
    }
    
    public func getHasReadPromo() -> String {
        let userDefaults = UserDefaults.standard
        if userDefaults.string(forKey: "hasReadPromo") != nil {
            return userDefaults.string(forKey: "hasReadPromo")!
        } else {
            return ""
        }
    }
    
    func setBioState() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue("1", forKey: "bioState")
        userDefaults.synchronize()
    }
    
    func getBioState() -> Bool {
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: "bioState") == nil || userDefaults.value(forKey: "transPassword") == nil {
            return false
        } else {
            return true
        }
    }
    
    //MARK: - Change Root
    public func changeRootOfFunc(Type type:LoginFuncType, discountForTransfer:String = "", discountCode:String = "") {
        
        var storyboardId = ""
        var navigaterId = ""
        
        AppDelegate.shared().discountForTransfer = ""
        AppDelegate.shared().discountCode = ""
        
        if type == LoginFuncType.main {
            storyboardId = "Main"
            navigaterId = "MainNC"
        } else {
            
            if type == LoginFuncType.member {
                storyboardId = "Member"
                navigaterId = "MemberMainNC"
            } else if type == LoginFuncType.transState {
                storyboardId = "Member"
                navigaterId = "TransferListNC"
            } else if type == LoginFuncType.transaction {
                storyboardId = "Member"
                navigaterId = "TransferMainNC"
                AppDelegate.shared().discountForTransfer = discountForTransfer
                AppDelegate.shared().discountCode = discountCode
            } else if type == LoginFuncType.sharing {
                storyboardId = "Member"
                var storyboardId = "ShareMainNC"
                if AppDelegate.shared().deviceSmall {
                    storyboardId = "ShareMainNCSmall"
                }
                navigaterId = storyboardId
            } else if type == LoginFuncType.notice {
                storyboardId = "Member"
                navigaterId = "NoticeMainNC"
            }
        }
        
        let window = UIApplication.shared.keyWindow
        // Set initial view controller from Main storyboard as root view controller of UIWindow
        let nextVC = UIStoryboard(name: storyboardId, bundle: nil).instantiateViewController(withIdentifier: navigaterId)
        window!.rootViewController = nextVC
        // Present window to screen
        self.window?.makeKeyAndVisible()
        
        //底層Menu
        addFloatingBtn()
        addBttomMenu()
        
        if type != LoginFuncType.main {
            showBottomMenu()
        }
        
    }
    
    /* //原本測試不換 rootViewController，但還是會引發 webview 登出空白化，應該是蘋果系統自動觸發
    public func changeRootOfFunc(Type type:LoginFuncType) {
        tempType = type
        
        AppDelegate.shared().rootController.navigationController?.popToRootViewController(animated: false)
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(step2), userInfo: nil, repeats: false)
    }
    
    @objc func step2() {
        Dlog("step2")
        let type = tempType
        var storyboardId = ""
        var navigaterId = ""
        
        let window = UIApplication.shared.keyWindow
        
        if type == LoginFuncType.main {
            storyboardId = "Main"
            navigaterId = "MainVC"
            
        } else {
            
            if type == LoginFuncType.member {
                storyboardId = "Member"
                navigaterId = "MemberMainVC"
            } else if type == LoginFuncType.transState {
                storyboardId = "Member"
                navigaterId = "TransferListVC"
            } else if type == LoginFuncType.transaction {
                storyboardId = "Member"
                navigaterId = "TransferMainVC"
            } else if type == LoginFuncType.sharing {
                storyboardId = "Member"
                var storyboardId = "ShareMainVC"
                if AppDelegate.shared().deviceSmall {
                    storyboardId = "ShareMainVCSmall"
                }
                navigaterId = storyboardId
            } else if type == LoginFuncType.notice {
                storyboardId = "Member"
                navigaterId = "NoticeMainVC"
            }
            
            Dlog("navigaterId = \(navigaterId)")
            let nextVC = UIStoryboard(name: storyboardId, bundle: nil).instantiateViewController(withIdentifier: navigaterId)
            AppDelegate.shared().rootController.navigationController?.pushViewController(nextVC, animated: false)
            
        }
        
        //底層Menu
        addFloatingBtn()
        addBttomMenu()
        
        if type != LoginFuncType.main {
            showBottomMenu()
        } else {
            hideBottomMenu()
        }
    }*/
    
    //MARK: - Cookie
    func saveCookie() {
        let cookieJar: HTTPCookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieJar.cookies {
            let data: Data = NSKeyedArchiver.archivedData(withRootObject: cookies)
            let ud: UserDefaults = UserDefaults.standard
            ud.set(data, forKey: "cookie")
        }
        
        Dlog("saveCookie")
    }

    func loadCookie() {
        Dlog("loadCookie")
        let ud: UserDefaults = UserDefaults.standard
        let data: Data? = ud.object(forKey: "cookie") as? Data
        if let cookie = data {
            let datas: NSArray? = NSKeyedUnarchiver.unarchiveObject(with: cookie) as? NSArray
            if let cookies = datas {
                for c in cookies {
                    if let cookieObject = c as? HTTPCookie {
                        HTTPCookieStorage.shared.setCookie(cookieObject)
                    }
                }
            }
        }
    }
    
    //MARK: - Utility
    class func shared() -> AppDelegate
    {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    //頂部兩個按鈕
    func addTopButton() {
        /*
        let window = UIApplication.shared.keyWindow
        bottomPadding = window?.safeAreaInsets.bottom
        
        topContainer = UIView(frame: CGRect.init(x: 0, y: topMargin, width: window!.bounds.width, height: 40))
        window!.addSubview(topContainer)
        topContainer.backgroundColor = UIColor.black
        normalPageBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: topContainer.frame.size.width/2, height: topContainer.frame.size.height))
        normalPageBtn.backgroundColor = UIColor.black
        normalPageBtn.setTitle(NSLocalizedString("remit", comment: ""), for: .normal)
        topContainer.addSubview(normalPageBtn)
        normalPageBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        normalPageBtn.addTarget(self, action: #selector(callFloatingNormalV), for: .touchUpInside)
        
        shopPageBtn = UIButton.init(frame: CGRect(x: topContainer.frame.size.width/2, y: 0, width: topContainer.frame.size.width/2, height: topContainer.frame.size.height))
        shopPageBtn.backgroundColor = UIColor.black
        shopPageBtn.setTitle(NSLocalizedString("shopping", comment: ""), for: .normal)
        topContainer.addSubview(shopPageBtn)
        shopPageBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        shopPageBtn.addTarget(self, action: #selector(callFloatingShopWeb), for: .touchUpInside)
        
        topLine = UIView.init(frame: CGRect.init(x: 0, y: topContainer.frame.size.height-2, width: topContainer.frame.size.width/2, height: 2))
        topLine.backgroundColor = UIColor.init(red: 26/255, green: 143/255, blue: 246/255, alpha: 1)
        topContainer.addSubview(topLine)
        
        let y = topContainer.frame.origin.y+topContainer.frame.size.height
        shopWebBgV = UIView.init(frame: CGRect.init(x: 0, y: y, width: topContainer.frame.size.width, height: window!.bounds.height-y))
        shopWebBgV.backgroundColor = .white
        window!.addSubview(shopWebBgV)
        shopWebBgV.isHidden = true
        
        shopWebView = WKWebView.init(frame: CGRect.init(x: 0, y: 0, width: shopWebBgV.frame.size.width, height: shopWebBgV.frame.size.height-bottomPadding))
        shopWebBgV.addSubview(shopWebView)
        shopWebView.navigationDelegate = self
        
        normalPageBtn.setTitleColor(.white, for: .normal)
        shopPageBtn.setTitleColor(.darkGray, for: .normal)
        
        initLinePosX()
        */
    }
    
    @objc func callFloatingShopWeb() {
        NotificationCenter.default.post(name: Notification.Name("closeKeyboard"), object: nil)
        
        normalPageBtn.setTitleColor(.darkGray, for: .normal)
        shopPageBtn.setTitleColor(.white, for: .normal)
        //topLine.frame = CGRect.init(x: topContainer.frame.size.width/2, y: topContainer.frame.size.height-2, width: topContainer.frame.size.width/2, height: 2)
        shopWebBgV.isHidden = false
        if !callUrlOnce {
            lastUrl = URL(string: "https://ec.indogo.tw/")
            let request = URLRequest(url: lastUrl!)
            shopWebView.load(request)
        } else {
            Dlog("callFloatingShopWeb")
            let request = URLRequest(url: lastUrl!)
            shopWebView.load(request)
        }
        
        callUrlOnce = true
        showFloatingBtn()
    }
    
    @objc func callFloatingNormalV() {
        normalPageBtn.setTitleColor(.white, for: .normal)
        shopPageBtn.setTitleColor(.darkGray, for: .normal)
        //topLine.frame = CGRect.init(x: 0, y: topContainer.frame.size.height-2, width: topContainer.frame.size.width/2, height: 2)
        shopWebBgV.isHidden = true
        showFloatingBtn()
    }
    
    func showTopButton() {
        //topContainer.isHidden = false
    }
    
    func hideTopButton() {
        //topContainer.isHidden = true
    }
    
    //底部線條
    func initLinePosX() {
        /*
        if nowPage == 0 {
            topLine.frame =  CGRect.init(x: 0, y: topContainer.frame.size.height-2, width: topContainer.frame.size.width/2, height: 2)
        } else {
            topLine.frame =  CGRect.init(x: topContainer.frame.size.width/2, y: topContainer.frame.size.height-2, width: topContainer.frame.size.width/2, height: 2)
        }*/
    }
    
    //正在讀取
    func addLoadingView() {
        //PKHUD.sharedHUD.contentView = PKHUDProgressView()
        //PKHUD.sharedHUD.show()
        ZKProgressHUD.show()
    }
    
    //關掉讀取按鈕
    func removeLoadingView() {
        //PKHUD.sharedHUD.hide()
        ZKProgressHUD.dismiss()
    }
    
    //跳出alert
    /*
    func showAlertWithWindow (_ onVC:UIViewController, Message msg:String) {
        showAlertView(Message: msg)
    }
    
    //自定義 alert
    func showAlertView (Message msg:String) {
        if msg == "" {
            return
        }
        
        let window = UIApplication.shared.keyWindow
        
        alertViewContainer = UIView(frame: CGRect.init(x: 0, y: 0, width: window!.bounds.width, height: window!.bounds.height))
        window!.addSubview(alertViewContainer);
        alertViewContainer.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        
        //決定字串高度
        let strL = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: window!.bounds.width - 100, height: 10))
        strL.text = msg
        strL.font = UIFont.systemFont(ofSize: 14)
        let height = strL.requiredHeight
        let boxHeight = 110 + height
        
        let alertViewBg = UIView.init(frame: CGRect.init(x: 25, y: window!.bounds.height/2 - 20 - boxHeight/2, width: window!.bounds.width - 50, height: boxHeight))
        alertViewContainer.addSubview(alertViewBg)
        
        alertViewBg.backgroundColor = .white
        alertViewBg.layer.cornerRadius = 10
        alertViewBg.clipsToBounds = true
        
        //頂部紅色條
        let topView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: alertViewBg.frame.size.width, height: 30))
        topView.backgroundColor = Color_Main_Red
        alertViewBg.addSubview(topView)
        
        //字
        strL.frame = CGRect.init(x: 25, y: 45, width: alertViewBg.frame.size.width - 50, height: height)
        strL.textAlignment = .center
        strL.numberOfLines = 0
        alertViewBg.addSubview(strL)
        
        //按鈕
        let btn = UIButton.init(frame: CGRect.init(x: alertViewBg.frame.size.width * 0.2, y: boxHeight - 50, width: alertViewBg.frame.size.width * 0.6, height: 35))
        btn.layer.cornerRadius = btn.frame.size.height/2
        btn.layer.borderColor = Color_Main_Red.cgColor
        btn.layer.borderWidth = 0.5
        btn.addTarget(self, action: #selector(removeAlert), for: .touchUpInside)
        //btn.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        btn.setTitle(NSLocalizedString("JustOK", comment: ""), for: .normal)
        btn.setTitleColor(Color_Main_Red, for: .normal)
        alertViewBg.addSubview(btn)
    }*/
    
    func showAlertWithWindow (_ onVC:UIViewController, Message msg:String) {
        showAlertView(Message: msg, ConfrimStr: NSLocalizedString("cancelForError", comment: ""))
    }
    
    //跳出alert
    func showNormalAlertWithWindow (_ onVC:UIViewController, Message msg:String) {
        showAlertView(Message: msg, ConfrimStr: NSLocalizedString("cancel", comment: ""))
    }
    
    //自定義 alert
    func showAlertView (Message msg:String, ConfrimStr cancelstr:String) {
        if msg == "" {
            return
        }
        
        let window = UIApplication.shared.keyWindow
        
        alertViewContainer = UIView(frame: CGRect.init(x: 0, y: 0, width: window!.bounds.width, height: window!.bounds.height))
        window!.addSubview(alertViewContainer);
        alertViewContainer.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        
        //決定字串高度
        let strL = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: window!.bounds.width - 100, height: 10))
        strL.text = msg
        strL.font = UIFont.systemFont(ofSize: 14)
        let height = strL.requiredHeight
        let boxHeight = 110 + height
        
        let alertViewBg = UIView.init(frame: CGRect.init(x: 25, y: window!.bounds.height/2 - 20 - boxHeight/2, width: window!.bounds.width - 50, height: boxHeight))
        alertViewContainer.addSubview(alertViewBg)
        
        alertViewBg.backgroundColor = .white
        alertViewBg.layer.cornerRadius = 10
        alertViewBg.clipsToBounds = true
        
        //頂部紅色條
        let topView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: alertViewBg.frame.size.width, height: 30))
        topView.backgroundColor = Color_Main_Red
        alertViewBg.addSubview(topView)
        
        //字
        strL.frame = CGRect.init(x: 25, y: 45, width: alertViewBg.frame.size.width - 50, height: height)
        strL.textAlignment = .center
        strL.numberOfLines = 0
        alertViewBg.addSubview(strL)
        
        //按鈕
        let btn = UIButton.init(frame: CGRect.init(x: alertViewBg.frame.size.width * 0.2, y: boxHeight - 50, width: alertViewBg.frame.size.width * 0.6, height: 35))
        btn.layer.cornerRadius = btn.frame.size.height/2
        btn.layer.borderColor = Color_Main_Red.cgColor
        btn.layer.borderWidth = 0.5
        btn.addTarget(self, action: #selector(removeAlert), for: .touchUpInside)
        btn.setTitle(cancelstr, for: .normal)
        btn.setTitleColor(Color_Main_Red, for: .normal)
        alertViewBg.addSubview(btn)
    }
    
    //自定義 alert
    func showAlertViewWithTitle (Title title:String, Message msg:String, ConfrimStr cancelstr:String) {
        if msg == "" {
            return
        }
        
        let window = UIApplication.shared.keyWindow
        
        alertViewContainer = UIView(frame: CGRect.init(x: 0, y: 0, width: window!.bounds.width, height: window!.bounds.height))
        window!.addSubview(alertViewContainer);
        alertViewContainer.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        
        //決定字串高度
        let strL = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: window!.bounds.width - 100, height: 10))
        strL.text = msg
        strL.font = UIFont.systemFont(ofSize: 14)
        let height = strL.requiredHeight
        let boxHeight = 130 + height
        
        let alertViewBg = UIView.init(frame: CGRect.init(x: 25, y: window!.bounds.height/2 - 20 - boxHeight/2, width: window!.bounds.width - 50, height: boxHeight))
        alertViewContainer.addSubview(alertViewBg)
        
        alertViewBg.backgroundColor = .white
        alertViewBg.layer.cornerRadius = 10
        alertViewBg.clipsToBounds = true
        
        //頂部紅色條
        let topView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: alertViewBg.frame.size.width, height: 50))
        topView.backgroundColor = Color_Main_Red
        alertViewBg.addSubview(topView)
        
        let strTL = UILabel.init(frame: CGRect.init(x: 5, y: 5, width: alertViewBg.frame.size.width - 10, height: 50))
        strTL.text = title
        strTL.textColor = .white
        strTL.textAlignment = .center
        strTL.font = UIFont.boldSystemFont(ofSize: 16)
        topView.addSubview(strTL)
        
        //字
        strL.frame = CGRect.init(x: 25, y: 65, width: alertViewBg.frame.size.width - 50, height: height)
        strL.textAlignment = .center
        strL.numberOfLines = 0
        alertViewBg.addSubview(strL)
        
        //按鈕
        let btn = UIButton.init(frame: CGRect.init(x: alertViewBg.frame.size.width * 0.2, y: boxHeight - 50, width: alertViewBg.frame.size.width * 0.6, height: 35))
        btn.layer.cornerRadius = btn.frame.size.height/2
        btn.layer.borderColor = Color_Main_Red.cgColor
        btn.layer.borderWidth = 0.5
        btn.addTarget(self, action: #selector(removeAlert), for: .touchUpInside)
        btn.setTitle(cancelstr, for: .normal)
        btn.setTitleColor(Color_Main_Red, for: .normal)
        alertViewBg.addSubview(btn)
    }
    
    @objc func removeAlert () {
        alertViewContainer.removeFromSuperview()
        alertViewContainer = nil
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func saveIconImageToFile(Image img:UIImage) {
        if let data = img.jpegData(compressionQuality: 0.8) {
            let filename = getDocumentsDirectory().appendingPathComponent("myicon.jpg")
            try? data.write(to: filename)
            //FileManager.default.createFile(atPath: filename.absoluteString, contents: data, attributes: nil)
        }
    }
    
    func getIconImage() -> UIImage {
        let imagePAth = getDocumentsDirectory().appendingPathComponent("myicon.jpg")
        
        if FileManager.default.fileExists(atPath: imagePAth.path) {
            return UIImage(contentsOfFile: imagePAth.path)!
        }else{
            Dlog("not exist (\(imagePAth.absoluteString))")
            return UIImage.init(named: "profile_picture.png")!
        }
    }
    
    //MARK: - BlackWindow
    func showBlackWindow() {
        Dlog("BlackWindow Show")
        if blackWindow != nil {
            blackWindow.removeFromSuperview()
        }
        
        let window = UIApplication.shared.keyWindow
        blackWindow = UIView.init(frame: window!.bounds)
        blackWindow.backgroundColor = .black
        window?.addSubview(blackWindow)
    }
    
    func hideBlackWindow() {
        Dlog("BlackWindow Hide")
        if blackWindow != nil {
            blackWindow.removeFromSuperview()
        }
    }
}

extension AppDelegate : MessagingDelegate {
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
    }
    
    // [START refresh_token]
    
    internal func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken)")
        FirebaseToken = fcmToken ?? ""
        /*
        pushToken = fcmToken
        Messaging.messaging().subscribe(toTopic: "TOPIC_iOS") { error in
            print("Subscribed to weather topic")
        }*/
        
        //let dataDict:[String: String] = ["token": fcmToken]
        //NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
}

extension Alamofire.SessionManager{
    @discardableResult
    open func requestWithoutCache(
        _ url: URLConvertible,
        method: HTTPMethod = .post,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)// also you can add URLRequest.CachePolicy here as parameter
        -> DataRequest
    {
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: headers)
            urlRequest.cachePolicy = .reloadIgnoringCacheData // <<== Cache disabled
            let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
            return request(encodedURLRequest)
        } catch {
            // TODO: find a better way to handle error
            print(error)
            return request(URLRequest(url: URL(string: "http://example.com/wrong_request")!))
        }
    }
}
