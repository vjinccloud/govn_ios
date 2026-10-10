//
//  TransactionBankVC.swift
//  indogo
//
//  Created by mac on 2021/6/4.
//  Copyright © 2021 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class TransactionBankVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var paymentInfoL: UILabel!
    @IBOutlet weak var copyCodeBtn: UIButton!
    @IBOutlet weak var topScrollView: UIScrollView!
    
    @IBOutlet weak var bankCodeTL: UILabel!
    @IBOutlet weak var bankCodeL: UILabel!
    
    @IBOutlet weak var bankAccTL: UILabel!
    @IBOutlet weak var bankAccL: UILabel!
    
    @IBOutlet weak var bankTotalTL: UILabel!
    @IBOutlet weak var bankTotalL: UILabel!
    
    @IBOutlet weak var expireL: UILabel!
    @IBOutlet weak var expireTL: UILabel!
    
    @IBOutlet weak var expireETL: UILabel!
    @IBOutlet weak var expireEL: UILabel!
    
    @IBOutlet weak var expireBackV: UIView!
    
    @IBOutlet weak var teachView: UIView!
    
    var payment_info:String = ""
    var loadOnce = false
    var transferStateObj:TransferStateObj!
    
    var bankInfoJSON:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("Transfer PayStep Title", comment: "")
        paymentInfoL.text = payment_info.separateSpecialForIndoGo()
        
        bankCodeTL.text = NSLocalizedString("Transfer New bank code", comment: "")
        bankAccTL.text = NSLocalizedString("Transfer New bank acc", comment: "")
        bankTotalTL.text = NSLocalizedString("Transfer New bank total", comment: "")
        expireTL.text = NSLocalizedString("Transfer New bank expire 2", comment: "")
        expireETL.text = NSLocalizedString("Transfer New bank expire 3", comment: "")
        
        expireBackV.layer.borderWidth = 0.5
        expireBackV.layer.borderColor = Color_Main_Red.cgColor
        
        expireETL.adjustsFontSizeToFitWidth = true
        copyCodeBtn.layer.cornerRadius = 8
        
        bankCodeL.text = bankInfoJSON["bank_code"].stringValue
        bankAccL.text = bankInfoJSON["account"].stringValue.separate(every:4, with: " ")

        let secondAttributes = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]

        let firstString = NSMutableAttributedString(string: NSLocalizedString("Transfer New bank expire", comment: ""))
        let secondString = NSAttributedString(string: bankInfoJSON["expired_date_zh_tw"].stringValue, attributes: secondAttributes)

        firstString.append(secondString)
        expireL.attributedText = firstString
        expireL.adjustsFontSizeToFitWidth = true
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: bankInfoJSON["expired_date_id_id"].stringValue, attributes: underlineAttribute)
        expireEL.attributedText = underlineAttributedString
        
        bankTotalL.text = "TWD \(transferStateObj.total.stringToIntDecimalString())"
    }
    
    //MARK: - Button Action
    @IBAction func copyAccAction(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = bankInfoJSON["account"].stringValue
        
        AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("Transfer New bank copy success", comment: ""))
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        //new tpye 直接回上頁
        self.navigationController?.popViewController(animated: true)
        //self.navigationController?.popToRootViewController(animated: true)
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
