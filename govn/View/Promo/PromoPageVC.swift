//
//  PromoPageVC.swift
//  indogo
//
//  Created by mac on 2020/7/11.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Kingfisher
import KingfisherWebP
import Alamofire

class PromoPageVC: UIViewController {

    @IBOutlet weak var unitImv: UIImageView!
    var promoUrl:String = ""
    
    @IBOutlet weak var endBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setImage() {
        unitImv.contentMode = .scaleAspectFit
        unitImv.clipsToBounds = true
        let imgurl = ServerURL + promoUrl
        Dlog("imgurl = --\(unitImv.frame)--")
        let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        unitImv.kf.indicatorType = .activity
        //unitImv.kf.setImage(with: urlhaed)
        unitImv.kf.setImage(with: urlhaed, options: [.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)])
        
        //unitImv.image = UIImage.init(named: "id_back.png")
        endBtn.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
