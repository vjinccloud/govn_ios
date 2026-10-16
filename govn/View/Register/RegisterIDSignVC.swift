//
//  RegisterIDSignVC.swift
//  indogo
//
//  Created by mac on 2020/8/4.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class RegisterIDSignVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var firstPhotoTitleL: UILabel!
    @IBOutlet weak var signTitleL: UILabel!
    
    @IBOutlet weak var signL: UILabel!
    @IBOutlet weak var firstImgV: UIImageView!
    @IBOutlet weak var signImgV: UIImageView!
    
    var firstHasTaked = false
    var secHasTaked = false
    var signHasTaked = false
    
    var frontImage:UIImage!
    var signImage:UIImage!
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var signView: UIView!
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        AppDelegate.shared().tempRegisterObj.faceImg = frontImage
        AppDelegate.shared().tempRegisterObj.passportImg = frontImage
        AppDelegate.shared().tempRegisterObj.signImg = signImage
        
        let obj = AppDelegate.shared().tempRegisterObj
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_Register;
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(obj.account!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "name")
            multipartFormData.append(obj.phoneNum!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "phone")
            multipartFormData.append(obj.arcNum!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "arc_no")
            multipartFormData.append(UtilityTool().sha256(Code: obj.passwaord!).data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "password")
            multipartFormData.append(obj.shareCode.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "share_member_id")
            
            multipartFormData.append(obj.arcDay.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "arc_expire_date")
            multipartFormData.append(obj.arcIssueDay.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "arc_issue_date")
            multipartFormData.append(obj.birthday.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "birthday")
            
            multipartFormData.append(obj.frontImg.ImgPress(LimitInBytes: ImageLimitInBytes), withName: "arc", fileName: "arc.jpg", mimeType: "image/jpg")
            multipartFormData.append(obj.backImg.ImgPress(LimitInBytes: ImageLimitInBytes), withName: "arc_back", fileName: "arc_back.jpg", mimeType: "image/jpg")
            multipartFormData.append(obj.signImg.ImgPress(LimitInBytes: ImageLimitInBytes), withName: "sign", fileName: "sign.jpg", mimeType: "image/jpg")
            multipartFormData.append(obj.faceImg.ImgPress(LimitInBytes: ImageLimitInBytes), withName: "address", fileName: "address.jpg", mimeType: "image/jpg")
            //multipartFormData.append(obj.passportImg.ImgPress(LimitInBytes: ImageLimitInBytes), withName: "id_card", fileName: "id_card.jpg", mimeType: "image/jpg")
            multipartFormData.append(obj.faceImg.ImgPress(LimitInBytes: ImageLimitInBytes), withName: "self", fileName: "self.jpg", mimeType: "image/jpg")
            
        }, usingThreshold: UInt64.init(), to: todoEndpoint, method: .post, headers: headers) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                upload.response { response in
                    
                    AppDelegate.shared().removeLoadingView()
                    AppDelegate.shared().forgotPassTempPhone = obj.phoneNum!
                    
                    guard response.error == nil else {
                        // got an error in getting the data, need to handle it
                        print("error calling on \(todoEndpoint), response = \(response)")
                        print(response.error!)
                        return
                    }
                    
                    //下一步，簡訊
                    let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                    Dlog("responseStr = \(responseStr ?? "")")
                    let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                    
                    if result == ResponseState.ok {
                        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterEnterSMSCodeVC") as? RegisterEnterSMSCodeVC
                        self.navigationController?.pushViewController(nextVC!, animated: true)
                    } else if result == ResponseState.failed {
                        AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
        
    }
    
    @IBAction func signAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterMakeSignVC") as? RegisterMakeSignVC
        nextVC?.takePhotoType = PhotoIDType.sign
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func takeFirstPhoto(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDWithSelfIntroVC") as? RegisterIDWithSelfIntroVC
        nextVC?.takePhotoType = .faceAndId
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func takeSecPhoto(_ sender: Any) {
        var storyboardId = "RegisterIDTakeIntroVC"
        if AppDelegate.shared().deviceSmall {
            storyboardId = "RegisterIDTakeIntroVCSmall"
        }
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as? RegisterIDTakeIntroVC
        nextVC?.takePhotoType = PhotoIDType.passport
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - Utility
    func setTakedPic(Type type:PhotoIDType, Img img:UIImage) {
        if type == PhotoIDType.faceAndId {
            frontImage = img
            firstImgV.image = img
            firstHasTaked = true
        } else if type == PhotoIDType.passport {
            secHasTaked = true
        } else if type == PhotoIDType.sign {
            signImage = img
            signImgV.image = UIImage.init(named: "note-2.png")
            signL.isHidden = false
            signHasTaked = true
        }
        
        checkNextBtnState()
    }
    
    func checkNextBtnState() {
        var pass = true
        
        if !firstHasTaked || !signHasTaked {
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
        
        nextBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.layer.backgroundColor = Color_Main_Red.cgColor
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.layer.borderWidth = 0.5
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        
        firstPhotoTitleL.text = NSLocalizedString("Register ID Self First", comment: "")
        signTitleL.text = NSLocalizedString("Register ID Self Sign", comment: "")
        
        firstView.layer.borderWidth = 0.5
        firstView.layer.borderColor = UIColor.white.cgColor
        firstView.layer.cornerRadius = 5
        firstView.clipsToBounds = true
        signL.text = NSLocalizedString("Register Sign Confirmed", comment: "")
        signL.isHidden = true
        signView.layer.borderWidth = 0.5
        signView.layer.borderColor = UIColor.white.cgColor
        signView.layer.cornerRadius = 5
        signView.clipsToBounds = true
        
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
