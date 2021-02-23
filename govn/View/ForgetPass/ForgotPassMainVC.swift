//
//  ForgotPassMainVC.swift
//  indogo
//
//  Created by mac on 2020/7/15.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class ForgotPassMainVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var topL: UILabel!
    @IBOutlet weak var introL: UILabel!
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassIntroVC") as? ForgotPassIntroVC
        nextVC!.fromType = .forgotPass
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
        AppDelegate.shared().showTopButton()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("back", comment: "")
        topL.text = NSLocalizedString("top for forgoet main", comment: "")
        introL.text = NSLocalizedString("intro for forgoet main", comment: "")
        
        AppDelegate.shared().hideTopButton()
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
