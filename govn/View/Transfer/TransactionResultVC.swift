//
//  TransactionResultVC.swift
//  indogo
//
//  Created by mac on 2020/9/3.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class TransactionResultVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var paymentInfoL: UILabel!
    @IBOutlet weak var totalTWDL: UILabel!
    
    @IBOutlet weak var topScrollView: UIScrollView!
    
    @IBOutlet weak var barV: UIView!
    @IBOutlet weak var barTitleL: UILabel!
    @IBOutlet weak var barNumberV: UIView!
    @IBOutlet weak var n0L: UILabel!
    @IBOutlet weak var n1L: UILabel!
    @IBOutlet weak var n2L: UILabel!
    @IBOutlet weak var n3L: UILabel!
    @IBOutlet weak var n4L: UILabel!
    @IBOutlet weak var n5L: UILabel!
    
    @IBOutlet weak var downV: UIView!
    @IBOutlet weak var downIconIgV: UIImageView!
    @IBOutlet weak var downNameL: UILabel!
    @IBOutlet weak var downIDL: UILabel!
    @IBOutlet weak var downValueL: UILabel!
    @IBOutlet weak var downNoteL: UILabel!
    
    @IBOutlet weak var storeTitleL: UILabel!
    
    @IBOutlet weak var teachView: UIView!
    @IBOutlet weak var teach1ImgV: UIImageView!
    @IBOutlet weak var teach2ImgV: UIImageView!
    @IBOutlet weak var teach3ImgV: UIImageView!
    @IBOutlet weak var teach4ImgV: UIImageView!
    
    @IBOutlet weak var goMapL: UILabel!
    @IBOutlet weak var goMapBtn: UIButton!
    
    @IBOutlet weak var payV: UIView!
    @IBOutlet weak var goPayL: UILabel!
    @IBOutlet weak var goPayBtn: UIButton!
    
    var loadOnce = false
    var transferStateObj:TransferStateObj!
    var orderCheckStateObj:TransferOrderCheckObj!
    var payment_info:String = ""
    var chosedStyle = StoreType.sevenEleven
    var hasScanCodeFig = false
    
    //MARK: - API
    public func getOrderDetail() {
        var paymentAry:[String] = []
        paymentAry.append(payment_info)
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "payment_info":paymentAry]
        let headers: HTTPHeaders = [:]
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_OrderCheckMuilti;
        
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
                
                AppDelegate.shared().transferOrderCheckListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.reloadData()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func reloadData() {
        
        if AppDelegate.shared().transferOrderCheckListObjs.count>0 {
            orderCheckStateObj = AppDelegate.shared().transferOrderCheckListObjs[0]
            
            transferStateObj.printSelf()
            orderCheckStateObj.printSelf()
            
            if payment_info.count<14 {
                paymentInfoL.text = payment_info
            } else {
                paymentInfoL.text = payment_info.getSubString(Start: 0, EndNotInclude: 3) + " " + payment_info.getSubString(Start: 3, EndNotInclude: 9) + " " + payment_info.getSubString(Start: 9, EndNotInclude: 14)
            }
            
            totalTWDL.text = "Total TWD \(transferStateObj.total ?? "0")"
            barTitleL.text = NSLocalizedString("Transfer State " + orderCheckStateObj.order_status, comment: "")
            let serchBankobj = UtilityTool().searchBankObj(BankCode: transferStateObj.bank_code!)
            
            let imgurl = serchBankobj.bank_photo!
            let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            self.downIconIgV.kf.setImage(with: urlhaed)
            
            self.downNameL.text = transferStateObj.recipient_name
            self.downIDL.text = transferStateObj.to_acc
            
            self.downValueL.text = "IDR " + transferStateObj.transfer_amount_idr.stringToIntDecimalString()
            self.downNoteL.text = NSLocalizedString("Transfer State Down Kurs Value Title", comment: "") + " " + transferStateObj.kurs_value
            
            /*
            let expireTimeStr = orderCheckStateObj.lm_time_expire!
            let serverTimeStr = orderCheckStateObj.server_time!
            
            let time1 = UtilityTool().dateStringToTime(Str: expireTimeStr)
            let time2 = UtilityTool().dateStringToTime(Str: serverTimeStr)
            Dlog("time1 = \(time1), time2 = \(time2)")
            if time1 < 0 || time2 < 0 {
            } else {
                let diffTime = Int(time1 - time2)
                if diffTime < 0 {
                } else {
                    let leftSecs = diffTime%60
                    self.n5L.text = "\(leftSecs%10)"
                    self.n4L.text = "\(Int(leftSecs/10))"
                    
                    let leftMins = Int(diffTime/60)%60
                    self.n3L.text = "\(leftMins%10)"
                    self.n2L.text = "\(Int(leftMins/10))"
                    
                    let leftHours = Int(diffTime/3600)
                    self.n1L.text = "\(leftHours%10)"
                    self.n0L.text = "\(Int(leftHours/10))"
                }
            }*/
        }
    }
    
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
                    let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionPayVC") as? TransactionPayVC
                    nextVC?.payment_info = self.payment_info
                    nextVC?.transferStateObj = self.transferStateObj
                    nextVC?.orderCheckStateObj = self.orderCheckStateObj
                    nextVC?.chosedStyle = self.chosedStyle
                    self.navigationController?.pushViewController(nextVC!, animated: true)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        //AppDelegate.shared().showTopButton()
    }
    
    func showBottomBtnAndTeachPic(StoreStyle style:StoreType) {
        topScrollView.setContentOffset(CGPoint.init(x: 0, y: teachView.frame.origin.y), animated: true)
        teachView.isHidden = false
        payV.isHidden = false
        teach1ImgV.isHidden = true
        teach2ImgV.isHidden = true
        teach3ImgV.isHidden = true
        teach4ImgV.isHidden = true
        
        if style == .sevenEleven {
            teach1ImgV.isHidden = false
        } else if style == .familymart {
            teach4ImgV.isHidden = false
        } else if style == .ok {
            teach3ImgV.isHidden = false
        } else if style == .hiLife {
            teach2ImgV.isHidden = false
        }
    }
    
    @IBAction func open711IntroAction(_ sender: Any) {
        chosedStyle = .sevenEleven
        showBottomBtnAndTeachPic(StoreStyle: .sevenEleven)
    }
    
    @IBAction func openFamilyMartIntroAction(_ sender: Any) {
        chosedStyle = .familymart
        showBottomBtnAndTeachPic(StoreStyle: .familymart)
    }
    
    @IBAction func openOKIntroAction(_ sender: Any) {
        chosedStyle = .ok
        showBottomBtnAndTeachPic(StoreStyle: .ok)
    }
    
    @IBAction func openHiLifeIntroAction(_ sender: Any) {
        chosedStyle = .hiLife
        showBottomBtnAndTeachPic(StoreStyle: .hiLife)
    }
    
    @IBAction func openMapAction(_ sender: Any) {
        let urlStr = "http://maps.apple.com/?q=便利商店"
        UIApplication.shared.open(URL.init(string: urlStr.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func openPayAction(_ sender: Any) {
        getBarCode()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("Transfer Result Title", comment: "")
        barTitleL.text = NSLocalizedString("Transfer Result Bar Title", comment: "")
        storeTitleL.text = NSLocalizedString("Transfer Result Store Title", comment: "")
        goMapL.text = NSLocalizedString("Transfer Result Go Map Title", comment: "")
        goPayL.text = NSLocalizedString("Transfer Result Pay Title", comment: "")
        
        payV.isHidden = true
        teachView.isHidden = true
        goPayBtn.layer.cornerRadius = goPayBtn.frame.size.height/2
        
        goMapBtn.layer.cornerRadius = goMapBtn.frame.size.height/2
        goMapBtn.layer.borderColor = Color_Main_Red.cgColor
        goMapBtn.layer.borderWidth = 0.5
        
        self.downIconIgV.image = nil
        
        self.downNameL.text = ""
        self.downIDL.text = ""
        self.downValueL.text = ""
        self.downNoteL.text = ""
        
        self.barNumberV.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate.shared().hideTopButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            return
        }
        
        loadOnce = true
        getOrderDetail()
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
