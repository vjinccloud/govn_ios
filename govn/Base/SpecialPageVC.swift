//
//  SpecialPageVC.swift
//  govn
//
//  Created by Wang Jen Chung on 2023/1/9.
//  Copyright © 2023 DIM. All rights reserved.
//

import UIKit

class SpecialPageVC: UIViewController {
    
    @IBOutlet weak var backL: UILabel!
    var backTitle = ""
    var urlStr = ""
    @IBOutlet weak var barV: UIView!
    var loadOnce = false
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    public func setTitleAndCallURL(URL urlString:String, Title title:String) {
        backTitle = title
        urlStr = urlString
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let urlString:String = "https://www.foi.org.tw/Article.aspx?Lang=1&Arti=8452"
        let pasteboard = UIPasteboard.general
        pasteboard.string = urlString
        /*
        if let openURL = URL(string: urlString) {
            if (UIApplication.shared.canOpenURL(openURL)) {
                UIApplication.shared.open(openURL, options: [:], completionHandler: nil)
            }
        }*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nextBtn.setTitle(NSLocalizedString("Debate Page Btn", comment: ""), for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        backL.text = NSLocalizedString("Debate Page Title", comment: "")
        if loadOnce {
            return
        }
        
        loadOnce = true
        var startY:CGFloat = barV.frame.origin.y+barV.frame.height
        
        let scrollV = UIScrollView.init(frame: CGRect.init(x: 0, y: startY, width: self.view.frame.width, height: self.view.frame.height-startY-60))
        self.view.addSubview(scrollV)
        
        startY = 10
        let imgV = UIImageView.init(frame: CGRect.init(x: 10, y: startY, width: self.view.frame.width-20, height: self.view.frame.width-20))
        imgV.image = UIImage.init(named: "FOI_pic")
        scrollV.addSubview(imgV)
        
        startY += self.view.frame.width + 10
        
        let label = UILabel.init(frame: CGRect.init(x: 10, y: startY, width: self.view.frame.width-20, height: 0))
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = NSLocalizedString("Debate Page Content", comment: "")
        label.sizeToFit()
        scrollV.addSubview(label)
        
        startY += label.frame.height + 100
        
        scrollV.contentSize = CGSize.init(width: scrollV.frame.width, height: startY)
        
        //SALIN LINK
        self.view.bringSubviewToFront(nextBtn)
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
