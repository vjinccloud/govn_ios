//
//  TransferMainVC.swift
//  indogo
//
//  Created by mac on 2020/9/2.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class TransferMainVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var boxV: UIView!
    @IBOutlet weak var upNameL: UILabel!
    @IBOutlet weak var upTextLineV: UIView!
    @IBOutlet weak var downNameL: UILabel!
    @IBOutlet weak var downTextLineV: UIView!
    @IBOutlet weak var upTextField: UITextField!
    @IBOutlet weak var downTextField: UITextField!
    @IBOutlet weak var kirimL: UILabel!
    @IBOutlet weak var valueL: UILabel!
    @IBOutlet weak var pointL: UILabel!
    @IBOutlet weak var pointLeftL: UILabel!
    @IBOutlet weak var totalNTDTitleL: UILabel!
    @IBOutlet weak var totalNTDL: UILabel!
    @IBOutlet weak var leftBgV: UIView!
    @IBOutlet weak var leftPL: UILabel!
    @IBOutlet weak var leftTotalPL: UILabel!
    @IBOutlet weak var leftDownL: UILabel!
    @IBOutlet weak var rightBgV: UIView!
    @IBOutlet weak var rightTitleL: UILabel!
    @IBOutlet weak var downChangeBtn: UIButton!
    @IBOutlet weak var downArrowImgV: UIImageView!
    @IBOutlet weak var downTypeL: UILabel!
    
    @IBOutlet weak var headTitleL: UILabel!
    @IBOutlet weak var promteShowL: UILabel!
    @IBOutlet weak var topBarImg1: UIImageView!
    @IBOutlet weak var topBarL1: UILabel!
    @IBOutlet weak var topBarImg2: UIImageView!
    @IBOutlet weak var topBarL2: UILabel!
    @IBOutlet weak var topBarImg3: UIImageView!
    @IBOutlet weak var topBarL3: UILabel!
    
    @IBOutlet weak var topbox_barLength: NSLayoutConstraint!
    @IBOutlet weak var topbox_barbackV: UIView!
    @IBOutlet weak var topbox_barV: UIView!
    @IBOutlet weak var topbox_titleL: UILabel!
    @IBOutlet weak var topbox_MoneyL: UILabel!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    var moneyType:[String] = []
    var choseMoneyType = 0
    var choseTag = 0
    var pickerView:UIPickerView!
    var pickBackView:UIView!
    var kursValueShow:Double = 0
    
    var topBarSelectIdx = 0
    
    var loadOnce = false
    var kursValue:Double = 0
    var calculateStyle = 0 //0是以台幣為主計算，1是以印尼幣為主
    var coinTransferPercent = 1
    var serviceCharge = 0
    var decresedCharge = 0
    var decresedChargeUnit = 50
    var totalChage = 0
    var statusNow = 0
    var discountCodeValue = 0
    private var isManualRefreshing = false
    private let manualRefreshTriggerDistance: CGFloat = 90
    private lazy var manualRefreshIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .large)
        } else {
            indicator = UIActivityIndicatorView(style: .whiteLarge)
        }
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        return indicator
    }()
    private var manualRefreshIndicatorTopConstraint: NSLayoutConstraint?
    private var manualRefreshIndicatorBaseOffset: CGFloat = 8
    private var currentPullDistance: CGFloat = 0
    
    //MARK: - TopBar
    func initTopBar() {
        var imag1Str = "bank_account"
        var imag2Str = "cash_pick_up"
        var imag3Str = "doortodoor"
        
        var colorL1 = UIColor.darkGray
        var colorL2 = UIColor.darkGray
        var colorL3 = UIColor.darkGray
        var hideMoney = true
        
        if topBarSelectIdx == 0 {
            imag1Str = "bank_account_select"
            colorL1 = UIColor.white
        } else if topBarSelectIdx == 1 {
            imag2Str = "cash_pick_up_select"
            colorL2 = UIColor.white
        } else if topBarSelectIdx == 2 {
            imag3Str = "doortodoor_select"
            colorL3 = UIColor.white
            hideMoney = false
        }
        
        downChangeBtn.isHidden = hideMoney
        downArrowImgV.isHidden = hideMoney
        
        topBarImg1.image = UIImage.init(named: imag1Str)
        topBarImg2.image = UIImage.init(named: imag2Str)
        topBarImg3.image = UIImage.init(named: imag3Str)
        
        topBarL1.textColor = colorL1
        topBarL2.textColor = colorL2
        topBarL3.textColor = colorL3
        
        topBarL1.text = NSLocalizedString("Top Bar L1", comment: "")
        topBarL2.text = NSLocalizedString("Top Bar L2", comment: "")
        topBarL3.text = NSLocalizedString("Top Bar L3", comment: "")
    }
    
    //若轉換不同形式，需要重整
    func initCondition() {
        topBarSelectIdx = 0
        choseMoneyType = 0
        downTypeL.text = moneyType[choseMoneyType]
        
        upTextField.text = "1"
        checkAndCalculateValue(UseStyle: 0, NweString: "")
    }
    
    @IBAction func topBarBtn1Action(_ sender: Any) {
        if topBarSelectIdx == 0 {
            return
        }
        
        serviceCharge = Int(AppDelegate.shared().memberData["service_charge"]!)!
        
        initCondition()
        initTopBar()
        clearCharge()
        
        checkAndCalculateValue(UseStyle:0, NweString: "")
    }
    
    @IBAction func topBarBtn2Action(_ sender: Any) {
        if topBarSelectIdx == 1 {
            return
        }
        
        serviceCharge = Int(AppDelegate.shared().memberData["service_charge_2"]!)!
        
        initCondition()
        topBarSelectIdx = 1
        initTopBar()
        clearCharge()
        
        checkAndCalculateValue(UseStyle:0, NweString: "")
    }
    
    @IBAction func topBarBtn3Action(_ sender: Any) {
        if topBarSelectIdx == 2 {
            return
        }
        
        serviceCharge = Int(AppDelegate.shared().memberData["service_charge_3"]!)!
        
        initCondition()
        topBarSelectIdx = 2
        initTopBar()
        clearCharge()
        
        checkAndCalculateValue(UseStyle:0, NweString: "")
    }
    
    @IBAction func changeMoneyTypeAction(_ sender: Any) {
        if topBarSelectIdx != 2 {
            return
        }
        
        openPicker()
    }
    
    //MARK: - UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return moneyType[row]
    }
    
    @objc func openPicker() {
        //也要關掉textfield
        closeText()
        
        let tempWindow = UIApplication.shared.keyWindow
        tempWindow?.bringSubviewToFront(self.pickBackView)
        self.pickBackView.center.y = (tempWindow?.frame.size.height)!+270/2
        self.pickBackView.isHidden = false
        self.pickerView.reloadAllComponents()
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pickBackView.center.y = (tempWindow?.frame.size.height)!-270/2
            }, completion: { _ in
                
        })
    }
    
    @objc func closePicker() {
        let tempWindow = UIApplication.shared.keyWindow
        self.pickBackView.center.y = (tempWindow?.frame.size.height)!-270/2
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pickBackView.center.y = (tempWindow?.frame.size.height)!+270/2
            }, completion: { _ in
                self.pickBackView.isHidden = true
        })
    }
    
    @objc func finishSelect() {
        closePicker()
        let select = self.pickerView.selectedRow(inComponent: 0)
        if choseMoneyType == select {
            return
        }
        
        choseMoneyType = select
        downTypeL.text = moneyType[choseMoneyType]
        upTextField.text = "1"
        checkAndCalculateValue(UseStyle: 0, NweString: "")
        
        if choseMoneyType == 1 {
            upTextField.text = "\(kursValueShow)"
            downTextField.text = "1"
        }
        
    }
    
    //MARK: - Utility
    func addPickerView () {
        let tempWindow = UIApplication.shared.keyWindow
        pickBackView = UIView(frame: CGRect(x: 0, y: (tempWindow?.frame.height)!, width: view.frame.width, height: 260))
        
        // Toolbar
        let btnDone = UIBarButtonItem(title: "  OK  ", style: .plain, target: self, action: #selector(finishSelect))
        //UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finishSelect))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "  Cancel  ", style: .plain, target: self, action: #selector(closePicker))
        
        let barAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: pickBackView.frame.width, height: 44))
        barAccessory.barStyle = .default
        barAccessory.isTranslucent = false
        barAccessory.items = [cancelButton, spaceButton, btnDone]
        pickBackView.addSubview(barAccessory)
        
        // Month UIPIckerView
        pickerView = UIPickerView(frame: CGRect(x: 0, y: barAccessory.frame.height, width: view.frame.width, height: pickBackView.frame.height-barAccessory.frame.height))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
        pickBackView.addSubview(pickerView)
        
        tempWindow?.addSubview(pickBackView)
        pickBackView.isHidden = true
    }
    
    func setUpKursValue() {
        if choseMoneyType == 1 {
            kursValueShow = Double(AppDelegate.shared().memberData["usd_kurs_value"]!)!
            kursValue = 1/Double(AppDelegate.shared().memberData["usd_kurs_value"]!)!
        } else {
            kursValueShow = Double(AppDelegate.shared().memberData["usd_kurs_value"]!)!
            kursValue = Double(AppDelegate.shared().memberData["kurs_value"]!)!
        }
        
        if topBarSelectIdx == 0 {
            serviceCharge = Int(AppDelegate.shared().memberData["service_charge"]!)!
        } else if topBarSelectIdx == 1 {
            serviceCharge = Int(AppDelegate.shared().memberData["service_charge_2"]!)!
        } else if topBarSelectIdx == 2 {
            serviceCharge = Int(AppDelegate.shared().memberData["service_charge_3"]!)!
        }
        
    }
    
    func justCalculateValue(UseStyle style:Int, NweString newString:String) {

        var upValue = Int(newString.replacingOccurrences(of: ",", with: ""))
        var downValue = Int(newString.replacingOccurrences(of: ",", with: ""))
         
        if style == 0 {
            if upTextField.text == "" {
                upTextField.text = "1"
                upValue = 1
            }
            downValue = Int(round(Double(upValue!) * kursValue))
            if downValue! < 1 {
                downValue! = 1
            }
        } else if style == 1 {
            if downTextField.text == "" {
                downTextField.text = "1"
                downValue = 1
            }
            upValue = calculateNtdValue(from: downValue!)
            if upValue! < 1 {
                upValue! = 1
            }
        }
        
        if upTextField.isFirstResponder == false {
            upTextField.text = "\(upValue ?? 1)".stringToIntDecimalString()
        }
        
        if downTextField.isFirstResponder == false {
            downTextField.text = "\(downValue ?? 1)".stringToIntDecimalString()
        }
    }
    
    func checkAndCalculateValue(UseStyle style:Int, NweString newString:String) {
        setUpKursValue()
        
        var string = newString
        
        var upValue = Int(upTextField.text!.replacingOccurrences(of: ",", with: ""))
        var downValue = Int(downTextField.text!.replacingOccurrences(of: ",", with: ""))
         
        if style == 0 {
            if upTextField.text == "" {
                upTextField.text = "1"
                upValue = 1
            }
            downValue = Int(round(Double(upValue ?? 1) * kursValue))
            if downValue! < 1 {
                downValue! = 1
            }
        } else if style == 1 {
            if downTextField.text == "" {
                downTextField.text = "1"
                downValue = 1
            }
            upValue = calculateNtdValue(from: downValue!)
            if upValue! < 1 {
                upValue! = 1
            }
        } else if style == 2 {
            if string == "" {
                string = "1"
                //upTextField.text = "1"
            }
            
            upValue = Int(string)
            downValue = Int(round(Double(upValue!) * kursValue))
            downTextField.text = "\(downValue ?? 1)".stringToIntDecimalString()
        } else if style == 3 {
            if string == "" {
                string = "1"
                //downTextField.text = "1"
            }
            
            downValue = Int(string)
            upValue = calculateNtdValue(from: downValue!)
            if upValue! < 1 {
                upValue! = 1
            }
            upTextField.text = "\(upValue ?? 1)".stringToIntDecimalString()
        }
        
        if style < 2 {
            if upTextField.isFirstResponder == false {
                upTextField.text = "\(upValue ?? 1)".stringToIntDecimalString()
            }
            
            if downTextField.isFirstResponder == false {
                downTextField.text = "\(downValue ?? 1)".stringToIntDecimalString()
            }
        }
        
        valueL.text = "\(serviceCharge)"
        let totalDiscount:Int = decresedCharge + discountCodeValue
        
        if totalDiscount == 0 {
            pointLeftL.text = "\(totalDiscount)"
        } else {
            pointLeftL.text = "-\(totalDiscount)"
        }
        //20260504 舊的
        /*
        if decresedCharge == 0 {
            pointLeftL.text = "\(decresedCharge)"
        } else {
            pointLeftL.text = "-\(decresedCharge)"
        }
        
        totalChage = (upValue ?? 1) + serviceCharge - decresedCharge
         */
        
        totalChage = upValue! + serviceCharge - decresedCharge - discountCodeValue
        totalNTDL.text = "\(totalChage)".stringToIntDecimalString()
        
        Dlog("totalChage=\(totalChage), serviceCharge=\(serviceCharge), decresedCharge=\(decresedCharge)")
    }

    private func calculateNtdValue(from targetValue: Int) -> Int {
        let rawNtdValue = Double(targetValue) / kursValue

        if choseMoneyType == 0 { // VND 反算 NTD 時無條件進位
            return Int(ceil(rawNtdValue))
        }

        return Int(round(rawNtdValue))
    }
    
    //MARK: - Button Action
    private func updateUsePointButtonAppearance() {
        let isUsingPoints = decresedCharge > 0
        let availablePoints = Int(AppDelegate.shared().memberData["remit_point"]!) ?? 0
        leftTotalPL.text = "\(availablePoints - decresedCharge)"
        leftBgV.layer.backgroundColor = isUsingPoints ? UIColor.white.cgColor : UIColor.clear.cgColor
        leftDownL.textColor = isUsingPoints ? .black : .white
        leftTotalPL.textColor = isUsingPoints ? .black : .white
    }

    @IBAction func leftBtnDown(_ sender: Any) {
        updateUsePointButtonAppearance()
    }
    
    @IBAction func leftBtnOutside(_ sender: Any) {
        updateUsePointButtonAppearance()
    }
    
    @IBAction func leftBtnAction(_ sender: Any) {
        let value = Int(AppDelegate.shared().memberData["remit_point"]!)!
        
        if decresedCharge == serviceCharge {
            decresedCharge = 0
        } else {
            
            /*
            if decresedCharge > value {
                decresedCharge = 0
            }
            
            if decresedCharge > serviceCharge {
                decresedCharge = serviceCharge
            }*/
            
            if value >= serviceCharge {
                decresedCharge = serviceCharge
            } else {
                decresedCharge = 0
            }
            
        }
        
        checkAndCalculateValue(UseStyle: 0, NweString: "")
        updateUsePointButtonAppearance()
    }
    
    func clearCharge() {
        decresedCharge = 0
        updateUsePointButtonAppearance()
    }

    @IBAction func rightBtnAction(_ sender: Any) {
        
        if upTextField.text!.replacingOccurrences(of: ",", with: "") == "" || downTextField.text!.replacingOccurrences(of: ",", with: "") == "" {
            return
        }
        
        var ntdValue = 0
        //有小數點，換算成整數
        if upTextField.text!.contains(".")  {
            let value = Double(upTextField.text!.replacingOccurrences(of: ",", with: ""))!
            ntdValue = lround(value)
        } else {
            ntdValue = Int(upTextField.text!.replacingOccurrences(of: ",", with: ""))!
        }
        
        Dlog("ntdValue = \(ntdValue)")
        
        if ntdValue == 0 {
            return
        }
            
        var down2Value = 0
        //有小數點，換算成整數
        if downTextField.text!.contains(".")  {
            let value = Double(downTextField.text!.replacingOccurrences(of: ",", with: ""))!
            down2Value = lround(value)
        } else {
            down2Value = Int(downTextField.text!.replacingOccurrences(of: ",", with: ""))!
        }
        
        Dlog("downValue = \(down2Value)")
        
        if down2Value == 0 {
            return
        }
        
        AppDelegate.shared().transactionObj = TransactionObj()
        AppDelegate.shared().transactionObj.ntdValue = ntdValue //Int(upTextField.text!.replacingOccurrences(of: ",", with: ""))!
        //印尼盾必須再用台幣換算印尼盾(要對齊)
        //--should-- 20210608 把這函數所有 ceil 改成 round
        let downValue = Int(round(Double(AppDelegate.shared().transactionObj.ntdValue) * kursValue))
        AppDelegate.shared().transactionObj.targetValue = downValue
        AppDelegate.shared().transactionObj.feeValue = serviceCharge
        AppDelegate.shared().transactionObj.usePoint = decresedCharge + discountCodeValue
        AppDelegate.shared().transactionObj.totalNtdValue = totalChage
        AppDelegate.shared().transactionObj.recipient_type = topBarSelectIdx + 1
        AppDelegate.shared().transactionObj.currency = moneyType[choseMoneyType]
        
        //先檢查有無省份資料
        //20231217 改成都要檢查，因為省份有分
        getProvinceData(NeedNExt: true)
        
        /*
        if !AppDelegate.shared().hasProvinceData {
            getProvinceData(NeedNExt: true)
        } else {
            //送出前要查詢是否超過金額
            checkAmount()
        }*/
    }
    
    //MARK: - API
    public func callMemberData(completion: (() -> Void)? = nil) {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        if !isManualRefreshing {
            AppDelegate.shared().addLoadingView()
        }
        
        let todoEndpoint: String = API_CheckLogin;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { [weak self] response in
                defer {
                    completion?()
                }
                
                let shouldHideLoading = !(self?.isManualRefreshing ?? false)
                if shouldHideLoading {
                    AppDelegate.shared().removeLoadingView()
                }
                
                guard let self = self else { return }
                
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
                    self.setUpKursValue()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func callMemberData() {
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
                    self.setUpKursValue()
                    URLCache.shared.removeAllCachedResponses()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //取得省份資料
    func getProvinceData(NeedNExt next:Bool) {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "mode":"json"]
        
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        var todoEndpoint: String = API_Get_province_district
        
        if topBarSelectIdx == 2 {
            todoEndpoint = API_Get_province_districtDoorToDoor
        }
        
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
                //AppDelegate.shared().apiBackContentStr
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("province responseStr = \(responseStr ?? "")")
                    
                AppDelegate.shared().recipientListObjs = []
                AppDelegate.shared().recipientShownListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
               
                if result == ResponseState.ok {
                    AppDelegate.shared().hasProvinceData = true
                    if next {
                        //送出前要查詢是否超過金額
                        self.checkAmount()
                    }
                    URLCache.shared.removeAllCachedResponses()
                } else if result == ResponseState.error {
                    let msg = NSLocalizedString("Transfer Result Exceed", comment: "") + " " + AppDelegate.shared().apiBackContentStr.stringToIntDecimalString()
                    AppDelegate.shared().showAlertWithWindow(self, Message:msg)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func checkAmount() {
        
        //20231115
        var use_remit_point = 0
        if decresedCharge > 0 {
            use_remit_point = 1
        }
        
        //檢查金額要扣掉手續費
        let charge = Int(upTextField.text!.replacingOccurrences(of: ",", with: ""))!
        
        //let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":AppDelegate.shared().transactionObj.totalNtdValue, "use_remit_point":1]
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":charge, "use_remit_point":use_remit_point, "recipient_type":topBarSelectIdx + 1]
        var todoEndpoint: String = API_MemberRecipents;
        
        if AppDelegate.shared().discountForTransfer != "" {
            todoEndpoint = API_MemberRecipentsV2
            parameters["discount_code"] = AppDelegate.shared().discountCode
            parameters["discount_amt"] = AppDelegate.shared().discountForTransfer
        }
        
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
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
                //AppDelegate.shared().apiBackContentStr
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("responseStr = \(responseStr ?? "")")
                
                AppDelegate.shared().recipientListObjs = []
                AppDelegate.shared().recipientShownListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "RecipientListVC") as? RecipientListVC
                    nextVC!.canSelectForTransfer = true
                    self.navigationController?.pushViewController(nextVC!, animated: true)
                    URLCache.shared.removeAllCachedResponses()
                } else if result == ResponseState.error {
                    let msg = NSLocalizedString("Transfer Result Exceed", comment: "") + " " + AppDelegate.shared().apiBackContentStr.stringToIntDecimalString()
                    AppDelegate.shared().showAlertWithWindow(self, Message:msg)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                } else if result == ResponseState.maxExceed {
                    Dlog("AppDelegate.shared().tempTransferLeftAmount = \(AppDelegate.shared().tempTransferLeftAmount)")
                    self.upTextField.text = "\(AppDelegate.shared().tempTransferLeftAmount)"
                    self.justCalculateValue(UseStyle: 0, NweString: "\(AppDelegate.shared().tempTransferLeftAmount)")
                    let customAlert = CustomAlertView.init(frame: self.view.bounds)
                    customAlert.initAmountAlert(Title: NSLocalizedString("Exceed Maximun Amout Title", comment: ""), is509: AppDelegate.shared().transferErrorIs509)
                    self.view.addSubview(customAlert)
                    self.checkAndCalculateValue(UseStyle: 0, NweString: "")
                }
        }
    }
    
    func plotQuotaState() {
        topbox_MoneyL.text = String.stringToOnlyIntString(Number: AppDelegate.shared().transferQuotaLeft) + " NTD"
        
        if AppDelegate.shared().transferQuotaLeft == 0 || AppDelegate.shared().transferQuotaTotal == 0 {
            topbox_barLength.constant = 1
        } else {
            topbox_barLength.constant = topbox_barbackV.frame.width * (Double(AppDelegate.shared().transferQuotaLeft)/Double(AppDelegate.shared().transferQuotaTotal))
        }
    }
    
    public func getQuota(completion: (() -> Void)? = nil) {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken]
        let headers: HTTPHeaders = [:]
        if !isManualRefreshing {
            AppDelegate.shared().addLoadingView()
        }
        
        let todoEndpoint: String = API_GetQuota;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { [weak self] response in
                guard let self = self else {
                    completion?()
                    return
                }
                
                defer {
                    completion?()
                }
                
                let shouldHideLoading = !self.isManualRefreshing
                if shouldHideLoading {
                    AppDelegate.shared().removeLoadingView()
                }
                
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
                    self.plotQuotaState()
                    //self.getRecipents()
                } else if result == ResponseState.failed {
                    //AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Text Delegate
    func closeAll() {
        closeText()
        closePicker()
    }
    
    func closeText() {
        upTextField.resignFirstResponder()
        downTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        closePicker()
        if textField == upTextField {
            upTextField.text = upTextField.text!.replacingOccurrences(of: ",", with: "")
            if upTextField.text == "1" {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self, self.upTextField.isFirstResponder, self.upTextField.text == "1" else {
                        return
                    }
                    self.upTextField.selectAll(nil)
                }
            }
        } else if textField == downTextField {
            downTextField.text = downTextField.text!.replacingOccurrences(of: ",", with: "")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var mode = 0
        if textField == upTextField {
            mode = 0
        } else if textField == downTextField {
            mode = 1
        }
        checkAndCalculateValue(UseStyle: mode, NweString: "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if ((string == "0" || string == "") && (textField.text! as NSString).range(of: ".").location < range.location) {
            return true
        }
        
        var isEmpty = false
        var newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if newString == "" {
            isEmpty = true
            newString = "1"
        }

        let numericCharacters = CharacterSet(charactersIn: "0123456789")
        guard newString.rangeOfCharacter(from: numericCharacters.inverted) == nil,
              Int(newString) != nil else {
            return false
        }

        if textField == upTextField {
            justCalculateValue(UseStyle: 0, NweString: newString)
        } else if textField == downTextField {
            justCalculateValue(UseStyle: 1, NweString: newString)
        }
        
        if isEmpty {
            Dlog("isEmpty 1")
            if textField == upTextField {
                upTextField.text = "1"
                upTextField.selectAll(nil)
                return false
            } else if textField == downTextField {
                downTextField.text = "1"
                downTextField.selectAll(nil)
                return false
            }
        }

        /*
        // First check whether the replacement string's numeric...
        let cs = NSCharacterSet(charactersIn: "0123456789.").inverted
        let filtered = string.components(separatedBy: cs)
        let component = filtered.joined(separator: "")
        let isNumeric = string == component

        // Then if the replacement string's numeric, or if it's
        // a backspace, or if it's a decimal point and the text
        // field doesn't already contain a decimal point,
        // reformat the new complete number using
        if isNumeric {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 10
            // Combine the new text with the old; then remove any
            // commas from the textField before formatting
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let numberWithOutCommas = newString.replacingOccurrences(of: ",", with: "")
            let number = formatter.number(from: numberWithOutCommas)
            if number != nil {
                var formattedString = formatter.string(from: number!)
                // If the last entry was a decimal or a zero after a decimal,
                // re-add it here because the formatter will naturally remove
                // it.
                if string == "." && range.location == textField.text?.count {
                    formattedString = formattedString?.appending(".")
                }
                textField.text = formattedString
            } else {
                textField.text = nil
            }
        }
        return false
        */
        
        return true

    }
    
    /*
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if newString.contains(".") || newString.contains("-") {
            //let str = newString.replacingOccurrences(of: "..", with: ".")
            //textField.text = str
            return false
        }
        
        if textField==upTextField {
            if newString.count == 10 {
                return false
            }
            checkAndCalculateValue(UseStyle: 2, NweString: newString)
        } else if textField==downTextField {
            if newString.count == 10 {
                return false
            }
            checkAndCalculateValue(UseStyle: 3, NweString: newString)
        }
        
        return true
    }*/
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        //self.view.backgroundColor = //Color_Main_
        
        upTextLineV.isHidden = true
        downTextLineV.isHidden = true
        boxV.layer.borderWidth = 1
        boxV.layer.borderColor = UIColor.lightGray.cgColor
        
        leftBgV.layer.cornerRadius = leftBgV.frame.size.height/2
        leftBgV.layer.borderWidth = 1
        leftBgV.layer.borderColor = Color_Main_Red.cgColor
        leftPL.backgroundColor = .clear
        leftPL.layer.backgroundColor = Color_Main_Red.cgColor
        leftPL.layer.cornerRadius = leftPL.frame.size.height/2
        
        rightBgV.layer.cornerRadius = rightBgV.frame.size.height/2
        downChangeBtn.layer.borderWidth = 0.5
        downChangeBtn.layer.borderColor = UIColor.white.cgColor
        
        topbox_barbackV.layer.cornerRadius = topbox_barbackV.frame.size.height/2
        topbox_barbackV.layer.borderWidth = 1
        topbox_barbackV.layer.borderColor = Color_Main_LightGray.cgColor
        topbox_barV.layer.cornerRadius = topbox_barV.frame.size.height/2
        topbox_barV.layer.backgroundColor = Color_Main_Red.cgColor
        
        upTextField.keyboardType = .numberPad
        downTextField.keyboardType = .numberPad
        upTextField.delegate = self
        downTextField.delegate = self
        
        topbox_titleL.text = NSLocalizedString("Transfer Main Top Box Title", comment: "")
        upNameL.text = NSLocalizedString("Transfer Main Box Up Title", comment: "")
        downNameL.text = NSLocalizedString("Transfer Main Box Down Title", comment: "")
        kirimL.text = NSLocalizedString("Transfer Main Charge Title", comment: "")
        pointL.text = NSLocalizedString("Transfer Main Use Point Title", comment: "")
        totalNTDTitleL.text = NSLocalizedString("Transfer Main Total Money", comment: "")
        leftDownL.text = NSLocalizedString("Transfer Main Total Point Title", comment: "")
        leftDownL.adjustsFontSizeToFitWidth = true
        rightTitleL.text = NSLocalizedString("send", comment: "")
        headTitleL.text = NSLocalizedString("Transfer Head Title", comment: "")
        //--should--
        leftTotalPL.text = AppDelegate.shared().memberData["remit_point"]!
        
        promteShowL.textAlignment = .center
        promteShowL.text = NSLocalizedString("Promo Shoiw Capt", comment: "")
        promteShowL.backgroundColor = .clear
        promteShowL.layer.backgroundColor = Color_Main_Red.cgColor
        promteShowL.layer.cornerRadius = promteShowL.frame.size.height/2
        
        if AppDelegate.shared().discountForTransfer == "" {
            promteShowL.isHidden = true
        } else {
            promteShowL.isHidden = false
        }
        
        if AppDelegate.shared().discountForTransfer != "" {
            discountCodeValue = Int(AppDelegate.shared().discountForTransfer) ?? 0
            leftBgV.isUserInteractionEnabled = false
            leftBtn.isUserInteractionEnabled = false
            
        } else {
            discountCodeValue = 0
            leftBgV.isUserInteractionEnabled = true
            leftBtn.isUserInteractionEnabled = true
        }

        updateUsePointButtonAppearance()
        
        checkAndCalculateValue(UseStyle:0, NweString: "")
        
        moneyType.append("VND")
        moneyType.append("USD")
        downTypeL.text = moneyType[choseMoneyType]
        
        initTopBar()
        
        addPickerView()
        setupManualRefreshGesture()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            //這邊每次都要重新設定
            //setUpKursValue()
            //callMemberData()
            refreshTransferData()
            AppDelegate.shared().showTopButton()
            return
        }
        
        loadOnce = true
        //callMemberData()
        refreshTransferData()
        //頂部兩個按鈕
        AppDelegate.shared().topMargin = self.view.safeAreaInsets.top
        AppDelegate.shared().addTopButton()
        
        AppDelegate.shared().nowBottomMenuType = .transaction
        AppDelegate.shared().bottomMenu.paintMenu()
        
        /*
        if !AppDelegate.shared().hasProvinceData {
            getProvinceData(NeedNExt: false)
        }*/
        
    }
    
    private func setupManualRefreshGesture() {
        manualRefreshIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(manualRefreshIndicator)
        if #available(iOS 11.0, *) {
            manualRefreshIndicatorBaseOffset = 8
            manualRefreshIndicatorTopConstraint = manualRefreshIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: manualRefreshIndicatorBaseOffset)
        } else {
            manualRefreshIndicatorBaseOffset = 28
            manualRefreshIndicatorTopConstraint = manualRefreshIndicator.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: manualRefreshIndicatorBaseOffset)
        }
        NSLayoutConstraint.activate([
            manualRefreshIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            manualRefreshIndicatorTopConstraint!
        ])
        view.bringSubviewToFront(manualRefreshIndicator)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleFullScreenPan(_:)))
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(panGesture)
    }
    
    private func showIndicatorIfNeeded() {
        if manualRefreshIndicator.isHidden {
            manualRefreshIndicator.isHidden = false
        }
        if !manualRefreshIndicator.isAnimating {
            manualRefreshIndicator.startAnimating()
        }
    }
    
    private func updateIndicatorPosition(for pullDistance: CGFloat) {
        guard let topConstraint = manualRefreshIndicatorTopConstraint else { return }
        let effectiveDistance = min(pullDistance, manualRefreshTriggerDistance * 1.3)
        topConstraint.constant = manualRefreshIndicatorBaseOffset + effectiveDistance * 0.5
        UIView.performWithoutAnimation {
            self.view.layoutIfNeeded()
        }
    }
    
    private func resetIndicator(animated: Bool) {
        guard let topConstraint = manualRefreshIndicatorTopConstraint else { return }
        let animations = {
            topConstraint.constant = self.manualRefreshIndicatorBaseOffset
            self.view.layoutIfNeeded()
        }
        let completion = {
            self.manualRefreshIndicator.stopAnimating()
            self.manualRefreshIndicator.isHidden = true
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: animations) { _ in
                completion()
            }
        } else {
            animations()
            completion()
        }
    }
    
    private func snapIndicatorToBase() {
        guard let topConstraint = manualRefreshIndicatorTopConstraint else { return }
        topConstraint.constant = manualRefreshIndicatorBaseOffset
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func handleFullScreenPan(_ gesture: UIPanGestureRecognizer) {
        if isManualRefreshing {
            return
        }
        
        let translation = gesture.translation(in: view)
        let pullDistance = max(0, translation.y)
        
        switch gesture.state {
        case .began:
            currentPullDistance = 0
            if pullDistance == 0 {
                resetIndicator(animated: false)
            }
        case .changed:
            currentPullDistance = pullDistance
            if pullDistance > 0 {
                showIndicatorIfNeeded()
                updateIndicatorPosition(for: pullDistance)
            } else {
                resetIndicator(animated: false)
            }
        case .ended, .cancelled, .failed:
            gesture.setTranslation(.zero, in: view)
            if currentPullDistance >= manualRefreshTriggerDistance {
                beginManualRefresh()
            } else {
                resetIndicator(animated: true)
            }
            currentPullDistance = 0
        default:
            break
        }
    }
    
    private func beginManualRefresh() {
        guard !isManualRefreshing else { return }
        isManualRefreshing = true
        manualRefreshIndicator.isHidden = false
        manualRefreshIndicator.startAnimating()
        snapIndicatorToBase()
        refreshTransferData { [weak self] in
            guard let self = self else { return }
            self.isManualRefreshing = false
            self.resetIndicator(animated: true)
            let newValue = (Int(AppDelegate.shared().memberData["remit_point"]!) ?? 0) - decresedCharge
            leftTotalPL.text = "\(newValue)"
            //self.justCalculateValue(UseStyle: 0, NweString: "")
            checkAndCalculateValue(UseStyle: 0, NweString: "")
        }
    }
    
    private func refreshTransferData(completion: (() -> Void)? = nil) {
        setUpKursValue()
        let group = DispatchGroup()
        self.upTextField.text = "1"
        decresedCharge = 0
        updateUsePointButtonAppearance()
        group.enter()
        callMemberData {
            group.leave()
        }
        
        group.enter()
        getQuota {
            group.leave()
        }
        
        AppDelegate.shared().showTopButton()
        
        group.notify(queue: .main) {
            completion?()
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
