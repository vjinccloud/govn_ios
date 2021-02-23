//
//  AddReciptientAddressVC.swift
//  govn
//
//  Created by mac on 2021/1/2.
//  Copyright © 2021 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class AddReciptientAddressVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var topScrollView: UIScrollView!
    
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var titleL1: UILabel!
    @IBOutlet weak var titleL2: UILabel!
    @IBOutlet weak var titleL3: UILabel!
    @IBOutlet weak var allV1: UIView!
    @IBOutlet weak var allV2: UIView!
    @IBOutlet weak var allV3: UIView!
    
    @IBOutlet weak var bgV1: UIView!
    @IBOutlet weak var bgV2: UIView!
    @IBOutlet weak var bgV3: UIView!
    @IBOutlet weak var field1: UITextField!
    @IBOutlet weak var field2: UITextField!
    @IBOutlet weak var field3: UITextField!
    var canSelectForTransfer = false
    @IBOutlet weak var nextBtn: UIButton!
    var tempBankCode = ""
    
    var topBarSelectIdx = 0
    @IBOutlet weak var topBarImg1: UIImageView!
    @IBOutlet weak var topBarL1: UILabel!
    @IBOutlet weak var topBarImg2: UIImageView!
    @IBOutlet weak var topBarL2: UILabel!
    @IBOutlet weak var topBarImg3: UIImageView!
    @IBOutlet weak var topBarL3: UILabel!
    
    var showBankList:[BankObj] = []
    var tempRecipientObj:RecipientObj =  RecipientObj()
    
    var choseProvinceIdx = 0
    var choseDistrictIdx = 0
    var choseTag = 0
    var pickerView:UIPickerView!
    var pickBackView:UIView!
    var relationTypeAry:[String] = []
    
    //MARK: - TopBar
    func initTopBar() {
        var imag1Str = "bank_account"
        var imag2Str = "cash_pick_up"
        var imag3Str = "doortodoor"
        
        var colorL1 = UIColor.darkGray
        var colorL2 = UIColor.darkGray
        var colorL3 = UIColor.darkGray
        
        if topBarSelectIdx == 0 {
            imag1Str = "bank_account_select"
            colorL1 = UIColor.white
        } else if topBarSelectIdx == 1 {
            imag2Str = "cash_pick_up_select"
            colorL2 = UIColor.white
        } else if topBarSelectIdx == 2 {
            imag3Str = "doortodoor_select"
            colorL3 = UIColor.white
        }
        
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
    
    @IBAction func topBarBtn1Action(_ sender: Any) {
       
    }
    
    @IBAction func topBarBtn2Action(_ sender: Any) {
        
    }
    
    @IBAction func topBarBtn3Action(_ sender: Any) {
        
    }
    
    //MARK: - Utility
    func checkBtnState() {
        if field1.text! != "", field2.text! != "", field3.text! != "" {
            nextBtn.isEnabled = true
            nextBtn.backgroundColor = Color_Main_Red
        } else {
            nextBtn.isEnabled = false
            nextBtn.backgroundColor = .clear
        }
    }
    
    func closeAll() {
        closeText()
    }
    
    func closeText() {
        field1.resignFirstResponder()
        field2.resignFirstResponder()
        field3.resignFirstResponder()
    }
    
    //MARK: - UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if choseTag==0 {
            return AppDelegate.shared().provinceData.count
        } else {
            return AppDelegate.shared().provinceData[choseProvinceIdx].allZone.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if choseTag==0 {
            return AppDelegate.shared().provinceData[row].province_name
        } else {
            return AppDelegate.shared().provinceData[choseProvinceIdx].allZone[row].district_name
        }
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
        field1.resignFirstResponder()
        field2.resignFirstResponder()
        /*
        let tempWindow = UIApplication.shared.keyWindow
        self.pickBackView.center.y = (tempWindow?.frame.size.height)!-270/2
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pickBackView.center.y = (tempWindow?.frame.size.height)!+270/2
            }, completion: { _ in
                self.pickBackView.isHidden = true
        })*/
    }
    
    @objc func finishSelect() {
        closePicker()
        let select = self.pickerView.selectedRow(inComponent: 0)
        
        if choseTag==0 {
            choseProvinceIdx = select
            field1.text = AppDelegate.shared().provinceData[choseProvinceIdx].province_name
            choseDistrictIdx = 0
            field2.text = AppDelegate.shared().provinceData[choseProvinceIdx].allZone[choseDistrictIdx].district_name
            
        } else {
            choseDistrictIdx = select
            field2.text = AppDelegate.shared().provinceData[choseProvinceIdx].allZone[choseDistrictIdx].district_name
        }
        checkBtnState()
    }
    
    //MARK: - Text Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeAll()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == field1 {
            choseTag = 0
            pickerView.reloadAllComponents()
            //topScrollView.contentOffset = CGPoint.init(x: 0, y: allV1.frame.origin.y)
        } else if textField == field2 {
            choseTag = 1
            pickerView.reloadAllComponents()
            topScrollView.contentOffset = CGPoint.init(x: 0, y: allV2.frame.origin.y)
        } else if textField == field3 {
            topScrollView.contentOffset = CGPoint.init(x: 0, y: allV3.frame.origin.y)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        topScrollView.contentOffset = CGPoint.init(x: 0, y: 0)
        
        checkBtnState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if textField == field1 {
            searchRecipient(Text: newString)
        }
        
        checkBtnState()
        return true

    }
    
    //MARK: - API
    func searchRecipient(Text txt:String) {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "recipient_name":txt]
        let headers: HTTPHeaders = [:]
 
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_Search_recipient;
        
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
                    //--should-- 須先有第一個才能寫後續規則
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
        
    }
    
    func addRecipientStep2() {
        AppDelegate.shared().tempRecipientObj.recipient_type = []
        AppDelegate.shared().tempRecipientObj.recipient_type.append(AppDelegate.shared().transactionObj.recipient_type)
        AppDelegate.shared().tempRecipientObj.province_id = AppDelegate.shared().provinceData[choseProvinceIdx].province_id
        AppDelegate.shared().tempRecipientObj.district_id = AppDelegate.shared().provinceData[choseProvinceIdx].allZone[choseDistrictIdx].district_id
        AppDelegate.shared().tempRecipientObj.address = field3.text
        
        if AppDelegate.shared().transactionObj.recipient_type == 2, AppDelegate.shared().tempTransferChoseMode {
            //CP最後要多選銀行
            let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "AddRecipientBankVC") as? AddRecipientBankVC
            nextVC!.canSelectForTransfer = self.canSelectForTransfer
            self.navigationController?.pushViewController(nextVC!, animated: true)
            return
        }
        
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "recipient_type":AppDelegate.shared().tempRecipientObj.recipient_type[0], "recipient_name":AppDelegate.shared().tempRecipientObj.recipient_name!,"id_card_no":AppDelegate.shared().tempRecipientObj.id_card_no!,"phone_no":AppDelegate.shared().tempRecipientObj.phone_no!,"relationship":AppDelegate.shared().tempRecipientObj.relationship!,"province_id":AppDelegate.shared().tempRecipientObj.province_id!,"district_id":AppDelegate.shared().tempRecipientObj.district_id!,"address":AppDelegate.shared().tempRecipientObj.address!]
        if AppDelegate.shared().transactionObj.recipient_type == 1 {
            parameters["bank_code"] = AppDelegate.shared().tempRecipientObj.bank_code
            parameters["bank_acc"] = AppDelegate.shared().tempRecipientObj.bank_acc
        }
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_UpdateAddRecipient;
        
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
                    
                    if self.canSelectForTransfer {
                        AppDelegate.shared().transactionObj.recipientObj = AppDelegate.shared().tempRecipientObj
                        
                        var storyboardId = "TransactionInfoConfirmVC"
                        if AppDelegate.shared().deviceSmall {
                            storyboardId = "TransactionInfoConfirmVCSmall"
                        }
                        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as? TransactionInfoConfirmVC
                        self.navigationController?.pushViewController(nextVC!, animated: true)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        addRecipientStep2()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func generateToolBar() ->UIToolbar {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        
        let toolBar:UIToolbar = UIToolbar()
        toolBar.items = [flexibleSpace,done]
        toolBar.sizeToFit()
        
        return toolBar
    }
    
    @objc func doneAction() {
        closeText()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        //bankCodeTextfield.inputAccessoryView = generateToolBar()
        //accountTextfield.inputAccessoryView = generateToolBar()
        
        relationTypeAry = []
        relationTypeAry.append("FAMILY")
        relationTypeAry.append("FRIEND")
        relationTypeAry.append("SELF")
        relationTypeAry.append("OTHERS")
        
        field1.keyboardType = .default
        field2.keyboardType = .asciiCapable
        field3.keyboardType = .default
        
        field1.delegate = self
        field2.delegate = self
        field3.delegate = self
        
        let tempWindow = UIApplication.shared.keyWindow
        pickBackView = UIView(frame: CGRect(x: 0, y: (tempWindow?.frame.height)!, width: view.frame.width, height: 260))
        
        // Toolbar
        let btnDone = UIBarButtonItem(title: "  確定  ", style: .plain, target: self, action: #selector(finishSelect))
        //UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finishSelect))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "  取消  ", style: .plain, target: self, action: #selector(closePicker))
        
        let barAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: pickBackView.frame.width, height: 44))
        barAccessory.barStyle = .default
        barAccessory.isTranslucent = false
        barAccessory.items = [cancelButton, spaceButton, btnDone]
        pickerView = UIPickerView(frame: CGRect(x: 0, y: barAccessory.frame.height, width: view.frame.width, height: pickBackView.frame.height-barAccessory.frame.height))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
        field1.inputView = pickerView
        field1.inputAccessoryView = barAccessory
        
        field2.inputView = pickerView
        field2.inputAccessoryView = barAccessory
        
        backL.text = ""
        
        bgV1.layer.cornerRadius = bgV1.frame.size.height/2
        bgV1.layer.backgroundColor = UIColor.clear.cgColor
        bgV1.layer.borderWidth = 0.5
        bgV1.layer.borderColor = UIColor.white.cgColor
        
        bgV2.layer.cornerRadius = bgV2.frame.size.height/2
        bgV2.layer.backgroundColor = UIColor.clear.cgColor
        bgV2.layer.borderWidth = 0.5
        bgV2.layer.borderColor = UIColor.white.cgColor
        
        bgV3.layer.cornerRadius = bgV3.frame.size.height/2
        bgV3.layer.backgroundColor = UIColor.clear.cgColor
        bgV3.layer.borderWidth = 0.5
        bgV3.layer.borderColor = UIColor.white.cgColor
        
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        nextBtn.backgroundColor = .clear
        nextBtn.layer.borderWidth = 0.5
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        nextBtn.isEnabled = false
        
        titleL1.text = NSLocalizedString("Input Bank Person Address Field1", comment: "")
        titleL2.text = NSLocalizedString("Input Bank Person Address Field2", comment: "")
        titleL3.text = NSLocalizedString("Input Bank Person Address Field3", comment: "")
        
        topBarSelectIdx = AppDelegate.shared().transactionObj.recipient_type-1
        initTopBar()
        
        if AppDelegate.shared().tempTransferChoseMode {
            
            field3.text = AppDelegate.shared().tempRecipientObj.address
            
            //比對省份
            var ori = AppDelegate.shared().tempRecipientObj.province_id
            for i in 0..<AppDelegate.shared().provinceData.count {
                let str = AppDelegate.shared().provinceData[i].province_id
                if ori == str {
                    choseProvinceIdx = i
                    field1.text = AppDelegate.shared().provinceData[i].province_name
                    break
                }
            }
            
            ori = AppDelegate.shared().tempRecipientObj.district_id
            for i in 0..<AppDelegate.shared().provinceData[choseProvinceIdx].allZone.count {
                let str = AppDelegate.shared().provinceData[choseProvinceIdx].allZone[i].district_id
                if ori == str {
                    choseDistrictIdx = i
                    field2.text = AppDelegate.shared().provinceData[choseProvinceIdx].allZone[i].district_name
                    break
                }
            }
            checkBtnState()
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
