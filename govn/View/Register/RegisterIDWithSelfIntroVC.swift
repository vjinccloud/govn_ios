//
//  RegisterIDWithSelfIntroVC.swift
//  indogo
//
//  Created by mac on 2020/8/5.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class RegisterIDWithSelfIntroVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, CustomAlertDelegate {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var bottomImgV: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bottomL: UILabel!
    
    var takePhotoType:PhotoIDType = PhotoIDType.faceAndId
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if takePhotoType == .faceAndId || takePhotoType == .faceAndIdFromEdit {
            
            let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterSelfPhotoVC") as? RegisterSelfPhotoVC
            nextVC?.takePhotoType = self.takePhotoType
            self.navigationController?.pushViewController(nextVC!, animated: true)
            
            /*
            let customAlert = CustomAlertView.init(frame: backView.frame)
            //customAlert.initTwoActionAlert(Title: NSLocalizedString("Register Input Foto Select Title" , comment: ""), Content: "", NextBtn1Str: NSLocalizedString("Register Input Foto Select Camera" , comment: ""), NextBtn2Str: NSLocalizedString("Register Input Foto Select Gallery" , comment: ""), CancelBtn1Str: NSLocalizedString("cancel" , comment: ""))
            customAlert.initAlert(Title: NSLocalizedString("Register Input Foto Select Title" , comment: ""), Content: "", NextBtn1Str: NSLocalizedString("Register Input Foto Select Camera" , comment: ""), CancelBtn1Str: NSLocalizedString("cancel" , comment: ""))
            self.view.addSubview(customAlert)
            customAlert.customDelegate = self*/
        }
    }
    
    func customAlertnextAction(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        ImagePicker.GetCameraStatus(view: self,completion: { (scuess)->Void in
            if(scuess){
                //拍照
                DispatchQueue.main.async{
                    let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterSelfPhotoVC") as? RegisterSelfPhotoVC
                    nextVC?.takePhotoType = self.takePhotoType
                    self.navigationController?.pushViewController(nextVC!, animated: true)
                }
            }
            else{
                print("無法使用相機")
            }
        })
    }
    
    func customAlertnextActionSecond(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        ImagePicker.GetPhotoStatus(view: self,completion: { (scuess)->Void in
            if(scuess){
                self.initPhotoPicker()
            }
            else{
                print("無法使用相簿")
            }
        })
    }
    
    //MARK: - Camera
    func initPhotoPicker(){
        DispatchQueue.main.async{
            let photoPicker =  UIImagePickerController()
            photoPicker.delegate = self
            photoPicker.allowsEditing = false
            photoPicker.sourceType = .photoLibrary
            //在需要的地方present出来
            self.present(photoPicker, animated: true, completion: nil)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //UIImagePickerControllerOriginalImage  原始圖像
        //UIImagePickerControllerEditedImage    編輯後的圖片(開啓編輯該對象才存在)
        
        self.dismiss(animated: true, completion: {
            var img:UIImage? = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            if picker.allowsEditing {
                img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            }
            
            let data = img!.ImgPress(LimitInBytes: ImageLimitInBytes)
            print("allcount = \(data.count)")
            //img!.jpegData(compressionQuality: 0.2)
            if(data.count>512000){
                AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("Photo too big", comment: ""))
                return
            }
            
            let image = UIImage.init(data: data)!
            
            let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterSelfPhotoStep2VC") as? RegisterSelfPhotoStep2VC
            nextVC?.tempImg = image
            nextVC?.takePhotoType = self.takePhotoType
            self.navigationController?.pushViewController(nextVC!, animated: true)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        picker.dismiss(animated: true, completion: nil) // 退出相機介面
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("Register ID Face And ID Intro2", comment: "")
        
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.setTitle(NSLocalizedString("Register ID Photo Intro", comment: ""), for: .normal)
        bottomL.text = NSLocalizedString("Selfie Face Reminder2", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if takePhotoType == PhotoIDType.faceAndId || takePhotoType == PhotoIDType.faceAndIdFromEdit {
            //bottomImgV.image = UIImage.init(named: "man_with_id_2.png")
            backL.text = NSLocalizedString("Register ID Photo Title Passport", comment: "")
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
