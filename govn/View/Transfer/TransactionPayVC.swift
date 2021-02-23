//
//  TransactionPayVC.swift
//  indogo
//
//  Created by mac on 2020/9/4.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class TransactionPayVC: UIViewController {
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var paymentInfoL: UILabel!
    @IBOutlet weak var totalTWDL: UILabel!
    
    @IBOutlet weak var topScrollView: UIScrollView!
    
    @IBOutlet weak var upIntoL: UILabel!
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var minL: UILabel!
    @IBOutlet weak var minDownL: UILabel!
    @IBOutlet weak var secL: UILabel!
    @IBOutlet weak var secDownL: UILabel!
    
    @IBOutlet weak var barCodeBgV: UIView!
    @IBOutlet weak var barV1: UIView!
    @IBOutlet weak var barL1: UILabel!
    @IBOutlet weak var barV2: UIView!
    @IBOutlet weak var barL2: UILabel!
    @IBOutlet weak var barV3: UIView!
    @IBOutlet weak var barL3: UILabel!
    @IBOutlet weak var enlargeBtn: UIButton!
    @IBOutlet weak var barCodeImgV1: UIImageView!
    @IBOutlet weak var barCodeImgV2: UIImageView!
    @IBOutlet weak var barCodeImgV3: UIImageView!
    
    @IBOutlet weak var reloadL: UILabel!
    @IBOutlet weak var warnL: UILabel!
    @IBOutlet weak var bigBarCodeV: UIView!
    @IBOutlet weak var bigBarCodeImgV: UIImageView!
    
    var loadOnce = false
    var transferStateObj:TransferStateObj!
    var orderCheckStateObj:TransferOrderCheckObj!
    var payment_info:String = ""
    var chosedStyle:StoreType!
    var nowBarCodeObj:BarCodeInfoObj!
    var barcodeImg:UIImage!
    var oriScreenBightness:CGFloat = 0
    
    var countDownTimer:Timer!
    var startCountDown = false
    var expireTime:Date!
    
    //MARK: - API
    public func getBarCode() {
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "payment_info":payment_info, "mode":2]
        let headers: HTTPHeaders = [:]
        AppDelegate.shared().addLoadingView()
        
        var todoEndpoint: String = API_BarCode_711;
        
        if chosedStyle == StoreType.sevenEleven {
            todoEndpoint = API_BarCode_711
        } else if chosedStyle == StoreType.familymart {
            todoEndpoint = API_BarCode_fami
        } else if chosedStyle == StoreType.ok {
            todoEndpoint = API_BarCode_ok
        } else if chosedStyle == StoreType.hiLife {
            todoEndpoint = API_BarCode_hilife
        }
        
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
                    self.reloadData()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func reloadData() {
        self.nowBarCodeObj = AppDelegate.shared().tempBarCodeInfoObj
        
        var words = nowBarCodeObj.ol_code_1!
        var image = UtilityTool().generateBarCode39(from: words)
        barCodeImgV1.image = image
        barL1.text = words
        
        words = nowBarCodeObj.ol_code_2!
        image = UtilityTool().generateBarCode39(from: words)
        barCodeImgV2.image = image
        barL2.text = words
        
        words = nowBarCodeObj.ol_code_3!
        image = UtilityTool().generateBarCode39(from: words)
        barCodeImgV3.image = image
        barL3.text = words
        
        barL1.isHidden = false
        barL2.isHidden = false
        barL3.isHidden = false
        
        secL.isHidden = false
        minL.isHidden = false
        
        getScreenShotOfBarCodeView()
        
        expireTime = UtilityTool().dateStringToDate(Str: nowBarCodeObj.lm_time_expire.trimmingCharacters(in: .whitespacesAndNewlines))
        //Dlog("expireTime = \(expireTime), now = \(Date())")
        
        if countDownTimer == nil {
            countDownTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
            startCountDown = true
        }
    }
    
    func goExpiredVC() {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionExipredVC") as? TransactionExipredVC
        nextVC?.parentVC = self
        nextVC?.payment_info = payment_info
        nextVC?.transferStateObj = transferStateObj
        nextVC?.orderCheckStateObj = orderCheckStateObj
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @objc func countDown() {
        if startCountDown {
            let timeDiff = expireTime.timeIntervalSince(Date())
            
            if timeDiff <= 0 {
                startCountDown = false
                countDownTimer.invalidate()
                countDownTimer = nil
                secL.text = "00"
                minL.text = "00"
                goExpiredVC()
            } else {
                let timeIntDiff = Int(timeDiff)
                
                let leftSecs = timeIntDiff%60
                secL.text = String(format: "%02d", leftSecs)
                
                let leftMins = Int(timeIntDiff/60)%60
                minL.text = String(format: "%02d", leftMins)
            }
        }
    }
    
    func getScreenShotOfBarCodeView() {
        barcodeImg = barCodeBgV.takeScreenshot().rotate(radians: -1 * Float(Double.pi/2))
        bigBarCodeImgV.image = barcodeImg
    }
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func closeBigBarCodeView(_ sender: Any) {
        bigBarCodeV.isHidden = true
    }
    
    @IBAction func showBigBarCodeView(_ sender: Any) {
        bigBarCodeV.isHidden = false
    }
    
    @IBAction func reloadTime(_ sender: Any) {
        if startCountDown {
            return
        } else {
            getBarCode()
        }
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        AppDelegate.shared().hideTopButton()
        backL.text = NSLocalizedString("Transfer PayStep Title", comment: "")
        upIntoL.text = NSLocalizedString("Transfer PayStep Up Intro", comment: "")
        warnL.text = NSLocalizedString("Transfer PayStep Warn", comment: "")
        paymentInfoL.text = payment_info
        totalTWDL.text = "Total TWD \(transferStateObj.total.stringToIntDecimalString())"
        minDownL.text = NSLocalizedString("Transfer PayStep Min Title", comment: "")
        secDownL.text = NSLocalizedString("Transfer PayStep Sec Title", comment: "")
        enlargeBtn.setTitle(NSLocalizedString("Transfer PayStep Btn Enlarge", comment: ""), for: .normal)
        reloadL.text = NSLocalizedString("Transfer PayStep Btn Reload", comment: "")
        barL1.isHidden = true
        barL2.isHidden = true
        barL3.isHidden = true
        
        secL.isHidden = true
        minL.isHidden = true
        
        bigBarCodeV.isHidden = true
        
        /*
        let serchBankobj = UtilityTool().searchBankObj(BankCode: transferStateObj.bank_code!)
        let imgurl = serchBankobj.bank_photo!
        let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        iconImgV.kf.setImage(with: urlhaed)
        */
        iconImgV.image = nil
        
        barCodeBgV.layer.borderColor = UIColor.black.cgColor
        barCodeBgV.layer.borderWidth = 0.5
        
        enlargeBtn.layer.cornerRadius = enlargeBtn.frame.size.height/2
        enlargeBtn.layer.borderColor = Color_Main_Red.cgColor
        enlargeBtn.layer.borderWidth = 0.5
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        UIScreen.main.brightness = oriScreenBightness
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        oriScreenBightness = UIScreen.main.brightness
        UIScreen.main.brightness = CGFloat(1)
        
        if loadOnce {
            return
        }
        
        loadOnce = true
        reloadData()
        
        if chosedStyle == StoreType.sevenEleven {
            iconImgV.image = UIImage.init(named: "711.png")
        } else if chosedStyle == StoreType.familymart {
            iconImgV.image = UIImage.init(named: "fanilymart.png")
        } else if chosedStyle == StoreType.ok {
            iconImgV.image = UIImage.init(named: "okmart.png")
        } else if chosedStyle == StoreType.hiLife {
            iconImgV.image = UIImage.init(named: "hilife.png")
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
