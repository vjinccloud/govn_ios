//
//  ArcScanWrong.swift
//  govn
//
//  Created by mac on 2020/11/23.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class ArcScanWrong: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var preBtn: UIButton!
    @IBOutlet weak var topL: UILabel!
    @IBOutlet weak var orL: UILabel!
    
    public var fromType:ScanParentType = ScanParentType.forgotPass
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func inputAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ARCInputVC") as? ARCInputVC
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
        nextBtn.setTitle(NSLocalizedString("re scan", comment: ""), for: .normal)
        preBtn.setTitle(NSLocalizedString("input arc number", comment: ""), for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.height/2
        preBtn.layer.cornerRadius = nextBtn.frame.height/2
        preBtn.layer.backgroundColor = UIColor.clear.cgColor
        preBtn.layer.borderWidth = 0.5
        preBtn.layer.borderColor = UIColor.white.cgColor
        topL.text = NSLocalizedString("scan failed", comment: "")
        orL.text = NSLocalizedString("or", comment: "")
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
