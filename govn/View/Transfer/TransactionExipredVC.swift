//
//  TransactionExipredVC.swift
//  indogo
//
//  Created by mac on 2020/9/5.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class TransactionExipredVC: UIViewController {
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var warnL: UILabel!
    @IBOutlet weak var warn2L: UILabel!
    @IBOutlet weak var warnTL: UILabel!
    @IBOutlet weak var twdL: UILabel!
    @IBOutlet weak var reloadBtn: UIButton!
    
    var loadOnce = false
    var transferStateObj:TransferStateObj!
    var orderCheckStateObj:TransferOrderCheckObj!
    var payment_info:String = ""
    var chosedStyle:StoreType!
    var parentVC:TransactionPayVC!
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func reloadTimer(_ sender: Any) {
        parentVC.getBarCode()
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = ""
        warnL.text = payment_info
        warn2L.text = NSLocalizedString("Transfer Expired Step Warn2", comment: "")
        warnTL.text = NSLocalizedString("Transfer Expired Step Warn Title", comment: "")
        
        twdL.text = "NTD \(transferStateObj.total.stringToIntDecimalString())"
        reloadBtn.setTitle(NSLocalizedString("Transfer Expired Step Btn Title", comment: "") + "    ", for: .normal)
        reloadBtn.layer.cornerRadius = reloadBtn.frame.size.height/2
        
        //應該是超商logo
        if chosedStyle == StoreType.sevenEleven {
            iconImgV.image = UIImage.init(named: "711.png")
        } else if chosedStyle == StoreType.familymart {
            iconImgV.image = UIImage.init(named: "fanilymart.png")
        } else if chosedStyle == StoreType.ok {
            iconImgV.image = UIImage.init(named: "okmart.png")
        } else if chosedStyle == StoreType.hiLife {
            iconImgV.image = UIImage.init(named: "hilife.png")
        }
        /*
        let serchBankobj = UtilityTool().searchBankObj(BankCode: transferStateObj.bank_code!)
        let imgurl = serchBankobj.bank_photo!
        let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        iconImgV.kf.setImage(with: urlhaed)
        */
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
