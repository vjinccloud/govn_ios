//
//  PureWebVC.swift
//  indogo
//
//  Created by mac on 2020/8/11.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import WebKit

class PureWebVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var webView: WKWebView!
    var backTitle = ""
    var urlStr = ""
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    public func setTitleAndCallURL(URL urlString:String, Title title:String) {
        backTitle = title
        urlStr = urlString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        backL.text = backTitle
        let url = URL(string: urlStr)
        let request = URLRequest(url: url!)
        webView.load(request)
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
