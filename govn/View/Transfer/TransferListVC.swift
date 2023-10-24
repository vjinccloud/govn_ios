//
//  TransferListVC.swift
//  indogo
//
//  Created by mac on 2020/8/30.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class TransferListVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBgV: UIView!
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var myTable: UITableView!
    
    var showDataList:[TransferStateObj] = []
    var showOrderCheckDataList:[TransferOrderCheckObj] = []
    var searchShowIndex:[Int] = []
    var cellBarColor:[UIColor] = []
    var loadOnce = false
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return searchShowIndex.count
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let realIdx = searchShowIndex[indexPath.row]
        let cellOrderCheckData = showOrderCheckDataList[realIdx]
        
        if cellOrderCheckData.order_status == "5" {
            return 215
        } else {
            return 320
        }
        
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransferStateType1TableViewCell", for: indexPath) as! TransferStateType1TableViewCell
        
        let realIdx = searchShowIndex[indexPath.row]
        let cellData = showDataList[realIdx]
        let cellOrderCheckData = showOrderCheckDataList[realIdx]
        
        let serchBankobj = UtilityTool().searchBankObj(BankCode: cellData.bank_code!)
        
        cell.barTitleL.text = NSLocalizedString("Transfer State " + cellOrderCheckData.order_status, comment: "")
        
        let colorIdx = Int(cellOrderCheckData.order_status)! - 1
        if colorIdx >= 0, colorIdx <= 4 {
            cell.barV.backgroundColor = cellBarColor[colorIdx]
        }
        
        cell.failV.isHidden = true
        cell.failType2V.isHidden = true
        cell.downV.isHidden = true
        cell.downType2V.isHidden = true
        cell.upV.isHidden = false
        cell.pureTextV.isHidden = false
        cell.midL.isHidden = false
        
        if cellOrderCheckData.order_status != "5" {
            if cellData.recipient_type == "1" {
                cell.downV.isHidden = false
                cell.downType2V.isHidden = true
                cell.midL.text = NSLocalizedString("Transfer State Mid Text Title", comment: "")
                
                if cellOrderCheckData.order_status != "5" {
                    let imgurl = serchBankobj.bank_photo!
                    let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
                    cell.downIconIgV.kf.setImage(with: urlhaed)
                }
                
                cell.downNameL.text = cellData.recipient_name
                cell.downIDL.text = cellData.to_acc
                cell.downValueL.text = "VND " + cellData.transfer_amount_idr.stringToIntDecimalString()
                cell.downNoteL.text = NSLocalizedString("Transfer State Down Kurs Value Title", comment: "") + " " + cellData.kurs_value
                
            } else {
                cell.downV.isHidden = true
                cell.downType2V.isHidden = false
                
                if cellData.recipient_type == "2" {
                    cell.midL.text = NSLocalizedString("Transfer State Mid Text Title2", comment: "")
                } else if cellData.recipient_type == "3" {
                    cell.midL.text = NSLocalizedString("Transfer State Mid Text Title3", comment: "")
                }
                
                cell.downType2L1.text = ""
                //--shoud--
                let str = cellData.recipient_name + "  CMND: " + cellData.id_card_no
                let attributedString = NSMutableAttributedString(string: str);
                attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 14), range: NSMakeRange(0, cellData.recipient_name.count));
                cell.downType2L1.attributedText = attributedString
                
                cell.downType2L2.text = cellData.phone
                cell.downType2L3.text = cellData.address//計算越南盾
                let totalvnd = Int((cellData.kurs_value as NSString).floatValue * (cellData.transfer_amount_idr as NSString).floatValue)
                let totalstr = "\(totalvnd)"
                
                if cellData.recipient_type == "3" {
                    cell.downType2L4.text = cellData.currency + " " + cellData.transfer_amount_idr.stringToIntDecimalString()
                    //totalstr.stringToIntDecimalString()
                } else {
                    cell.downType2L4.text = "VND " + cellData.transfer_amount_idr.stringToIntDecimalString()
                    //totalstr.stringToIntDecimalString()
                }
                
                cell.downType2L5.text = NSLocalizedString("Transfer State Down Kurs Value Title", comment: "") + " " + cellData.kurs_value
            }
        }
        
        cell.upIconIgV.image = UIImage.init()
        cell.setTransferState(Stae: cellOrderCheckData.order_status)
        
        if cellOrderCheckData.order_status == "1" {
            cell.pureTextV.isHidden = false
            cell.upV.isHidden = true
            
            cell.barNumberV.isHidden = false
            cell.barTimeL.isHidden = true
            
            cell.pureNameL.text = NSLocalizedString("Transfer State Pure Text Title", comment: "") //cellData.recipient_name
            cell.pureValueL.text = "NTD " + cellData.total.stringToIntDecimalString()
            cell.pureCodeL.text = cellData.payment_info
            
            let expireTimeStr = cellOrderCheckData.lm_time_expire!
            let serverTimeStr = cellOrderCheckData.server_time!
            
            let time1 = UtilityTool().dateStringToTime(Str: expireTimeStr)
            let time2 = UtilityTool().dateStringToTime(Str: serverTimeStr)
            
            if time1 < 0 || time2 < 0 {
                cell.barNumberV.isHidden = true
            } else {
                cell.startCountDown(Time: expireTimeStr)
                /*
                let diffTime = Int(time1 - time2)
                if diffTime < 0 {
                    cell.barNumberV.isHidden = true
                } else {
                    let leftSecs = diffTime%60
                    cell.n5L.text = "\(leftSecs%10)"
                    cell.n4L.text = "\(Int(leftSecs/10))"
                    
                    let leftMins = Int(diffTime/60)%60
                    cell.n3L.text = "\(leftMins%10)"
                    cell.n2L.text = "\(Int(leftMins/10))"
                    
                    let leftHours = Int(diffTime/3600)
                    cell.n1L.text = "\(leftHours%10)"
                    cell.n0L.text = "\(Int(leftHours/10))"
                }*/
            }
            
        } else if cellOrderCheckData.order_status == "5" {
            cell.barNumberV.isHidden = true
            cell.barTimeL.isHidden = false
            
            cell.failV.isHidden = false
            cell.downV.isHidden = true
            cell.downType2V.isHidden = true
            cell.upV.isHidden = true
            cell.pureTextV.isHidden = true
            cell.midL.isHidden = true
            
            let timeStr = UtilityTool().transferIndogoDate(Date:cellOrderCheckData.lm_time_failed!)
            cell.barTimeL.text = timeStr
            
            let imgurl = serchBankobj.bank_photo!
            let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            cell.failIconIgV.kf.setImage(with: urlhaed)
            
            if cellData.recipient_type == "1" {
                cell.failType2V.isHidden = true
                Dlog("failed 1")
                cellData.printSelf()
                cell.failNameL.text = cellData.recipient_name
                cell.failIDL.text = cellData.to_acc
                //cell.failValueL.text = "NTD " + cellData.transfer_amount_idr.stringToIntDecimalString() failType2L4
                cell.failValueL.text = "\(cellData.currency!) " + cellData.transfer_amount_idr.stringToIntDecimalString()
                cell.failNoteL.text = NSLocalizedString("Transfer State Down Kurs Value Title", comment: "") + " " + cellData.kurs_value
                
            } else {
                cell.failType2V.isHidden = false
                Dlog("failed 2")
                cellData.printSelf()
                cell.failType2L1.text = ""
                //--should--
                //let str = cellData.recipient_name + "  " + "ID: " + cellData.recipient_id
                let str = cellData.recipient_name + "  " + "CMND: " + cellData.id_card_no
                let attributedString = NSMutableAttributedString(string: str);
                attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 14), range: NSMakeRange(0, cellData.recipient_name.count));
                cell.failType2L1.attributedText = attributedString
                
                cell.failType2L2.text = cellData.phone
                cell.failType2L3.text = cellData.address
                cell.failType2L4.text = "\(cellData.currency!) " + cellData.transfer_amount_idr.stringToIntDecimalString()
                cell.failType2L5.text = NSLocalizedString("Transfer State Down Kurs Value Title", comment: "") + " " + cellData.kurs_value
            }
            
        } else {
            
            cell.barNumberV.isHidden = true
            cell.barTimeL.isHidden = false
            cell.pureTextV.isHidden = true
            cell.upV.isHidden = false
            cell.upV.alpha = 1
            cell.failV.isHidden = true
            
            if cellOrderCheckData.mini_mart_id == "1" {
                cell.upIconIgV.image = UIImage.init(named: "711.png")
            } else if cellOrderCheckData.mini_mart_id == "2" {
                cell.upIconIgV.image = UIImage.init(named: "fanilymart.png")
            } else if cellOrderCheckData.mini_mart_id == "3" {
                cell.upIconIgV.image = UIImage.init(named: "okmart.png")
            } else if cellOrderCheckData.mini_mart_id == "4" {
                cell.upIconIgV.image = UIImage.init(named: "hilife.png")
            }
            
            var timeStr = cellOrderCheckData.lm_time_paid!
            if cellOrderCheckData.order_status == "2" {
                timeStr = cellOrderCheckData.lm_time_paid!
            } else if cellOrderCheckData.order_status == "3" {
                timeStr = cellOrderCheckData.lm_time_process!
            } else if cellOrderCheckData.order_status == "4" {
                timeStr = cellOrderCheckData.lm_time_transfer!
            }
            
            cell.barTimeL.text = UtilityTool().transferIndogoDate(Date:timeStr)
            
            let ary = timeStr.components(separatedBy: " ")
            
            if ary.count > 1 {
                cell.upIDL.text = NSLocalizedString("Transfer State Down Time Title", comment: "") + " " + ary[1]
            } else {
                cell.upIDL.text = ""
            }
            
            cell.upValueL.text = "NTD " + cellData.total.stringToIntDecimalString()
            cell.upNoteL.text = cellData.payment_info
            
        }
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let realIdx = searchShowIndex[indexPath.row]
        let cellData = showDataList[realIdx]
        let cellOrderCheckData = showOrderCheckDataList[realIdx]
        
        if cellOrderCheckData.order_status == "5" {
            return
        }
        
        if cellOrderCheckData.order_status != "1" {
            return
        }
        
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionResultVC") as? TransactionResultVC
        nextVC?.payment_info = cellData.payment_info
        nextVC?.transferStateObj = cellData
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - API
    public func getAllOrdersDetail() {
        if AppDelegate.shared().transferStateListObjs.count==0 {
            return
        }
        
        var paymentAry:[String] = []
        for i in 0..<AppDelegate.shared().transferStateListObjs.count {
            let obj = AppDelegate.shared().transferStateListObjs[i]
            paymentAry.append(obj.payment_info)
        }
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "payment_info":paymentAry]
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_OrderCheckMuilti;
        
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
                
                AppDelegate.shared().transferOrderCheckListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.reloadDataAndTable(Str: self.searchTextfield.text!)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    /*
    public func getAllOrdersDetail() {
        if AppDelegate.shared().transferStateListObjs.count==0 {
            return
        }
        
        var paymentAry:[String] = []
        for i in 0..<AppDelegate.shared().transferStateListObjs.count {
            let obj = AppDelegate.shared().transferStateListObjs[i]
            paymentAry.append(obj.payment_info)
        }
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "payment_info":paymentAry]
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_OrderCheckMuilti;
        
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
                
                AppDelegate.shared().transferOrderCheckListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.reloadDataAndTable(Str: self.searchTextfield.text!)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }*/
    
    public func getTransferList() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken]
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_TransferHistory;
        
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
                Dlog("API_TransferHistory responseStr = \(responseStr ?? "")")
                
                AppDelegate.shared().transferStateListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.getAllOrdersDetail()
                    //self.reloadDataAndTable()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
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
        
        guard let text = textField.text else{
            return true
        }
        
        if !string.checkAlphabetDigitAndSpace() {
            return false
        }
        
        let textLength = text.count + string.count - range.length
        if textLength>20 {
            return false
        }
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        reloadDataAndTable(Str: newString)
        return true

    }
    
    //MARK: - Utility
    func reloadDataAndTable(Str str:String) {
        //根據search字串過濾
        searchShowIndex = []
        showDataList = AppDelegate.shared().transferStateListObjs
        showOrderCheckDataList = AppDelegate.shared().transferOrderCheckListObjs
        
        if str == "" {
            for i in 0..<showDataList.count {
                searchShowIndex.append(i)
            }
        } else {
            let searchStr = str.lowercased()
            for i in 0..<showDataList.count {
                let obj = showDataList[i]
                if obj.payment_info.lowercased().contains(searchStr) || obj.to_acc.lowercased().contains(searchStr) || obj.recipient_name.lowercased().contains(searchStr) {
                    searchShowIndex.append(i)
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
        let nib = UINib(nibName: "TransferStateType1TableViewCell", bundle: nil)
        myTable.register(nib, forCellReuseIdentifier: "TransferStateType1TableViewCell")
        myTable.bounces = false
        myTable.backgroundColor = .clear
        myTable.separatorStyle = .none
        
        searchTextfield.keyboardType = .default
        searchTextfield.returnKeyType = .search
        searchTextfield.delegate = self
        
        searchBgV.layer.cornerRadius = searchBgV.frame.size.height/2
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            AppDelegate.shared().showTopButton()
            return
        }
        
        loadOnce = true
        
        cellBarColor.append(UtilityTool().hexStringToUIColor(hex: "#BD1621"))
        cellBarColor.append(UtilityTool().hexStringToUIColor(hex: "#156784"))
        cellBarColor.append(UtilityTool().hexStringToUIColor(hex: "#FDA11A"))
        cellBarColor.append(UtilityTool().hexStringToUIColor(hex: "#2B712A"))
        cellBarColor.append(UtilityTool().hexStringToUIColor(hex: "#706F6F"))
        
        //nowPage = 1
        getTransferList()
        
        //頂部兩個按鈕
        AppDelegate.shared().topMargin = self.view.safeAreaInsets.top
        AppDelegate.shared().addTopButton()
        
        AppDelegate.shared().nowBottomMenuType = .transState
        AppDelegate.shared().bottomMenu.paintMenu()
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
