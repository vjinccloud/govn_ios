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
    
    //MARK: - API
    public func callMemberData() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_CheckLogin;
        
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
                    self.recalculateTargetMoneyAndGoNext()
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
        let obj = AppDelegate.shared().transactionObj
        let kursValue = Double(AppDelegate.shared().memberData["kurs_value"]!)!
        AppDelegate.shared().transactionObj.targetValue = Int(ceil(Double(obj.ntdValue) * kursValue))
        
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionAgreeMentVC") as? TransactionAgreeMentVC
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
        nextBtn.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
        
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
        
        if AppDelegate.shared().transactionObj.recipient_type == 3 {
            bankAndCPView.isHidden = true
            dtdView.isHidden = false
            midVHeight.constant = 160
            
            dtdIDL.text = obj.recipientObj.id_card_no
            dtdPhoneL.text = obj.recipientObj.phone_no
            
            var address = ""
            var choseProvinceIdx = 0
            //比對省份
            var ori = AppDelegate.shared().tempRecipientObj.province_id
            for i in 0..<AppDelegate.shared().provinceData.count {
                let str = AppDelegate.shared().provinceData[i].province_id
                if ori == str {
                    choseProvinceIdx = i
                    address += AppDelegate.shared().provinceData[i].province_name
                    break
                }
            }
            
            ori = AppDelegate.shared().tempRecipientObj.district_id
            for i in 0..<AppDelegate.shared().provinceData[choseProvinceIdx].allZone.count {
                let str = AppDelegate.shared().provinceData[choseProvinceIdx].allZone[i].district_id
                if ori == str {
                    address += AppDelegate.shared().provinceData[choseProvinceIdx].allZone[i].district_name
                    break
                }
            }
            dtdAdrL.text = address + " " + obj.recipientObj.address
            
        } else {
            bankAndCPView.isHidden = false
            dtdView.isHidden = true
            bandcIDL.text = obj.recipientObj.id_card_no
            bandcPhoneL.text = obj.recipientObj.phone_no
            bandcAccL.text = obj.recipientObj.bank_acc
            midVHeight.constant = 190
            Dlog("obj.recipientObj.bank_code = \(obj.recipientObj.bank_code!)")
            var serchBankobj = UtilityTool().searchBankObj(BankName: obj.recipientObj.bank_name!)
            if obj.recipientObj.bank_name == "" {
                serchBankobj = UtilityTool().searchBankObj(BankCode: obj.recipientObj.bank_code!)
            } else {
                serchBankobj = UtilityTool().searchBankObj(BankName: obj.recipientObj.bank_name!)
            }
            
            let imgurl = serchBankobj.bank_photo!
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
