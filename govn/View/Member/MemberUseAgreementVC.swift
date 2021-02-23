//
//  MemberUseAgreementVC.swift
//  indogo
//
//  Created by mac on 2020/8/31.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class MemberUseAgreementVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var agreementBackV: UIView!
    @IBOutlet weak var webView: WKWebView!
    
    //MARK: - API
    public func getAgreement() {
        let parameters:Parameters = ["doc_name":"使用者條款"]
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
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "使用者條款")
                if result == ResponseState.ok {
                    self.webView.loadHTMLString(AppDelegate.shared().tempAgreementHtmlContent, baseURL: nil)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        AppDelegate.shared().showTopButton()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.shared().hideTopButton()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("Member Use Agreement Title", comment: "")
        agreementBackV.layer.cornerRadius = 20
        agreementBackV.clipsToBounds = true
        
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
