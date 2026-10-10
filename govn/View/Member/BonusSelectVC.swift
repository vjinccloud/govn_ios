//
//  BonusSelectVC.swift
//  govn
//
//  Created by Wang Jen Chung on 2026/5/4.
//  Copyright © 2026 DIM. All rights reserved.
//

import UIKit

class BonusSelectVC: UIViewController {
    
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var barV: UIView!
    
    var loadOnce = false
    var backTitle = ""
    var urlStr = ""
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func upAction(_ sender: Any) {
        let urlPath = "https://bonus.indogo.com.tw/bonusGoVN?arc=\(AppDelegate.shared().getRemeberedAccount())&pass=\(String(describing: AppDelegate.shared().getRemeberedAccount().base64EncodedString()!))"
        Dlog("url = \(urlPath)")
        //UIApplication.shared.open(URL.init(string: urlPath.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!)!, options: [:], completionHandler: nil)
        
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "PureWebVC") as? PureWebVC
        nextVC?.setTitleAndCallURL(URL: urlPath, Title: "")
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func downAction(_ sender: Any) {
        let urlPath = "https://invoice.indogo.com.tw/alistGoVN?arc=\(AppDelegate.shared().getRemeberedAccount())&pass=\(String(describing: AppDelegate.shared().getRemeberedAccount().base64EncodedString()!))"
        Dlog("url = \(urlPath)")
        //UIApplication.shared.open(URL.init(string: urlPath.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!)!, options: [:], completionHandler: nil)
        
        //return
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "PureWebVC") as? PureWebVC
        nextVC?.setTitleAndCallURL(URL: urlPath, Title: "")
        self.navigationController?.pushViewController(nextVC!, animated: true)
         
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backL.text = "Hoá đơn / Quà may mắn"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if loadOnce {
            return
        }
        
        loadOnce = true
    }
}

