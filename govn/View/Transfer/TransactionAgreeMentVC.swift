//
//  TransactionAgreeMentVC.swift
//  indogo
//
//  Created by mac on 2020/9/3.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP
import WebKit

class TransactionAgreeMentVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var backgV: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var webView: WKWebView!
    
    //MARK: - API
    public func getAgreement() {
        let obj = AppDelegate.shared().transactionObj
        var recipient_id = AppDelegate.shared().transactionObj.recipientObj.recipient_id!
        if recipient_id == "" {
            recipient_id = AppDelegate.shared().tempRecipientObj.recipient_id
        }
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "doc_name":"外籍勞工薪資結匯申報委託書", "recipient_id":recipient_id, "transfer_amount_ntd":obj.ntdValue+obj.feeValue]
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
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "外籍勞工薪資結匯申報委託書")
                if result == ResponseState.ok {
                    self.webView.loadHTMLString(AppDelegate.shared().tempAgreementHtmlContent, baseURL: nil)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func createTransaction() {
        let obj = AppDelegate.shared().transactionObj
        let recipient_id = AppDelegate.shared().transactionObj.recipientObj.recipient_id!
        //let total_payment = obj.ntdValue + obj.feeValue -
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":obj.ntdValue,"kurs_lm_time":AppDelegate.shared().memberData["kurs_lm_time"]!, "service_charge":obj.feeValue, "total_payment":obj.totalNtdValue, "transfer_idr":
                                        obj.targetValue, "recipient_id":recipient_id, "pin_code_mode":2, "recipient_type":AppDelegate.shared().transactionObj.recipient_type,"currency":AppDelegate.shared().transactionObj.currency!]
        
        if obj.usePoint == 0 {
            parameters["use_remit_point"] = 0
        } else {
            parameters["use_remit_point"] = 1
            parameters["use_points"] = obj.usePoint
        }
        
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_TransactionCreate;
        
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
                    //self.getNextStep()
                    self.getTransferListAndCheck()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //改成直接撈history的資料，不然第一種銀行匯款，無法有地址資料
    public func getTransferListAndCheck() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken]
        let headers: HTTPHeaders = [:]
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_TransferHistory;
        
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
                
                AppDelegate.shared().transferStateListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    for i in 0..<AppDelegate.shared().transferStateListObjs.count {
                        let obj = AppDelegate.shared().transferStateListObjs[i]
                        if obj.payment_info == AppDelegate.shared().tempTransactionResultObj.payment_info {
                            self.getNextStep(TransferStateObj: obj)
                            return
                        }
                    }
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func getNextStep(TransferStateObj transferStateObj:TransferStateObj) {
        /*
        let transferStateObj = TransferStateObj()
        let serchBankobj = UtilityTool().searchBankObj(BankName: AppDelegate.shared().transactionObj.recipientObj.bank_name!)
        
        transferStateObj.bank_code = serchBankobj.bank_code
        transferStateObj.to_acc = AppDelegate.shared().transactionObj.recipientObj.bank_acc
        transferStateObj.total = "\(AppDelegate.shared().transactionObj.totalNtdValue)"
        transferStateObj.transfer_amount_idr = "\(AppDelegate.shared().transactionObj.targetValue)"
        transferStateObj.recipient_id = AppDelegate.shared().transactionObj.recipientObj.recipient_id
        transferStateObj.phone = AppDelegate.shared().transactionObj.recipientObj.phone_no
        transferStateObj.address = AppDelegate.shared().wholeAddress
            //AppDelegate.shared().transactionObj.recipientObj.address
        //AppDelegate.shared().tempRecipientObj.address
        transferStateObj.recipient_name =  AppDelegate.shared().transactionObj.recipientObj.recipient_name
        */
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionResultVC") as? TransactionResultVC
        nextVC?.payment_info = AppDelegate.shared().tempTransactionResultObj.payment_info
        nextVC?.transferStateObj = transferStateObj
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        createTransaction()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = ""
        
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.setTitle(NSLocalizedString("agree", comment: ""), for: .normal)
        webView.backgroundColor = .white
        backgV.layer.cornerRadius = 5
        getAgreement()
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
