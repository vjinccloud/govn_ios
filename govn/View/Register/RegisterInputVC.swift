//
//  RegisterInputVC.swift
//  indogo
//
//  Created by mac on 2020/7/21.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegisterInputVC: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, CustomAlertDelegate {

    @IBOutlet weak var inputMoreSpaceView: UIView!
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var camBtn: UIButton!
    
    @IBOutlet weak var topScrollView: UIScrollView!
    
    @IBOutlet weak var nameL: UILabel!
    
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var accountBtn: UIButton!
    @IBOutlet weak var accountTextfield: UITextField!
    
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var phoneTextfield: UITextField!
    
    @IBOutlet weak var passView: UIView!
    @IBOutlet weak var passBtn: UIButton!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var showPassBtn: UIButton!
    
    @IBOutlet weak var rePassView: UIView!
    @IBOutlet weak var rePassBtn: UIButton!
    @IBOutlet weak var rePassTextField: UITextField!
    @IBOutlet weak var showRePassBtn: UIButton!
    
    @IBOutlet weak var noArcView: UIView!
    @IBOutlet weak var hasArcView: UIView!
    
    @IBOutlet weak var inputArcView: UIView!
    @IBOutlet weak var arcTextfield: UITextField!
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var arcCodeL: UILabel!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorL: UILabel!
    
    @IBOutlet weak var scanARC: UILabel!
    
    var hasSharedCode = false
    var hasMeCode = false
    var meImg:UIImage!
    
    //MARK: - Button-Action
    @IBAction func shareCodeInputAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterShareInputVC") as? RegisterShareInputVC
        nextVC?.parentVC = self
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        
        AppDelegate.shared().tempRegisterObj = RegisterDataObj()
        //AppDelegate.shared().tempRegisterObj.meImg = meImg
        AppDelegate.shared().tempRegisterObj.account = accountTextfield.text
        AppDelegate.shared().tempRegisterObj.phoneNum = phoneTextfield.text
        AppDelegate.shared().tempRegisterObj.passwaord = passTextField.text
        AppDelegate.shared().tempRegisterObj.arcNum = arcCodeL.text
        if hasSharedCode {
            AppDelegate.shared().tempRegisterObj.shareCode =  arcTextfield.text!
        } else {
            AppDelegate.shared().tempRegisterObj.shareCode = ""
        }
        
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDTakePhotoVC") as? RegisterIDTakePhotoVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
    }
    
    @IBAction func callScanArcActon(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassIntroVC") as? ForgotPassIntroVC
        nextVC!.fromType = .register
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func callCamActon(_ sender: Any) {
        let customAlert = CustomAlertView.init(frame: topScrollView.frame)
        customAlert.initTwoActionAlert(Title: NSLocalizedString("Register Input Foto Select Title" , comment: ""), Content: "", NextBtn1Str: NSLocalizedString("Register Input Foto Select Camera" , comment: ""), NextBtn2Str: NSLocalizedString("Register Input Foto Select Gallery" , comment: ""), CancelBtn1Str: NSLocalizedString("cancel" , comment: ""))
        self.view.addSubview(customAlert)
        customAlert.customDelegate = self
    }
    
    func customAlertnextAction(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        ImagePicker.GetCameraStatus(view: self,completion: { (scuess)->Void in
            if(scuess){
                //拍照
                DispatchQueue.main.async{
                    let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterSelfPhotoVC") as? RegisterSelfPhotoVC
                    nextVC?.takePhotoType = .normal
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
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showPassAction(_ sender: Any) {
        passTextField.isSecureTextEntry.toggle()
        
        if passTextField.isSecureTextEntry {
            showPassBtn.setBackgroundImage(UIImage.init(named: "noview_b"), for: .normal)
        } else {
            showPassBtn.setBackgroundImage(UIImage.init(named: "view_w"), for: .normal)
        }
    }
    
    @IBAction func showRePassAction(_ sender: Any) {
        rePassTextField.isSecureTextEntry.toggle()
        
        if rePassTextField.isSecureTextEntry {
            showRePassBtn.setBackgroundImage(UIImage.init(named: "noview_b"), for: .normal)
        } else {
            showRePassBtn.setBackgroundImage(UIImage.init(named: "view_w"), for: .normal)
        }
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
            
            self.setImage(Image: UIImage.init(data: data)!)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        picker.dismiss(animated: true, completion: nil) // 退出相機介面
    }
    
    //MARK: - Text Bar
    func generateToolBar() ->UIToolbar {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextBarAction))
        
        let toolBar:UIToolbar = UIToolbar()
        toolBar.items = [flexibleSpace,done]
        toolBar.sizeToFit()
        
        return toolBar
    }
    
    @objc func nextBarAction() {
        if accountTextfield.isFirstResponder {
            phoneTextfield.becomeFirstResponder()
        } else if phoneTextfield.isFirstResponder {
            passTextField.becomeFirstResponder()
        } else if passTextField.isFirstResponder {
            rePassTextField.becomeFirstResponder()
        } else if rePassTextField.isFirstResponder {
            rePassTextField.resignFirstResponder()
        }
    }
    
    //MARK: - Text Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == accountTextfield {
            phoneTextfield.becomeFirstResponder()
        } else if textField == phoneTextfield {
            passTextField.becomeFirstResponder()
        } else if textField == passTextField {
            rePassTextField.becomeFirstResponder()
        } else if textField == rePassTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        inputMoreSpaceView.isHidden = false
        if textField == accountTextfield {
            topScrollView.contentOffset = CGPoint.init(x: 0, y: accountView.frame.origin.y)
            accountBtn.backgroundColor = Color_Main_LightGray
            accountTextfield.textColor = .black
        } else if textField == phoneTextfield {
            topScrollView.contentOffset = CGPoint.init(x: 0, y: phoneView.frame.origin.y)
            phoneBtn.backgroundColor = Color_Main_LightGray
            phoneTextfield.textColor = .black
        } else if textField == passTextField {
            topScrollView.contentOffset = CGPoint.init(x: 0, y: passView.frame.origin.y)
            passBtn.backgroundColor = Color_Main_LightGray
            passTextField.textColor = .black
        } else if textField == rePassTextField {
            topScrollView.contentOffset = CGPoint.init(x: 0, y: rePassView.frame.origin.y)
            rePassBtn.backgroundColor = Color_Main_LightGray
            rePassTextField.textColor = .black
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputMoreSpaceView.isHidden = true
        
        if textField == accountTextfield {
            if textField.text!.count == 0 {
                accountBtn.backgroundColor = Color_Main_DarkGray
                accountTextfield.textColor = .white
            } else {
                accountBtn.backgroundColor = Color_Main_LightGray
                accountTextfield.textColor = .black
            }
        } else if textField == phoneTextfield {
            if textField.text!.count == 0 {
                phoneBtn.backgroundColor = Color_Main_DarkGray
                phoneTextfield.textColor = .white
            } else {
                phoneBtn.backgroundColor = Color_Main_LightGray
                phoneTextfield.textColor = .black
            }
        } else if textField == passTextField {
            if textField.text!.count == 0 {
                passBtn.backgroundColor = Color_Main_DarkGray
                passTextField.textColor = .white
            } else {
                passBtn.backgroundColor = Color_Main_LightGray
                passTextField.textColor = .black
            }
        } else if textField == rePassTextField {
            if textField.text!.count == 0 {
                rePassBtn.backgroundColor = Color_Main_DarkGray
                rePassTextField.textColor = .white
            } else {
                rePassBtn.backgroundColor = Color_Main_LightGray
                rePassTextField.textColor = .black
            }
        }
        
        checkNextBtnState(CheckText: true)
    }
    
    /*
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if !accountTextfield.isFirstResponder, !phoneTextfield.isFirstResponder, !passTextField.isFirstResponder, !rePassTextField.isFirstResponder, !arcTextfield.isFirstResponder {
            topScrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
        return true
    }*/
    //MARK: - Utility
    func checkTextFormat() -> Bool {
        
        if accountTextfield.text?.count == 0 || phoneTextfield.text?.count == 0 || passTextField.text?.count == 0 || rePassTextField.text?.count == 0 || arcCodeL.text?.count == 0 {
            errorL.text = NSLocalizedString("Register Error Empty", comment: "")
            errorView.isHidden = false
            return false
        }
        
        //Tel
        var pass = true
        if !(phoneTextfield.text?.hasPrefix("09"))! {
            pass = false
        }
        
        if phoneTextfield.text?.count != 10 {
            pass = false
        }
        
        if !pass {
            errorL.text = NSLocalizedString("Register Error Tel", comment: "")
            errorView.isHidden = false
            return false
        }
        
        //名字限填英文
        pass = true
        let words = accountTextfield.text
        let pred = NSPredicate(format:"SELF MATCHES %@", "[A-Za-z ]+")
        pass = pred.evaluate(with: words)
        
        if !pass {
            errorL.text = NSLocalizedString("Register Name ARC", comment: "")
            errorView.isHidden = false
            
            return false
        }
        
        //ARC
        pass = true
        let text = arcCodeL.text!
        
        if text.count != 10 {
            pass = false
        }
        
        let singleWord = text.getSubString(Start: 1, EndNotInclude: 2).lowercased()
        Dlog("singleWord = \(singleWord)")
        if singleWord == "c" || singleWord == "d" || singleWord == "8" || singleWord == "9" {
            pass = true
        } else {
            pass = false
        }
        
        if pass {
            let range = NSRange(location: 0, length: 1)
            let regex = try! NSRegularExpression(pattern: "[A-Z]")
            pass = regex.firstMatch(in: text, options: [], range: range) != nil
        }
        
        if pass {
            let words = text.getSubString(Start: 2, EndNotInclude: 10)
            Dlog("words = \(words)")
            let pred = NSPredicate(format:"SELF MATCHES %@", "^[0-9]\\d*$")
            pass = pred.evaluate(with: words)
        }
        
        if !pass {
            errorL.text = NSLocalizedString("Register Error ARC", comment: "")
            errorView.isHidden = false
            
            return false
        }
        
        //密碼
        pass = true
        if passTextField.text!.count < 4 {
            pass = false
        }
        
        if !pass {
            errorL.text = NSLocalizedString("Register Error Pass", comment: "")
            errorView.isHidden = false
            return false
        }
        
        pass = true
        
        if passTextField.text != rePassTextField.text {
            pass = false
        }
        
        if !pass {
            errorL.text = NSLocalizedString("Register Error Pass Not match", comment: "")
            errorView.isHidden = false
            return false
        }
        
        errorView.isHidden = true
        return true
    }
    
    func checkNextBtnState(CheckText checkNow:Bool) {
        var pass = true
        
        if accountTextfield.text?.count == 0 || phoneTextfield.text?.count == 0 || passTextField.text?.count == 0 || rePassTextField.text?.count == 0 || arcCodeL.text?.count == 0 {
            pass = false
        } else if passTextField.text != rePassTextField.text {
            pass = false
        } /*else if !hasMeCode {
            pass = false
        }*/
        
        if checkNow {
            let passText = checkTextFormat()
            if !passText {
                pass = false
            }
        }
        
        if pass {
            registerBtn.backgroundColor = Color_Main_Red
            registerBtn.isEnabled = true
        } else {
            registerBtn.backgroundColor = .clear
            registerBtn.isEnabled = false
        }
    }
    
    public func setArcCodeString(Code code:String) {
        noArcView.isHidden = true
        hasArcView.isHidden = false
        arcCodeL.text = code
        checkNextBtnState(CheckText: true)
    }
    
    public func setImage(Image img:UIImage) {
        iconBtn.setImage(img, for: .normal)
        iconBtn.imageView?.contentMode = .scaleAspectFill
        iconBtn.layer.cornerRadius = iconBtn.frame.size.height/2
        iconBtn.clipsToBounds = true
        AppDelegate.shared().saveIconImageToFile(Image: img)
        meImg = img
        hasMeCode = true
        checkNextBtnState(CheckText: true)
    }
    
    public func setShareCode(Code code:String) {
        noArcView.isHidden = true
        hasArcView.isHidden = false
        arcTextfield.text = code
        hasSharedCode = true
        checkNextBtnState(CheckText: true)
    }
    
    public func showShareCodeInputview() {
        noArcView.isHidden = false
        hasArcView.isHidden = true
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        backL.text = NSLocalizedString("back", comment: "")
        accountBtn.layer.cornerRadius = accountBtn.frame.size.height/2
        phoneBtn.layer.cornerRadius = phoneBtn.frame.size.height/2
        passBtn.layer.cornerRadius = passBtn.frame.size.height/2
        rePassBtn.layer.cornerRadius = rePassBtn.frame.size.height/2
        registerBtn.layer.cornerRadius = registerBtn.frame.size.height/2
        
        passTextField.placeholder = NSLocalizedString("passcode", comment: "")
        rePassTextField.placeholder = NSLocalizedString("TFFRHP Change placehold2", comment: "")
        registerBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        
        passTextField.isSecureTextEntry = true
        rePassTextField.isSecureTextEntry = true
        
        accountTextfield.autocapitalizationType = .allCharacters
        
        //setShareCode(Code: "FD30471099")
        showShareCodeInputview()
        
        accountTextfield.keyboardType = .asciiCapable
        passTextField.keyboardType = .asciiCapable
        rePassTextField.keyboardType = .asciiCapable
        
        accountTextfield.delegate = self
        phoneTextfield.delegate = self
        passTextField.delegate = self
        rePassTextField.delegate = self
        arcTextfield.isEnabled = false
        
        accountTextfield.inputAccessoryView = generateToolBar()
        phoneTextfield.inputAccessoryView = generateToolBar()
        passTextField.inputAccessoryView = generateToolBar()
        rePassTextField.inputAccessoryView = generateToolBar()
        
        errorView.isHidden = true
        
        accountTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register Input Name", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        phoneTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register Input Phone", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        passTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register Input Pass", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        rePassTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register Input rePass", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        arcTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register Input ARC Placehold", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        registerBtn.layer.borderColor = Color_Main_Red.cgColor
        registerBtn.layer.borderWidth = 0.5
        arcTextfield.adjustsFontSizeToFitWidth = true
        
        //inputArcView.isHidden = true
        inputMoreSpaceView.isHidden = true
        nameL.text = NSLocalizedString("Register Input Foto", comment: "")
        scanARC.text = NSLocalizedString("Register Input Scan Label", comment: "")
        checkNextBtnState(CheckText: false)
        #if targetEnvironment(simulator)
        //模擬器直接秀下一步
        self.simulatorNextAction()
        #else
        //--should--
        if DevMode {
            //self.simulatorNextAction()
        }
        #endif
        
        if self.view.frame.size.width<380 {
            Dlog("special handling")
            arcTextfield.font = UIFont.systemFont(ofSize: 12)
        }
        
        if AppDelegate.shared().hasArcResultAndGotoRegister {
            setArcCodeString(Code: AppDelegate.shared().arcScanReulstForRegister)
        }
    }
    
    func setArcText(Text text:String) {
        arcTextfield.text = text
        arcTextfield.font = UIFont.systemFont(ofSize: 20)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //測試用(僅在模擬器發生)
    func simulatorNextAction() {
        accountTextfield.text = "ask"
        phoneTextfield.text = "0935499332"
        passTextField.text = "a12345"
        rePassTextField.text = "a12345"
        setArcCodeString(Code: "XC00000092") //XX00000037
        
        checkNextBtnState(CheckText: true)
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
