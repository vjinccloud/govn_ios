//
//  AddRecipientBankVC.swift
//
//  Created by mac on 2021/1/2.
//  Copyright © 2021 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class AddRecipientBankVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backL: UILabel!
    
    @IBOutlet weak var hideTextBtn: UIButton!
    @IBOutlet weak var codeBgV: UIView!
    @IBOutlet weak var bankCodeTextfield: UITextField!
    var canSelectForTransfer = false
    @IBOutlet weak var nextBtn: UIButton!
    var tempBankCode = ""
    @IBOutlet weak var selectBankNameL: UILabel!
    @IBOutlet weak var bankListTableView: UITableView!
    
    var topBarSelectIdx = 0
    @IBOutlet weak var topBarImg1: UIImageView!
    @IBOutlet weak var topBarL1: UILabel!
    @IBOutlet weak var topBarImg2: UIImageView!
    @IBOutlet weak var topBarL2: UILabel!
    @IBOutlet weak var topBarImg3: UIImageView!
    @IBOutlet weak var topBarL3: UILabel!
    
    var showBankList:[BankObj] = []
    var tempRecipientObj:RecipientObj =  RecipientObj()
    
    @IBOutlet weak var bankImg: UIImageView!
    
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showBankList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BankListTableViewCell", for: indexPath) as! BankListTableViewCell
        let cellData = showBankList[indexPath.row]
        let serchBankobj = UtilityTool().searchBankObj(BankName: cellData.bank_name!)
        
        let imgurl = serchBankobj.bank_photo!
        let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        cell.bankIconImgV.kf.setImage(with: urlhaed)
        cell.bankL.text = cellData.bank_name
        
        cell.backgroundColor = .white
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = showBankList[indexPath.row]
        bankCodeTextfield.text = cellData.bank_name
        //bankImg
        tempBankCode = cellData.bank_code
        bankCodeTextfield.resignFirstResponder()
        changeBankImg(BankName: cellData.bank_name!)
    }
    
    //MARK: - Utility
    func changeBankImg(BankName name:String) {
        let serchBankobj = UtilityTool().searchBankObj(BankName: name)
        let imgurl = serchBankobj.bank_photo!
        let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        bankImg.kf.setImage(with: urlhaed)
    }
    
    func checkBtnState() {
        if bankCodeTextfield.text! != "" {
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
        bankCodeTextfield.resignFirstResponder()
    }
    
    func reloadDataAndTable(Str str:String) {
        if str == "" {
            showBankList = AppDelegate.shared().bankList
        } else {
            showBankList = []
            
            for i in 0..<AppDelegate.shared().bankList.count {
                let obj = AppDelegate.shared().bankList[i]
                
                if obj.bank_name.lowercased().contains(str.lowercased()) {
                    showBankList.append(obj)
                }
            }
        }
        
        bankListTableView.reloadData()
    }
    
    //MARK: - Text Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeAll()
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideTextBtn.isHidden = false
        if textField == bankCodeTextfield {
            bankListTableView.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        hideTextBtn.isHidden = true
        bankListTableView.isHidden = true
        checkBtnState()
        changeBankImg(BankName: bankCodeTextfield.text!)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else{
            return true
        }
        
        let textLength = text.count + string.count - range.length
        if textLength>20 {
            return false
        }
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        reloadDataAndTable(Str: newString)
        checkBtnState()
        return true

    }
    
    //MARK: - API
    func addRecipient() {
        //找出 bank code
        let serchBankobj = UtilityTool().searchBankObj(BankName: bankCodeTextfield.text!)
        if serchBankobj.bank_code == "" {
            return
        }
        AppDelegate.shared().tempRecipientObj.bank_code = serchBankobj.bank_code!
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "recipient_type":AppDelegate.shared().tempRecipientObj.recipient_type[0], "recipient_name":AppDelegate.shared().tempRecipientObj.recipient_name!,"id_card_no":AppDelegate.shared().tempRecipientObj.id_card_no!,"phone_no":AppDelegate.shared().tempRecipientObj.phone_no!,"relationship":AppDelegate.shared().tempRecipientObj.relationship!,"province_id":AppDelegate.shared().tempRecipientObj.province_id!,"district_id":AppDelegate.shared().tempRecipientObj.district_id!,"address":AppDelegate.shared().tempRecipientObj.address!,"bank_code":AppDelegate.shared().tempRecipientObj.bank_code!]
        
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_UpdateAddRecipient;
        
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
                    
                    if self.canSelectForTransfer {
                        AppDelegate.shared().transactionObj.recipientObj = AppDelegate.shared().tempRecipientObj
                        
                        var storyboardId = "TransactionInfoConfirmVC"
                        if AppDelegate.shared().deviceSmall {
                            storyboardId = "TransactionInfoConfirmVCSmall"
                        }
                        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as? TransactionInfoConfirmVC
                        nextVC!.topBarSelectIdx = self.topBarSelectIdx
                        self.navigationController?.pushViewController(nextVC!, animated: true)
                    } else {
                        //回到列表
                        guard let viewControllers = self.navigationController?.viewControllers else {
                            return
                        }
                        for firstViewController in viewControllers {
                            if firstViewController is RecipientListVC {
                                self.navigationController?.popToViewController(firstViewController, animated: true)
                                return
                            }
                        }
                    }
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        addRecipient()
    }
    
    @IBAction func hideTextAction(_ sender: Any) {
        closeAll()
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
        bankCodeTextfield.returnKeyType = .done
        
        showBankList = AppDelegate.shared().bankList
        bankListTableView.separatorStyle = .none
        bankListTableView.delegate = self
        bankListTableView.dataSource = self
        bankListTableView.isHidden = true
        bankListTableView.backgroundColor = .white
        
        bankCodeTextfield.keyboardType = .default
        bankCodeTextfield.autocorrectionType = .no
        bankCodeTextfield.delegate = self
        
        bankCodeTextfield.autocapitalizationType = .allCharacters
        
        backL.text = ""
        
        bankCodeTextfield.becomeFirstResponder()
        bankCodeTextfield.placeholder = NSLocalizedString("Point Transfer Add Recipient Code PlaceHolder", comment: "")
        
        codeBgV.layer.cornerRadius = codeBgV.frame.size.height/2
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        nextBtn.backgroundColor = .clear
        nextBtn.layer.borderWidth = 0.5
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        nextBtn.isEnabled = false
        
        selectBankNameL.text = NSLocalizedString("Point Transfer Add Recipient Code Select", comment: "")
        
        hideTextBtn.isHidden = true
        topBarSelectIdx = AppDelegate.shared().transactionObj.recipient_type-1
        initTopBar()
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
