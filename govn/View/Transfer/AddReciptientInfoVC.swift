//
//  AddReciptientInfoVC.swift
//
//  Created by mac on 2020/12/29.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class AddReciptientInfoVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var topScrollView: UIScrollView!
    var keyboardAvoider: KeyboardAvoider!
    
    @IBOutlet weak var hideTextBtn: UIButton!
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var titleL1: UILabel!
    @IBOutlet weak var titleL2: UILabel!
    @IBOutlet weak var titleL3: UILabel!
    @IBOutlet weak var titleL4: UILabel!
    @IBOutlet weak var allV1: UIView!
    @IBOutlet weak var allV2: UIView!
    @IBOutlet weak var allV3: UIView!
    @IBOutlet weak var allV4: UIView!
    
    @IBOutlet weak var bgV1: UIView!
    @IBOutlet weak var bgV2: UIView!
    @IBOutlet weak var bgV3: UIView!
    @IBOutlet weak var bgV4: UIView!
    @IBOutlet weak var field1: UITextField!
    @IBOutlet weak var field2: UITextField!
    @IBOutlet weak var field3: UITextField!
    @IBOutlet weak var field4: UITextField!
    var canSelectForTransfer = false
    var canEditName = true
    @IBOutlet weak var nextBtn: UIButton!
    var tempBankCode = ""
    var canEdit = true
    
    var topBarSelectIdx = 0
    @IBOutlet weak var topBarImg1: UIImageView!
    @IBOutlet weak var topBarL1: UILabel!
    @IBOutlet weak var topBarImg2: UIImageView!
    @IBOutlet weak var topBarL2: UILabel!
    @IBOutlet weak var topBarImg3: UIImageView!
    @IBOutlet weak var topBarL3: UILabel!
    
    @IBOutlet weak var selectTable: UITableView!
    var showBankList:[BankObj] = []
    var tempSearchRecipientList:[RecipientObj] = []
    
    var choseRelationType = 0
    var choseTag = 0
    var pickerView:UIPickerView!
    var pickBackView:UIView!
    var relationTypeAry:[String] = []
    var relationEngTypeAry:[String] = []
    
    var loadOnce = false
    
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
    
    //MARK: - Tableview Delegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        view.backgroundColor = Color_Main_LightGray
        let label = UILabel.init(frame: CGRect.init(x: 15, y: 0, width: tableView.frame.size.width-30, height: 30))
        label.text = NSLocalizedString("Do you mean this person", comment: "")
        label.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempSearchRecipientList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectRecitientNameTableViewCell", for: indexPath) as! SelectRecitientNameTableViewCell
        let cellData = tempSearchRecipientList[indexPath.row]
        cell.backgroundColor = Color_Main_LightGray
        cell.contentView.backgroundColor = Color_Main_LightGray
        cell.nameL.text = cellData.recipient_name
        cell.idL.text = "ID:\(cellData.id_card_no ?? "")"
        cell.phoneL.text = cellData.phone_no
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = tempSearchRecipientList[indexPath.row]
        Dlog("cellData = \(cellData.description)")
        canEdit = false
        field1.text = cellData.recipient_name
        field2.text = cellData.id_card_no
        field3.text = cellData.phone_no
        
        AppDelegate.shared().tempRecipientObj.province_id = cellData.province_id
        AppDelegate.shared().tempRecipientObj.district_id = cellData.district_id
        AppDelegate.shared().tempRecipientObj.address = cellData.address
        
        //比對關係
        let ori = cellData.relationship
        for i in 0..<relationTypeAry.count {
            let str = relationTypeAry[i].lowercased()
            if ori == str {
                choseRelationType = i
                field4.text = relationTypeAry[i]
                break
            }
        }
        
        hideTextAction(hideTextBtn!)
        
        field1.isEnabled = false
        field2.isEnabled = false
        field1.resignFirstResponder()
        
        field1.isUserInteractionEnabled = false
        field2.isUserInteractionEnabled = false
        
    }
    
    //MARK: - Utility
    func checkSearchAction() {
        if tempSearchRecipientList.count==0 {
            selectTable.isHidden = true
        } else {
            selectTable.isHidden = false
            selectTable.reloadData()
        }
    }
    
    func checkBtnState() {
        if field1.text! != "", field2.text! != "", field3.text! != "", field4.text! != "" {
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
        field4.resignFirstResponder()
    }
    
    //MARK: - UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return relationTypeAry.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return relationTypeAry[row]
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
        field4.resignFirstResponder()
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
        
        choseRelationType = select
        field4.text = relationTypeAry[choseRelationType]
        
        checkBtnState()
    }
    
    //MARK: - Text Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeAll()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideTextBtn.isHidden = false
        //需求 7：被鍵盤蓋住才小幅捲動，不再捲到頂；收鍵盤也不捲回頂端
        keyboardAvoider.fieldDidBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        hideTextBtn.isHidden = true
        if textField == field1 {
            selectTable.isHidden = true
            if !checkLeagleCharacter() {
                showNameAlert()
                return
            }
        }
        checkBtnState()
    }
    
    func showNameAlert() {
        if AppDelegate.shared().alertViewContainer != nil {
            return
        }
        AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("No illeagal Words in name", comment: ""))
    }
    
    func checkLeagleCharacter() -> Bool {
        var pass = true
        let words = field1.text
        let pred = NSPredicate(format:"SELF MATCHES %@", "[A-Za-z0-9 _,./-]+")
        pass = pred.evaluate(with: words)
        
        if field1.text?.count==0 {
            pass = true
        }
        
        return pass
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        guard let text = textField.text else{
            return true
        }
        
        let textLength = text.count + string.count - range.length
        if textLength>20 {
            return false
        }
        
        if textField == field1 {
            /*
            var pass = true
            let words = newString
            let pred = NSPredicate(format:"SELF MATCHES %@", "[A-Za-z0-9 ]+")
            pass = pred.evaluate(with: words)
            
            if let char = string.cString(using: String.Encoding.utf8) {
                    let isBackSpace = strcmp(char, "\\b")
                    if (isBackSpace == -92) {
                        print("Backspace was pressed")
                        pass = true
                    }
            }
            
            if !pass {
                showNameAlert()
                return false
            }
            
            if newString != "" {
                searchRecipient(Text: newString)
            }
            */
        } else if textField == field2 {
            
            var pass = true
            let words = newString
            let pred = NSPredicate(format:"SELF MATCHES %@", "[0-9]+")
            pass = pred.evaluate(with: words)
            
            if let char = string.cString(using: String.Encoding.utf8) {
                    let isBackSpace = strcmp(char, "\\b")
                    if (isBackSpace == -92) {
                        print("Backspace was pressed")
                        pass = true
                    }
            }
            
            if !pass {
                return false
            }
            
            let text = field2.text
            let textLength = text!.count + string.count - range.length
            return textLength <= 12
        } else if textField == field3 {
            
            var pass = true
            let words = newString
            let pred = NSPredicate(format:"SELF MATCHES %@", "[0-9]+")
            pass = pred.evaluate(with: words)
            
            if let char = string.cString(using: String.Encoding.utf8) {
                    let isBackSpace = strcmp(char, "\\b")
                    if (isBackSpace == -92) {
                        print("Backspace was pressed")
                        pass = true
                    }
            }
            
            if !pass {
                return false
            }
            
            let text = field3.text
            let textLength = text!.count + string.count - range.length
            return textLength <= 10
        }
        
        checkBtnState()
        return true

    }
    
    //MARK: - API
    func searchRecipient(Text txt:String) {
        var paymentAry:[String] = []
        paymentAry.append(txt)
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "recipient_name":paymentAry]
        let headers: HTTPHeaders = [:]

        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_Search_recipient;
        
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
                    //--should-- 須先有第一個才能寫後續規則
                    self.tempSearchRecipientList = []
                    self.tempSearchRecipientList.append(contentsOf: AppDelegate.shared().tempSearchRecipientList)
                    self.checkSearchAction()
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
        
    }
    
    func addRecipientStep2() {
        AppDelegate.shared().tempRecipientObj.recipient_name = field1.text
        AppDelegate.shared().tempRecipientObj.id_card_no = field2.text
        AppDelegate.shared().tempRecipientObj.phone_no = field3.text
        AppDelegate.shared().tempRecipientObj.relationship = relationEngTypeAry[choseRelationType].lowercased()
        
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "AddReciptientAddressVC") as? AddReciptientAddressVC
        nextVC!.canSelectForTransfer = canSelectForTransfer
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
        
        //找出 bank code
        /*
        let serchBankobj = UtilityTool().searchBankObj(BankName: bankCodeTextfield.text!)
        if serchBankobj.bank_code == "" {
            return
        }
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "bank_code":serchBankobj.bank_code!, "bank_acc":accountTextfield.text!]
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_AddRecipient;
        
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
                    self.tempRecipientObj.bank_acc = self.accountTextfield.text!
                    self.tempRecipientObj.bank_code = serchBankobj.bank_code!
                    self.tempRecipientObj.recipient_id = AppDelegate.shared().tempRecipientObj.recipient_id
                    self.tempRecipientObj.recipient_name = AppDelegate.shared().tempRecipientObj.recipient_name
                    
                    if self.canSelectForTransfer {
                        AppDelegate.shared().transactionObj.recipientObj = self.tempRecipientObj
                        
                        //先選匯款目的，再進交易確認頁（compliance-202610）
                        self.showTransferPurposeThenConfirm()
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }*/
    }
    
    //MARK: - Button-Action
    @IBAction func hideTextAction(_ sender: Any) {
        field1.delegate = self
        field2.delegate = self
        field3.delegate = self
        field4.delegate = self
        closeAll()
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if !checkLeagleCharacter() {
            showNameAlert()
            return
        }
        /*
        //地址只能填英數字
        var pass = true
        let words = field1.text
        let pred = NSPredicate(format:"SELF MATCHES %@", "[A-Za-z0-9 ]+")
        pass = pred.evaluate(with: words)
        
        if !pass {
            AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("Register Error Name", comment: ""))
            return
        }*/
        
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
        //self.setupHideKeyboardOnTap()
        //bankCodeTextfield.inputAccessoryView = generateToolBar()
        //accountTextfield.inputAccessoryView = generateToolBar()
        
        relationTypeAry = []
        relationTypeAry.append(NSLocalizedString("Relation Type 1", comment: ""))
        relationTypeAry.append(NSLocalizedString("Relation Type 2", comment: ""))
        relationTypeAry.append(NSLocalizedString("Relation Type 3", comment: ""))
        relationTypeAry.append(NSLocalizedString("Relation Type 4", comment: ""))
        
        relationEngTypeAry = []
        relationEngTypeAry.append("FAMILY")
        relationEngTypeAry.append("FRIEND")
        relationEngTypeAry.append("SELF")
        relationEngTypeAry.append("OTHERS")
        
        field1.keyboardType = .default
        field1.autocorrectionType = .no
        field2.keyboardType = .numberPad
        field3.keyboardType = .numberPad
        field4.keyboardType = .default
        
        field1.delegate = self
        field2.delegate = self
        field3.delegate = self
        field4.delegate = self
        keyboardAvoider = KeyboardAvoider(scrollView: topScrollView, hostView: view) { [weak self] field in
            guard let self = self else { return field }
            if field == self.field1 { return self.allV1 }
            if field == self.field2 { return self.allV2 }
            if field == self.field3 { return self.allV3 }
            if field == self.field4 { return self.allV4 }
            return field
        }
        
        selectTable.backgroundColor = .clear
        selectTable.separatorStyle = .none
        
        let tempWindow = UIApplication.shared.keyWindow
        pickBackView = UIView(frame: CGRect(x: 0, y: (tempWindow?.frame.height)!, width: view.frame.width, height: 260))
        
        // Toolbar
        let btnDone = UIBarButtonItem(title: " Xác nhận ", style: .plain, target: self, action: #selector(finishSelect))
        //UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finishSelect))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: " Huỷ ", style: .plain, target: self, action: #selector(closePicker))
        
        let barAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: pickBackView.frame.width, height: 44))
        barAccessory.barStyle = .default
        barAccessory.isTranslucent = false
        barAccessory.items = [cancelButton, spaceButton, btnDone]
        pickerView = UIPickerView(frame: CGRect(x: 0, y: barAccessory.frame.height, width: view.frame.width, height: pickBackView.frame.height-barAccessory.frame.height))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
        field4.inputView = pickerView
        field4.inputAccessoryView = barAccessory
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
        
        bgV4.layer.cornerRadius = bgV4.frame.size.height/2
        bgV4.layer.backgroundColor = UIColor.clear.cgColor
        bgV4.layer.borderWidth = 0.5
        bgV4.layer.borderColor = UIColor.white.cgColor
        
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        nextBtn.backgroundColor = .clear
        nextBtn.layer.borderWidth = 0.5
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        nextBtn.isEnabled = false
        
        titleL1.text = NSLocalizedString("Input Bank Person Info Field1", comment: "")
        titleL2.text = NSLocalizedString("Input Bank Person Info Field2", comment: "")
        titleL3.text = NSLocalizedString("Input Bank Person Info Field3", comment: "")
        titleL4.text = NSLocalizedString("Input Bank Person Info Field4", comment: "")
        
        field1.autocorrectionType = .no
        
        topBarSelectIdx = AppDelegate.shared().transactionObj.recipient_type-1
        selectTable.isHidden = true
        initTopBar()
        hideTextBtn.isHidden = true
        let nib = UINib(nibName: "SelectRecitientNameTableViewCell", bundle: nil)
        selectTable.register(nib, forCellReuseIdentifier: "SelectRecitientNameTableViewCell")
        selectTable.delegate = self
        selectTable.dataSource = self
        
        if AppDelegate.shared().tempTransferChoseMode {
            field1.isUserInteractionEnabled = false
            field2.isUserInteractionEnabled = false
            
            field1.text = AppDelegate.shared().tempRecipientObj.recipient_name
            field2.text = AppDelegate.shared().tempRecipientObj.id_card_no
            field3.text = AppDelegate.shared().tempRecipientObj.phone_no
            
            choseRelationType = 0
            //比對關係
            let ori = AppDelegate.shared().tempRecipientObj.relationship
            for i in 0..<relationEngTypeAry.count {
                let str = relationEngTypeAry[i].lowercased()
                if ori == str {
                    choseRelationType = i
                    break
                }
            }
            field4.text = relationTypeAry[choseRelationType]
            checkBtnState()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            return
        }
        
        loadOnce = true
        
        field1.text = AppDelegate.shared().tempRecipientObj.recipient_name
        field1.isEnabled = canEditName
        
        if field1.text == "" {
            field1.isUserInteractionEnabled = true
            field1.isEnabled = true
        }
        
        if field2.text == "" {
            field2.isUserInteractionEnabled = true
            field2.isEnabled = true
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
