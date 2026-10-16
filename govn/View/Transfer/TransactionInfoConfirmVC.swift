//
//  TransactionInfoConfirmVC.swift
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

class TransactionInfoConfirmVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    
    @IBOutlet weak var backgV: UIView!
    @IBOutlet weak var nameL: UILabel!
    //@IBOutlet weak var iconImgV: UIImageView!
    //@IBOutlet weak var accountL: UILabel!
    //@IBOutlet weak var accountNameL: UILabel!
    @IBOutlet weak var twdL: UILabel!
    @IBOutlet weak var twdVL: UILabel!
    @IBOutlet weak var feeL: UILabel!
    @IBOutlet weak var feeVL: UILabel!
    @IBOutlet weak var usePointL: UILabel!
    @IBOutlet weak var usePointVL: UILabel!
    @IBOutlet weak var totalL: UILabel!
    @IBOutlet weak var totalVL: UILabel!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var midV: UIView!
    @IBOutlet weak var midVHeight: NSLayoutConstraint!
    @IBOutlet weak var bankAndCPView: UIView!
    @IBOutlet weak var dtdView: UIView!
    
    @IBOutlet weak var bandcIDL: UILabel!
    @IBOutlet weak var bandcPhoneL: UILabel!
    @IBOutlet weak var bandcAccL: UILabel!
    @IBOutlet weak var bandcIconImgV: UIImageView!
    
    @IBOutlet weak var dtdIDL: UILabel!
    @IBOutlet weak var dtdPhoneL: UILabel!
    @IBOutlet weak var dtdAdrL: UILabel!
    
    var topBarSelectIdx = 0
    
    //MARK: - API
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
                    self.recalculateTargetMoneyAndGoNext()
                    URLCache.shared.removeAllCachedResponses()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        //再計算一次匯率
        callMemberData()
    }
    
    @IBAction func backAction(_ sender: Any) {
        //一律回想選擇畫面
        guard let viewControllers = self.navigationController?.viewControllers else {
            return
        }
        
        for firstViewController in viewControllers {
            if firstViewController is RecipientListVC {
                self.navigationController?.popToViewController(firstViewController, animated: true)
                break
            }
        }
        
        //self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - View-Life
    func recalculateTargetMoneyAndGoNext() {
        //202311 改成不重新計算
        //改成直接到結果頁
        createTransaction()
        
        /*
        let obj = AppDelegate.shared().transactionObj
        var kursValue = Double(AppDelegate.shared().memberData["kurs_value"]!)!
        if AppDelegate.shared().transactionObj.currency! == "USD" {
            kursValue = 1/Double(AppDelegate.shared().memberData["usd_kurs_value"]!)!
        } else {
            kursValue = Double(AppDelegate.shared().memberData["kurs_value"]!)!
        }
        
        //--should-- 20210608 把這函數所有 ceil 改成 round
        let downValue = Int(round(Double(AppDelegate.shared().transactionObj.ntdValue) * kursValue))
        AppDelegate.shared().transactionObj.targetValue = downValue
        
        //AppDelegate.shared().transactionObj.targetValue = Int(round(Double(obj.ntdValue) * kursValue))
        
        //改成直接到結果頁
        createTransaction()
        */
        
        /*
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionAgreeMentVC") as? TransactionAgreeMentVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
         */
    }
    
    public func createTransaction() {
        let obj = AppDelegate.shared().transactionObj
        let recipient_id = AppDelegate.shared().transactionObj.recipientObj.recipient_id!
        //let total_payment = obj.ntdValue + obj.feeValue -
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":obj.ntdValue,"kurs_lm_time":AppDelegate.shared().memberData["kurs_lm_time"]!, "service_charge":obj.feeValue, "total_payment":obj.totalNtdValue, "transfer_idr":
                                        obj.targetValue, "recipient_id":recipient_id, "purposes_id":obj.purposes_id, "pin_code_mode":PinCodeMode, "recipient_type":AppDelegate.shared().transactionObj.recipient_type,"currency":AppDelegate.shared().transactionObj.currency!]
        
        if obj.usePoint == 0 {
            parameters["use_remit_point"] = 0
        } else {
            parameters["use_remit_point"] = 1
            parameters["use_points"] = obj.usePoint
        }
        
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        var todoEndpoint: String = API_TransactionCreate;
        if AppDelegate.shared().discountForTransfer != "" {
            todoEndpoint = API_TransactionCreateV2
            parameters["discount_code"] = AppDelegate.shared().discountCode
            parameters["discount_amt"] = AppDelegate.shared().discountForTransfer
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        twdL.text = NSLocalizedString("Transfer Confirm TWD Title", comment: "")
        feeL.text = NSLocalizedString("Transfer Confirm Fee Title", comment: "")
        usePointL.text = NSLocalizedString("Transfer Confirm UsePoint Title", comment: "")
        totalL.text = NSLocalizedString("Transfer Confirm Total Title", comment: "")
        nameL.adjustsFontSizeToFitWidth = true
        nameL.textAlignment = .center
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.setTitle(NSLocalizedString("SUBMIT", comment: ""), for: .normal)
        
        backgV.layer.cornerRadius = 5
        backL.text = NSLocalizedString("Transfer Confirm Title", comment: "")
        let obj = AppDelegate.shared().transactionObj
        var valueStr = "\(obj.ntdValue)".stringToIntDecimalString()
        twdVL.text = "NTD \(valueStr)"
        feeVL.text = "\(obj.feeValue)"
        if obj.usePoint > 0 {
            usePointVL.text = "-\(obj.usePoint)"
        } else {
            usePointVL.text = "\(obj.usePoint)"
        }
        
        valueStr = "\(obj.totalNtdValue)".stringToIntDecimalString()
        totalVL.text = "\(valueStr)"
        
        nameL.text = obj.recipientObj.recipient_name
        
        var provinceName = ""
        if AppDelegate.shared().transactionObj.recipient_type == 3 {
            bankAndCPView.isHidden = true
            dtdView.isHidden = false
            midVHeight.constant = 160
            
            dtdIDL.text = obj.recipientObj.id_card_no
            dtdPhoneL.text = obj.recipientObj.phone_no
            
            var address = obj.recipientObj.address + " "
            var choseProvinceIdx = Int(AppDelegate.shared().tempRecipientObj.province_id)!
            
            //比對省份
            var ori = AppDelegate.shared().tempRecipientObj.province_id
            for i in 0..<AppDelegate.shared().provinceData.count {
                let str = AppDelegate.shared().provinceData[i].province_id
                if ori == str {
                    choseProvinceIdx = i
                    provinceName = AppDelegate.shared().provinceData[i].province_name
                    break
                }
            }
            
            ori = AppDelegate.shared().tempRecipientObj.district_id
            for i in 0..<AppDelegate.shared().provinceData[choseProvinceIdx].allZone.count {
                let str = AppDelegate.shared().provinceData[choseProvinceIdx].allZone[i].district_id
                if ori == str {
                    address += " " + AppDelegate.shared().provinceData[choseProvinceIdx].allZone[i].district_name
                    break
                }
            }
            
            address += " " + provinceName
            
            /*
            //比對省份
            ori = AppDelegate.shared().tempRecipientObj.province_id
            for i in 0..<AppDelegate.shared().provinceData.count {
                let str = AppDelegate.shared().provinceData[i].province_id
                if ori == str {
                    choseProvinceIdx = i
                    address += " " + AppDelegate.shared().provinceData[i].province_name
                    provinceName = AppDelegate.shared().provinceData[i].province_name
                    break
                }
            }*/
            
            dtdAdrL.text = address
        } else {
            bankAndCPView.isHidden = false
            dtdView.isHidden = true
            bandcIDL.text = obj.recipientObj.id_card_no
            bandcPhoneL.text = obj.recipientObj.phone_no
            bandcAccL.text = obj.recipientObj.bank_acc
            
            midVHeight.constant = 190
            Dlog("obj.recipientObj.bank_code = \(obj.recipientObj.bank_code!)")
            var serchBankobj = UtilityTool().searchBankObj(BankName: obj.recipientObj.bank_name!)
            if obj.recipientObj.bank_code != "" {
                serchBankobj = UtilityTool().searchBankObj(BankCode: obj.recipientObj.bank_code!)
            } else {
                serchBankobj = UtilityTool().searchBankObj(BankName: obj.recipientObj.bank_name!)
            }
            
            let imgurl = serchBankobj.bank_photo!
            Dlog("serchBankobj.bank_photo! = \(serchBankobj.bank_photo!)")
            let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            bandcIconImgV.kf.setImage(with: urlhaed)
        }
        
        //accountL.text = obj.recipientObj.bank_acc
        //accountNameL.text = obj.recipientObj.recipient_name
        //accountNameL.adjustsFontSizeToFitWidth = true
        
        
        
        //重抓一次匯率，再計算一次
        //callMemberData(Continue: false)
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
