//
//  RegisterIDAndSelfPhotoStep2VC.swift
//  indogo
//
//  Created by mac on 2020/9/29.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class RegisterIDAndSelfPhotoStep2VC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var processImgV: UIImageView!
    @IBOutlet weak var scanViewWidthConstrain: NSLayoutConstraint!
    @IBOutlet weak var bottomL: UILabel!
    
    var tempImg:UIImage!
    var finalImg:UIImage!
    var loadOnce:Bool = false
    var angle:CGFloat = 0
    
    var takePhotoType:PhotoIDType = PhotoIDType.normal
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        guard let viewControllers = self.navigationController?.viewControllers else {
            return
        }

        for firstViewController in viewControllers {
            if takePhotoType == .normal {
                if firstViewController is RegisterInputVC {
                    let nextVC = firstViewController as! RegisterInputVC
                    nextVC.setImage(Image: finalImg)
                    self.navigationController?.popToViewController(nextVC, animated: true)
                    break
                }
            } else if takePhotoType == .normalFromEdit {
                if firstViewController is MemberEditVC {
                    let nextVC = firstViewController as! MemberEditVC
                    nextVC.setImage(Image: finalImg)
                    self.navigationController?.popToViewController(nextVC, animated: true)
                    break
                }
            } else if takePhotoType == .faceAndId {
                if firstViewController is RegisterIDSignVC {
                    let nextVC = firstViewController as! RegisterIDSignVC
                    nextVC.setTakedPic(Type: takePhotoType, Img: finalImg)
                    self.navigationController?.popToViewController(nextVC, animated: true)
                    break
                }
            } else if takePhotoType == .faceAndIdFromEdit {
                if firstViewController is MemberEditVC {
                    let nextVC = firstViewController as! MemberEditVC
                    nextVC.setTakedPic(Type: takePhotoType, Img: finalImg)
                    self.navigationController?.popToViewController(nextVC, animated: true)
                    break
                }
            }
            
        }
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("back", comment: "")
        bottomL.text = NSLocalizedString("bottom for forgoet sec", comment: "")
        nextBtn.setTitle(NSLocalizedString("Register Self Photo Confrim", comment: ""), for: .normal)
        cancelBtn.setTitle(NSLocalizedString("Register Self Photo Retake", comment: ""), for: .normal)
        
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.layer.backgroundColor = Color_Main_Red.cgColor
        
        cancelBtn.layer.cornerRadius = cancelBtn.frame.size.height/2
        cancelBtn.backgroundColor = .clear
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.layer.borderWidth = 0.5
        cancelBtn.layer.borderColor = Color_Main_Red.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if loadOnce {
            return
        }
        
        loadOnce = true
        finalImg = tempImg
        processImgV.image = finalImg
        processImgV.contentMode = .scaleAspectFit
        
        if self.view.frame.size.width<380 {
            Dlog("special handling")
            //scanViewWidthConstrain.constant = -40
        }
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
