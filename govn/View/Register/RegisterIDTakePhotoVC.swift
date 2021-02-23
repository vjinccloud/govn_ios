//
//  RegisterIDTakePhotoVC.swift
//  indogo
//
//  Created by mac on 2020/8/3.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class RegisterIDTakePhotoVC: UIViewController {
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var firstPhotoTitleL: UILabel!
    @IBOutlet weak var secPhotoTitleL: UILabel!
    
    @IBOutlet weak var firstImgV: UIImageView!
    @IBOutlet weak var secImgV: UIImageView!
    
    var firstHasTaked = false
    var secHasTaked = false
    
    var frontImage:UIImage!
    var backImage:UIImage!
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secView: UIView!
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        AppDelegate.shared().tempRegisterObj.frontImg = frontImage
        AppDelegate.shared().tempRegisterObj.backImg = backImage
        
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDSignVC") as? RegisterIDSignVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func takeFirstPhoto(_ sender: Any) {
        var storyboardId = "RegisterIDTakeIntroVC"
        if AppDelegate.shared().deviceSmall {
            storyboardId = "RegisterIDTakeIntroVCSmall"
        }
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as? RegisterIDTakeIntroVC
        nextVC?.takePhotoType = PhotoIDType.front
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func takeSecPhoto(_ sender: Any) {
        var storyboardId = "RegisterIDTakeIntroVC"
        if AppDelegate.shared().deviceSmall {
            storyboardId = "RegisterIDTakeIntroVCSmall"
        }
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as? RegisterIDTakeIntroVC
        nextVC?.takePhotoType = PhotoIDType.back
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - Utility
    func setTakedPic(Type type:PhotoIDType, Img img:UIImage) {
        if type == PhotoIDType.front {
            frontImage = img
            firstImgV.image = img
            firstHasTaked = true
        } else if type == PhotoIDType.back {
            backImage = img
            secImgV.image = img
            secHasTaked = true
        }
        
        checkNextBtnState()
    }
    
    func checkNextBtnState() {
        var pass = true
        
        if !firstHasTaked || !secHasTaked {
            pass = false
        }
        
        
        if pass {
            nextBtn.backgroundColor = Color_Main_Red
            nextBtn.isEnabled = true
        } else {
            nextBtn.backgroundColor = .clear
            nextBtn.isEnabled = false
        }
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("back", comment: "")
        backL.adjustsFontSizeToFitWidth = true
        
        nextBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.layer.backgroundColor = Color_Main_Red.cgColor
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.layer.borderWidth = 0.5
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        
        firstPhotoTitleL.text = NSLocalizedString("Register ID Photo First", comment: "")
        secPhotoTitleL.text = NSLocalizedString("Register ID Photo Sec", comment: "")
        
        firstView.layer.borderWidth = 0.5
        firstView.layer.borderColor = UIColor.white.cgColor
        firstView.layer.cornerRadius = 5
        firstView.clipsToBounds = true
        
        secView.layer.borderWidth = 0.5
        secView.layer.borderColor = UIColor.white.cgColor
        secView.layer.cornerRadius = 5
        secView.clipsToBounds = true
        
        checkNextBtnState()
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
