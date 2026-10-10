//
//  MemberMainVC.swift
//  indogo
//
//  Created by mac on 2020/8/10.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MemberMainVC: UIViewController, CustomAlertDelegate {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var memberImgV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var phoneL: UILabel!
    @IBOutlet weak var pointL: UILabel!
    @IBOutlet weak var promoL: UILabel!
    @IBOutlet weak var reciterL: UILabel!
    @IBOutlet weak var transactionL: UILabel!
    @IBOutlet weak var callL: UILabel!
    @IBOutlet weak var aboutL: UILabel!
    @IBOutlet weak var termsL: UILabel!
    @IBOutlet weak var faqL: UILabel!
    @IBOutlet weak var logoutL: UILabel!
    @IBOutlet weak var deleteL: UILabel!
    @IBOutlet weak var eRecieptL: UILabel!
    @IBOutlet weak var eRecieptLb: UILabel!
    
    @IBOutlet weak var bonusBtn: UIButton!
    @IBOutlet weak var promoBtn: UIButton!
    
    var loadOnce = false
    var nowAction = 0
    
    //MARK: - API
    func getPointHistory() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_PointHistoryList;
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
                Dlog("todoEndpoint = \(todoEndpoint),responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                
                if result == ResponseState.ok {
                    AppDelegate.shared().pointRootShowHistory = true
                    AppDelegate.shared().changeRootOfFunc(Type: .sharing)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func editAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "MemberEditVC") as? MemberEditVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func pointAction(_ sender: Any) {
        getPointHistory()
    }
    
    @IBAction func promoAction(_ sender: Any) {
        promoBtn.isHidden = true
        let userDefaults = UserDefaults.standard
        userDefaults.set("1", forKey: "isShowPromoBtn")
        userDefaults.synchronize()
        
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransfePreCountVC") as? TransfePreCountVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func eRecieptAction(_ sender: Any) {
        bonusBtn.isHidden = true
        let userDefaults = UserDefaults.standard
        userDefaults.set("1", forKey: "isShowERecieptBtn")
        userDefaults.synchronize()
        
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "BonusSelectVC") as? BonusSelectVC
        nextVC?.backTitle = NSLocalizedString("ereciept", comment: "")
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
        /*
        let urlPath = "https://invoice.indogo.com.tw/alistGoVN?arc=\(AppDelegate.shared().getRemeberedAccount())&pass=\(String(describing: AppDelegate.shared().getRemeberedAccount().base64EncodedString()!))"
        Dlog("url = \(urlPath)")
        
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "PureWebVC") as? PureWebVC
        nextVC?.setTitleAndCallURL(URL: urlPath, Title: NSLocalizedString("Profile Main eReciept", comment: ""))
        self.navigationController?.pushViewController(nextVC!, animated: true)
         */
    }
    
    @IBAction func ticketAction(_ sender: Any) {
        let urlPath = "https://ticket.indogo.com.tw/alistGoVN?arc=\(AppDelegate.shared().getRemeberedAccount())&pass=\(String(describing: AppDelegate.shared().getRemeberedAccount().base64EncodedString()!))"
        Dlog("url = \(urlPath)")
        
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "PureWebVC") as? PureWebVC
        nextVC?.setTitleAndCallURL(URL: urlPath, Title: NSLocalizedString("Profile Main eRecieptB", comment: ""))
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func reciteAction(_ sender: Any) {
        AppDelegate.shared().transactionObj.recipient_type = 1
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "RecipientListVC") as? RecipientListVC
        nextVC!.canSelectForTransfer = false
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func tansactionAction(_ sender: Any) {
        AppDelegate.shared().changeRootOfFunc(Type: .transState)
    }
    
    @IBAction func callAction(_ sender: Any) {
        let phone = "0287925880"
        //let extensionNum = "2211"
        let cleanPhoneNumber = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        let urlString:String = "tel://\(cleanPhoneNumber)"

        if let phoneCallURL = URL(string: urlString) {
            if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
        /*
        let url = URL(string: "telprompt:0287928773")
        if UIApplication.shared.canOpenURL(url!) {
            //UIApplication.shared.open(url!)
            UIApplication.shared.open(url!, options: [:], completionHandler:
                 nil)
        }*/
    }
    
    @IBAction func aboutAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "PureWebVC") as? PureWebVC
        nextVC?.setTitleAndCallURL(URL: "https://govnprod.indogo.link/tomcat_images/GOVN_Info.html", Title: NSLocalizedString("Profile Main About", comment: ""))
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func termsAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "MemberUseAgreementVC") as? MemberUseAgreementVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func faqAction(_ sender: Any) {
        //改成到新畫面
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "SpecialPageVC") as? SpecialPageVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
        //let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "PureWebVC") as? PureWebVC
        //nextVC?.setTitleAndCallURL(URL: "https://govnprod.indogo.link/tomcat_images/GOVN_faq.html", Title: NSLocalizedString("Profile Main Faq", comment: ""))
        //self.navigationController?.pushViewController(nextVC!, animated: true)
        
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        AppDelegate.shared().userLogout()
        AppDelegate.shared().changeRootOfFunc(Type: .main)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameL.text = AppDelegate.shared().memberData["member_name"]
        phoneL.text = AppDelegate.shared().memberData["app_phone_no"]
        backL.text = NSLocalizedString("Profile Main Title", comment: "")
        pointL.text = NSLocalizedString("Profile Main Point", comment: "")
        promoL.text = NSLocalizedString("New Function Promo Words", comment: "")
        reciterL.text = NSLocalizedString("Profile Main Reciter", comment: "")
        transactionL.text = NSLocalizedString("Profile Main Transaction", comment: "")
        callL.text = NSLocalizedString("Profile Main Call", comment: "")
        aboutL.text = NSLocalizedString("Profile Main About", comment: "")
        termsL.text = NSLocalizedString("Profile Main Terms", comment: "")
        faqL.text = NSLocalizedString("Debate Page Title", comment: "")
        logoutL.text = NSLocalizedString("Profile Main Logout", comment: "")
        eRecieptL.text = NSLocalizedString("Profile Main eReciept", comment: "")
        eRecieptLb.text = NSLocalizedString("Profile Main eRecieptB", comment: "")
        
        memberImgV.contentMode = .scaleAspectFill
        memberImgV.layer.cornerRadius = memberImgV.frame.size.height/2
        memberImgV.clipsToBounds = true
        
        let userDefaults = UserDefaults.standard
        if userDefaults.string(forKey: "isShowERecieptBtn") != nil {
            bonusBtn.isHidden = true
        }
        if userDefaults.string(forKey: "isShowPromoBtn") != nil {
            promoBtn.isHidden = true
        }
        
        bonusBtn.setTitle(NSLocalizedString("New Function Btn Words", comment: ""), for: .normal)
        promoBtn.setTitle(NSLocalizedString("New Function Btn Words", comment: ""), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        memberImgV.image = AppDelegate.shared().getIconImage()
        
        if loadOnce {
            AppDelegate.shared().showTopButton()
            return
        }
        
        loadOnce = true
        
        //頂部兩個按鈕
        AppDelegate.shared().topMargin = self.view.safeAreaInsets.top
        AppDelegate.shared().addTopButton()
        
        AppDelegate.shared().nowBottomMenuType = .profile
        AppDelegate.shared().bottomMenu.paintMenu()
        setUpDeleteL()
        
        bonusBtn.layer.cornerRadius = bonusBtn.frame.height / 2
        bonusBtn.layer.backgroundColor = Color_Main_Red.cgColor
        promoBtn.layer.cornerRadius = promoBtn.frame.height / 2
        promoBtn.layer.backgroundColor = Color_Main_Red.cgColor
    }
    
    func setUpDeleteL() {
        // 設置UILabel的文本顏色為白色
        deleteL.textColor = UIColor.white
        
        // 創建一個NSMutableAttributedString
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("Delete Sting 1", comment: "")+NSLocalizedString("Delete Sting 2", comment: ""))
        
        // 創建紅色文字和底線的屬性
        let redAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.red,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        // 添加紅色文字和底線到指定的範圍
        let range = (attributedString.string as NSString).range(of: NSLocalizedString("Delete Sting 2", comment: ""))
        attributedString.addAttributes(redAttributes, range: range)
        
        // 設置UILabel的attributedText
        deleteL.attributedText = attributedString
        
        // 添加點擊手勢處理程序
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        deleteL.isUserInteractionEnabled = true
        deleteL.addGestureRecognizer(tapGesture)
    }
    
    @objc func labelTapped() {
        // 在這裡處理點擊UILabel的動作
        nowAction = 0
        let customAlert = CustomAlertView.init(frame: self.view.frame)
        customAlert.initSpecialAlert(Title: "Bạn có chắc muốn xóa tài khoản này không?", Content: "Nhấn ĐỒNG Ý để yêu cầu xóa tài khoản của bạn\nLưu ý: Tài khoản đã xóa không thể sử dụng lại.", NextBtn1Str: "ĐỒNG Ý", CancelBtn1Str: "Quay lại")
        self.view.addSubview(customAlert)
        customAlert.customDelegate = self
    }
    
    func customAlertnextAction(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        if nowAction == 0 {
            deleteMember()
        } else if nowAction == 1 {
            AppDelegate.shared().userLogout()
            AppDelegate.shared().changeRootOfFunc(Type: .main)
        }
    }
    
    func customAlertnextActionSecond(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        
    }
    
    func deleteMember() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken,"arc_no":AppDelegate.shared().getRemeberedAarcNo()]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_DeleteMember
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
                    self.nowAction = 1
                    let customAlert = CustomAlertView.init(frame: self.view.frame)
                    customAlert.initSimpleAlert(Title: "", Content: "GoVn đã nhận được yêu cầu xóa tài khoản của bạn", NextBtn1Str: "Đóng")
                    self.view.addSubview(customAlert)
                    customAlert.customDelegate = self
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
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
