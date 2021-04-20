//
//  ForgotPassIntroVC.swift
//  indogo
//
//  Created by mac on 2020/7/15.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class ForgotPassIntroVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var topL: UILabel!
    @IBOutlet weak var bottomL: UILabel!
    public var fromType:ScanParentType = ScanParentType.forgotPass
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassScanVC") as? ForgotPassScanVC
        nextVC!.fromType = fromType
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("back", comment: "")
        nextBtn.setTitle(NSLocalizedString("start scan", comment: ""), for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.height/2
        topL.text = NSLocalizedString("top for forgoet sec", comment: "")
        bottomL.text = NSLocalizedString("bottom for forgoet sec2", comment: "")
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
