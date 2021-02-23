//
//  RegisterMakeSignVC.swift
//  indogo
//
//  Created by mac on 2020/8/5.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation
import SwiftSignatureView

class RegisterMakeSignVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var bottomL: UILabel!
    @IBOutlet weak var signView: SwiftSignatureView!
    
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var takePhotoType:PhotoIDType = PhotoIDType.sign
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        guard let viewControllers = self.navigationController?.viewControllers else {
            return
        }
        
        for firstViewController in viewControllers {
            if takePhotoType == .sign {
                if firstViewController is RegisterIDSignVC {
                    let nextVC = firstViewController as! RegisterIDSignVC
                    nextVC.setTakedPic(Type: takePhotoType, Img: signView.signature!)
                    self.navigationController?.popToViewController(nextVC, animated: true)
                    break
                }
            } else if takePhotoType == .signFromEdit {
                if firstViewController is MemberEditVC {
                    let nextVC = firstViewController as! MemberEditVC
                    nextVC.setTakedPic(Type: takePhotoType, Img: signView.signature!)
                    self.navigationController?.popToViewController(nextVC, animated: true)
                    break
                }
            }
            
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        signView.clear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("back", comment: "")
        bottomL.text = NSLocalizedString("bottom for sign sec", comment: "")
        signView.layer.cornerRadius = 10
        signView.clipsToBounds = true
        
        cancelBtn.layer.cornerRadius = cancelBtn.frame.size.height/2
        cancelBtn.backgroundColor = .clear
        cancelBtn.layer.borderColor = Color_Main_Red.cgColor
        cancelBtn.layer.borderWidth = 0.5
        confirmBtn.layer.cornerRadius = confirmBtn.frame.size.height/2
        
        cancelBtn.setTitle(NSLocalizedString("Register Sign Retake", comment: ""), for: .normal)
        confirmBtn.setTitle(NSLocalizedString("Register Sign Confrim", comment: ""), for: .normal)
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
