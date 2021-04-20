//
//  TransferPointVC.swift
//  indogo
//
//  Created by mac on 2020/8/22.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class TransferPointVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var iconImgV: UIImageView!
    
    @IBOutlet weak var topScrollView: UIScrollView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var phoneL: UILabel!
    @IBOutlet weak var pointL: UILabel!
    
    @IBOutlet weak var choseBgV: UIView!
    @IBOutlet weak var choseTitleL: UILabel!
    @IBOutlet weak var choseNextBtn: UIButton!
    @IBOutlet weak var choseCancelBtn: UIButton!
    @IBOutlet weak var choseTableView: UITableView!
    
    @IBOutlet weak var warningNextBtn: UIButton!
    @IBOutlet weak var warningContentL: UILabel!
    @IBOutlet weak var warningTitleL: UILabel!
    @IBOutlet weak var warningBgV: UIView!
    @IBOutlet weak var alertContentTitleL: UILabel!
    @IBOutlet weak var alertContentL: UILabel!
    @IBOutlet weak var alertNextBtn: UIButton!
    
    @IBOutlet weak var alertIconImgV: UIImageView!
    @IBOutlet weak var alertTitleL: UILabel!
    @IBOutlet weak var alertBgV: UIView!
    @IBOutlet weak var inputBgV: UIView!
    @IBOutlet weak var inputTitleL: UILabel!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var pointView: UIView!
    
    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var pointTextfield: UITextField!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var webView: WKWebView!
    var transferSucceed = false
    var chosedAry:[Bool] = []
    var chosedIndx = -1
    var inSecondStep = false
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return AppDelegate.shared().transferFriendListObj.count
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "TransferMemberChoseTableViewCell", for: indexPath) as! TransferMemberChoseTableViewCell
       let cellData = AppDelegate.shared().transferFriendListObj[indexPath.row]
       if cellData.memberStyle == .normal {
           cell.nameL.text = cellData.name
           cell.phoneL.text = phoneTextfield.text
           cell.styleImgV.image = UIImage.init(named: "icon_remit.png")
       } else {
           cell.nameL.text = cellData.name
           cell.phoneL.text = cellData.phone
           cell.styleImgV.image = UIImage.init(named: "icon_shopping.png")
       }
       cell.chosed = chosedAry[indexPath.row]
       cell.setUpImgIcon()
       cell.parentVC = self
       cell.index = indexPath.row
       cell.backgroundColor = .clear
       cell.selectionStyle = .none
       return cell
    }
    
    //MARK: - API
    public func getAgrrementContent() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "doc_name":"點數轉移規則"]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_GetDoc;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
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
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "點數轉移規則")
                if result == ResponseState.ok {
                    self.nextBtn.isEnabled = true
                    self.webView.loadHTMLString(AppDelegate.shared().tempTransferAgreementHtmlContent, baseURL: nil)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func checkTransferFirstStep(Mode mode:Int) {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "phone":phoneTextfield.text!, "mode":mode]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_TransferPointFirstStep;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        AppDelegate.shared().transferStepOneListObj = []
        
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
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "\(mode)")
                if result == ResponseState.ok {
                    if mode == 1 {
                        //self.checkTransferFirstStep(Mode: 2)
                        self.transferSecondStep()
                        return
                    }
                    
                    let count = AppDelegate.shared().transferFriendListObj.count
                    
                    if count == 0 {
                        self.showAlertWithText(Title: NSLocalizedString("Point Transfer Alert No Member Title", comment: ""), Content: NSLocalizedString("Point Transfer Alert No Member Content", comment: ""))
                        return
                    } else {
                        self.showStep2()
                    }
                } else if result == ResponseState.error {
                    self.showWarningWithText(Content: AppDelegate.shared().apiBackContentStr)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func transferSecondStep() {
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "remit_point":pointTextfield.text!]
        if AppDelegate.shared().transferStepOneListObj.count == 0 {
            return
        }
        
        let data = AppDelegate.shared().transferStepOneListObj[0]
        //AppDelegate.shared().transferFriendListObj[chosedIndx]
        if data.memberStyle == .normal {
            parameters["mode"] = 1
            parameters["friend_id"] = Int(data.idStr)
        } else if data.memberStyle == .shop {
            parameters["mode"] = 2
            parameters["phone"] = data.phone
        }
        
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_TransferPointSecondStep;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
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
                    self.transferSucceed = true
                    self.showAlertWithText(Title: NSLocalizedString("Point Transfer Step2 Successed SubTitle", comment: ""), Content: NSLocalizedString("Point Transfer Step2 Successed Content A", comment: "") + self.pointTextfield.text! + NSLocalizedString("Point Transfer Step2 Successed Content B", comment: ""))
                }/* else {
                    self.showWarningWithText(Content: AppDelegate.shared().apiBackContentStr)
                }*/ else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Utility
    func showStep2() {
        alertBgV.isHidden = true
        inputBgV.isHidden = true
        warningBgV.isHidden = true
        choseBgV.isHidden = false
        
        chosedAry = []
        for _ in 0..<AppDelegate.shared().transferFriendListObj.count {
            chosedAry.append(false)
        }
        
        choseTableView.delegate = self
        choseTableView.dataSource = self
        choseTableView.reloadData()
        
    }
    
    func showAlertWithText(Title title:String, Content content:String) {
        alertBgV.isHidden = false
        inputBgV.isHidden = true
        warningBgV.isHidden = true
        choseBgV.isHidden = true
        
        alertContentTitleL.text = title
        alertContentL.text = content
        
        if transferSucceed {
            alertTitleL.text = NSLocalizedString("Point Transfer Step2 Successed Title", comment: "")
            alertIconImgV.image = UIImage.init(named: "success2.png")
        } else {
            alertTitleL.text = NSLocalizedString("Point Transfer Alert Title", comment: "")
            alertIconImgV.image = UIImage.init(named: "failed.png")
        }
    }
    
    func showWarningWithText(Content content:String) {
        alertBgV.isHidden = true
        inputBgV.isHidden = true
        warningBgV.isHidden = false
        choseBgV.isHidden = true
        
        warningContentL.text = content
    }
    
    func checkNextBtnState() {
        var pass = true
        
        if phoneTextfield.text?.count == 0 || pointTextfield.text?.count == 0 {
            pass = false
        }
        
        if pass {
            nextBtn.backgroundColor = Color_Main_Red
            nextBtn.isEnabled = true
        } else {
            nextBtn.backgroundColor = .clear
            nextBtn.isEnabled = false
        }
    }
    
    //MARK: - Text Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkNextBtnState()
    }
    
    //MARK: - Button-Action
    public func callFromCell(Index idx:Int, Result result:Bool) {
        for i in 0..<AppDelegate.shared().transferFriendListObj.count {
            chosedAry[i] = false
        }
        chosedAry[idx] = result
        choseTableView.reloadData()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        
        let point = Int(AppDelegate.shared().memberData["remit_point"]!)
        let nowPoint = Int(pointTextfield.text!)
        
        //點數不夠
        if nowPoint! > point! {
            self.showAlertWithText(Title: NSLocalizedString("Point Transfer Alert Point Lack Title", comment: ""), Content: NSLocalizedString("Point Transfer Alert Point Lack Content", comment: ""))
            return
        }
        
        AppDelegate.shared().transferFriendListObj = []
        checkTransferFirstStep(Mode: 1)
    }
    
    @IBAction func choseNextAction(_ sender: Any) {
        chosedIndx = -1
        for i in 0..<AppDelegate.shared().transferFriendListObj.count {
            if chosedAry[i] == true {
                chosedIndx = i
                break
            }
        }
        
        if chosedIndx == -1 {
            return
        } else {
            inSecondStep = true
            transferSecondStep()
        }
    }
    
    @IBAction func choseCancelAction(_ sender: Any) {
        choseBgV.isHidden = true
        inputBgV.isHidden = false
    }
    
    
    @IBAction func alertNextAction(_ sender: Any) {
        if transferSucceed {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        alertBgV.isHidden = true
        inputBgV.isHidden = false
    }
    
    @IBAction func warningNextAction(_ sender: Any) {
        if inSecondStep {
            warningBgV.isHidden = true
            alertBgV.isHidden = true
            inputBgV.isHidden = true
            choseBgV.isHidden = false
        } else {
            warningBgV.isHidden = true
            alertBgV.isHidden = true
            inputBgV.isHidden = false
            choseBgV.isHidden = true
        }
        
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        backL.text = NSLocalizedString("Point Transfer Title", comment: "")
        inputTitleL.text = NSLocalizedString("Point Transfer Input Title", comment: "")
        
        phoneTextfield.placeholder = NSLocalizedString("Point Transfer Input Phone Place Holder", comment: "")
        pointTextfield.placeholder = NSLocalizedString("Point Transfer Input Point Place Holder", comment: "")
        phoneTextfield.keyboardType = .phonePad
        pointTextfield.keyboardType = .numberPad
        phoneTextfield.delegate = self
        pointTextfield.delegate = self
        
        alertNextBtn.setTitle(NSLocalizedString("back Show", comment: ""), for: .normal)
        warningNextBtn.setTitle(NSLocalizedString("back Show", comment: ""), for: .normal)
        
        nextBtn.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.layer.backgroundColor = UIColor.clear.cgColor
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.layer.borderWidth = 0.5
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        
        phoneView.layer.cornerRadius = phoneView.frame.size.height/2
        pointView.layer.cornerRadius = pointView.frame.size.height/2
        
        inputBgV.layer.cornerRadius = 10
        inputBgV.clipsToBounds = true
        
        iconImgV.image = AppDelegate.shared().getIconImage()
        iconImgV.contentMode = .scaleAspectFill
        iconImgV.layer.cornerRadius = iconImgV.frame.size.height/2
        iconImgV.clipsToBounds = true
        
        webView.clipsToBounds = true
        webView.layer.cornerRadius = 8
        nameL.text = AppDelegate.shared().memberData["member_name"]!
        phoneL.text = AppDelegate.shared().memberData["app_phone_no"]!
        pointL.text = AppDelegate.shared().memberData["remit_point"]!
        
        self.nextBtn.isEnabled = false
        
        choseBgV.isHidden = true
        choseBgV.layer.cornerRadius = 8
        choseBgV.layer.borderColor = UIColor.black.cgColor
        choseBgV.layer.borderWidth = 0.5
        choseBgV.clipsToBounds = true
        choseNextBtn.layer.cornerRadius = choseNextBtn.frame.size.height/2
        choseCancelBtn.layer.cornerRadius = choseCancelBtn.frame.size.height/2
        choseCancelBtn.backgroundColor = .clear
        choseCancelBtn.layer.borderColor = Color_Main_Red.cgColor
        choseCancelBtn.layer.borderWidth = 0.5
        choseTableView.backgroundColor = .clear
        choseTableView.separatorStyle = .none
        
        let nib = UINib(nibName: "TransferMemberChoseTableViewCell", bundle: nil)
        choseTableView.register(nib, forCellReuseIdentifier: "TransferMemberChoseTableViewCell")
        choseTableView.bounces = false
        
        choseTitleL.text = NSLocalizedString("Point Transfer Step2 Title", comment: "")
        choseNextBtn.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
        choseCancelBtn.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        
        alertBgV.isHidden = true
        alertBgV.layer.cornerRadius = 8
        alertBgV.layer.borderColor = UIColor.black.cgColor
        alertBgV.layer.borderWidth = 0.5
        alertBgV.clipsToBounds = true
        alertNextBtn.layer.cornerRadius = alertNextBtn.frame.size.height/2
        alertTitleL.text = NSLocalizedString("Point Transfer Alert Title", comment: "")
        
        warningBgV.isHidden = true
        warningBgV.layer.cornerRadius = 8
        warningBgV.layer.borderColor = UIColor.black.cgColor
        warningBgV.layer.borderWidth = 0.5
        warningBgV.clipsToBounds = true
        warningNextBtn.layer.cornerRadius = warningNextBtn.frame.size.height/2
        warningTitleL.text = NSLocalizedString("Point Transfer Alert Title", comment: "")
        
        getAgrrementContent()
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
