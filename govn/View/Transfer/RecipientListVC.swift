//
//  RecipientListVC.swift
//  indogo
//
//  Created by mac on 2020/8/28.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class RecipientListVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBgV: UIView!
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var myTable: UITableView!
    
    var topBarSelectIdx = 0
    @IBOutlet weak var topBarImg1: UIImageView!
    @IBOutlet weak var topBarL1: UILabel!
    @IBOutlet weak var topBarImg2: UIImageView!
    @IBOutlet weak var topBarL2: UILabel!
    @IBOutlet weak var topBarImg3: UIImageView!
    @IBOutlet weak var topBarL3: UILabel!
    
    var canSelectForTransfer = false
    var showDataList:[RecipientObj] = []
    //因為怕會重複一直進入而產生無法返回的迴圈
    var hasGotoAddRecipient = false
    
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
        //觀看模式才能轉
        if !canSelectForTransfer {
            topBarSelectIdx = 0
            AppDelegate.shared().transactionObj.recipient_type = 1
            getRecipents()
            initTopBar()
        }
    }
    
    @IBAction func topBarBtn2Action(_ sender: Any) {
        //觀看模式才能轉
        if !canSelectForTransfer {
            topBarSelectIdx = 1
            AppDelegate.shared().transactionObj.recipient_type = 2
            getRecipents()
            initTopBar()
        }
    }
    
    @IBAction func topBarBtn3Action(_ sender: Any) {
        //觀看模式才能轉
        if !canSelectForTransfer {
            topBarSelectIdx = 2
            AppDelegate.shared().transactionObj.recipient_type = 3
            getRecipents()
            initTopBar()
        }
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return showDataList.count
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if AppDelegate.shared().transactionObj.recipient_type == 1 {
            return 72
        } else {
            return 120
        }
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if AppDelegate.shared().transactionObj.recipient_type == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipientTableViewCell", for: indexPath) as! RecipientTableViewCell
            let cellData = showDataList[indexPath.row]
            let serchBankobj = UtilityTool().searchBankObj(BankName: cellData.bank_name!)
            
            let imgurl = serchBankobj.bank_photo!
            let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            cell.logoImgV.kf.setImage(with: urlhaed)
            
            cell.nameL.text = cellData.recipient_name
            cell.bankL.text = cellData.bank_acc
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectRecitientType2and3TableViewCell", for: indexPath) as! SelectRecitientType2and3TableViewCell
            let cellData = showDataList[indexPath.row]
            
            cell.nameTL.text = NSLocalizedString("Person List Chose Field1", comment: "")
            cell.idTL.text = NSLocalizedString("Person List Chose Field2", comment: "")
            cell.phoneTL.text = NSLocalizedString("Person List Chose Field3", comment: "")
            cell.adrTL.text = NSLocalizedString("Person List Chose Field4", comment: "")
            
            cell.nameL.text = cellData.recipient_name
            cell.idL.text = cellData.id_card_no + " "
            cell.phoneL.text = cellData.phone_no + " "
            cell.adrL.text = cellData.address + " "
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        }
        
     }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            hideRecipient(Recipient: showDataList[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !canSelectForTransfer {
            //return
        }
        
        AppDelegate.shared().transactionObj.recipientObj = showDataList[indexPath.row]
        
        if AppDelegate.shared().transactionObj.recipient_type == 1, canSelectForTransfer {
            Dlog("AppDelegate.shared().transactionObj.recipientObj.printSelf")
            AppDelegate.shared().transactionObj.recipientObj.printSelf()
            let cell = tableView.cellForRow(at: indexPath) as! RecipientTableViewCell
            cell.checkImgV.image = UIImage.init(named: "choosen_checklist")
            
            var storyboardId = "TransactionInfoConfirmVC"
            if AppDelegate.shared().deviceSmall {
                storyboardId = "TransactionInfoConfirmVCSmall"
            }
            let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as? TransactionInfoConfirmVC
            nextVC!.topBarSelectIdx = topBarSelectIdx
            self.navigationController?.pushViewController(nextVC!, animated: true)
            
        } else {
            
            AppDelegate.shared().tempRecipientObj = showDataList[indexPath.row]
            AppDelegate.shared().tempTransferChoseMode = true
            
            AppDelegate.shared().tempRecipientObj.printSelf()
            
            if AppDelegate.shared().transactionObj.recipient_type == 1 {
                let cell = tableView.cellForRow(at: indexPath) as! RecipientTableViewCell
                cell.checkImgV.image = UIImage.init(named: "choosen_checklist")
                
                //bank_code要用找的
                let serchBankobj = UtilityTool().searchBankObj(BankName: AppDelegate.shared().tempRecipientObj.bank_name)
                if serchBankobj.bank_code == "" {
                    return
                }
                AppDelegate.shared().tempRecipientObj.bank_code = serchBankobj.bank_code!
            
            } else {
                let cell = tableView.cellForRow(at: indexPath) as! SelectRecitientType2and3TableViewCell
                cell.choseImgV.image = UIImage.init(named: "choosen_checklist")
            }
            
            //先找出詳細資料
            //searchRecipient()
            
            //直接到填受款人
            let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "AddReciptientInfoVC") as? AddReciptientInfoVC
            nextVC!.canSelectForTransfer = self.canSelectForTransfer
            self.navigationController?.pushViewController(nextVC!, animated: true)
        }
        
    }
    
    //MARK: - API
    /*
    func searchRecipient() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "recipient_name":AppDelegate.shared().transactionObj.recipientObj.recipient_name!]
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
                    if AppDelegate.shared().tempSearchRecipientList.count > 0 {
                        AppDelegate.shared().tempRecipientObj = AppDelegate.shared().tempSearchRecipientList[0]
                        AppDelegate.shared().tempTransferChoseMode = true
                        //直接到填受款人
                        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "AddReciptientInfoVC") as? AddReciptientInfoVC
                        nextVC!.canSelectForTransfer = self.canSelectForTransfer
                        self.navigationController?.pushViewController(nextVC!, animated: true)
                    }
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
        
    }
    */
    
    
    func searchRecipient() {
        var paymentAry:[String] = []
        
        for i in 0..<AppDelegate.shared().recipientShownListObjs.count {
            let obj = AppDelegate.shared().recipientShownListObjs[i]
            paymentAry.append(obj.recipient_name)
        }
        
        if paymentAry.count == 0 {
            self.reloadDataAndTable(Str: self.searchTextfield.text!)
            return
        }
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "recipient_name":paymentAry]
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
                    for i in 0..<AppDelegate.shared().recipientShownListObjs.count {
                        let oriname = AppDelegate.shared().recipientShownListObjs[i].recipient_name.lowercased()
                        for j in 0..<AppDelegate.shared().tempSearchRecipientList.count {
                            let objname = AppDelegate.shared().tempSearchRecipientList[j].recipient_name.lowercased()
                            if oriname == objname {
                                AppDelegate.shared().recipientShownListObjs[i].getIdenticalFromObjExceptHidden(Obj:AppDelegate.shared().tempSearchRecipientList[j], AddBank:false)
                                Dlog("identical at \(i) to \(j)")
                                break
                            }
                            
                        }
                    }
                    self.reloadDataAndTable(Str: self.searchTextfield.text!)
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
        
    }
    public func hideRecipient(Recipient obj:RecipientObj) {
        let serchBankobj = UtilityTool().searchBankObj(BankName: obj.bank_name!)
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "bank_code":serchBankobj.bank_code!, "bank_acc":obj.bank_acc!, "recipient_type":topBarSelectIdx+1]
        if topBarSelectIdx != 0 {
            parameters = ["token":AppDelegate.shared().sessionToken, "id_card_no":obj.id_card_no!, "recipient_type":topBarSelectIdx+1]
        }
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_MemberHideRecipent;
        
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
                    self.getRecipents()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func getRecipents() {
        var parameters:Parameters = [:]
        if canSelectForTransfer {
            parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":AppDelegate.shared().transactionObj.totalNtdValue, "use_remit_point":1]
        } else {
            parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":0, "use_remit_point":0]
        }
        
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_MemberRecipents;
        
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
                
                AppDelegate.shared().recipientListObjs = []
                AppDelegate.shared().recipientShownListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    
                    //self.reloadDataAndTable(Str: self.searchTextfield.text!)
                    if AppDelegate.shared().recipientShownListObjs.count == 0, self.hasGotoAddRecipient == false {
                        self.hasGotoAddRecipient = true
                        self.goAddRecipient()
                    } else {
                        //再去取得所有的細節
                        self.searchRecipient()
                    }
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func goAddRecipient() {
        AppDelegate.shared().tempRecipientObj = RecipientObj()
        AppDelegate.shared().tempRecipientObj.recipient_type.append(AppDelegate.shared().transactionObj.recipient_type)
        
        //如果是 To Bank Account
        if AppDelegate.shared().transactionObj.recipient_type == 1 {
            let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "AddRecipientVC") as? AddRecipientVC
            nextVC!.canSelectForTransfer = canSelectForTransfer
            self.navigationController?.pushViewController(nextVC!, animated: true)
        } else {
            //直接到填受款人
            let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "AddReciptientInfoVC") as? AddReciptientInfoVC
            nextVC!.canSelectForTransfer = canSelectForTransfer
            self.navigationController?.pushViewController(nextVC!, animated: true)
        }
        
    }
    
    //MARK: - Button-Action
    @IBAction func addRecipientAction(_ sender: Any) {
        AppDelegate.shared().tempTransferChoseMode = false
        goAddRecipient()
    }
    
    @IBAction func searchAction(_ sender: Any) {
        closeAll()
        reloadDataAndTable(Str: searchTextfield.text!)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Text Delegate
    func closeAll() {
        closeText()
    }
    
    func closeText() {
        searchTextfield.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeAll()
        reloadDataAndTable(Str: textField.text!)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        reloadDataAndTable(Str: newString)
        return true

    }
    
    //MARK: - Utility
    func reloadDataAndTable(Str str:String) {
        //根據search字串過濾
        showDataList = []
        if str == "" {
            showDataList = AppDelegate.shared().recipientShownListObjs
        } else {
            let searchStr = str.lowercased()
            for i in 0..<AppDelegate.shared().recipientShownListObjs.count {
                let obj = AppDelegate.shared().recipientShownListObjs[i]
                if obj.recipient_name.lowercased().contains(searchStr) || obj.bank_acc.lowercased().contains(searchStr) || obj.bank_name.lowercased().contains(searchStr) {
                    showDataList.append(obj)
                }
            }
        }
        
        self.myTable.delegate = self
        self.myTable.dataSource = self
        self.myTable.reloadData()
        
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        topBarSelectIdx = AppDelegate.shared().transactionObj.recipient_type-1
        initTopBar()
        
        backL.text = ""
        let nib = UINib(nibName: "RecipientTableViewCell", bundle: nil)
        myTable.register(nib, forCellReuseIdentifier: "RecipientTableViewCell")
        let nib2 = UINib(nibName: "SelectRecitientType2and3TableViewCell", bundle: nil)
        myTable.register(nib2, forCellReuseIdentifier: "SelectRecitientType2and3TableViewCell")
        myTable.bounces = false
        myTable.backgroundColor = .clear
        myTable.separatorStyle = .none
        
        searchTextfield.keyboardType = .default
        searchTextfield.returnKeyType = .search
        searchTextfield.autocapitalizationType = .allCharacters
        searchTextfield.delegate = self
        
        searchBgV.layer.cornerRadius = searchBgV.frame.size.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate.shared().tempTransferChoseMode = false
        AppDelegate.shared().hideTopButton()
        getRecipents()
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
