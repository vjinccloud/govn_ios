//
//  RegisterIntroVC.swift
//  indogo
//
//  Created by mac on 2020/7/20.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class RegisterIntroVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var topTitleL: UILabel!
    @IBOutlet weak var topL: UILabel!
    @IBOutlet weak var bottomL: UILabel!
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterInputVC") as? RegisterInputVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        AppDelegate.shared().hideTopButton()
        backL.text = NSLocalizedString("back", comment: "")
        nextBtn.setTitle(NSLocalizedString("start", comment: ""), for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.height/2
        topTitleL.text = NSLocalizedString("Register Intro Top Title", comment: "")
        topL.text = NSLocalizedString("Register Intro Top", comment: "")
        bottomL.text = NSLocalizedString("Register Intro Bottom", comment: "")
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
