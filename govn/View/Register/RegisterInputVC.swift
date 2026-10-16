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
    
    @IBOutlet weak var birthView: UIView!
    @IBOutlet weak var birthBtn: UIButton!
    @IBOutlet weak var birthTextfield: UITextField!
    
    @IBOutlet weak var expiredTextfield: UITextField!
    
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
    
    @IBOutlet weak var expiredBackV: UIView!
    @IBOutlet weak var arcBackV: UIView!
    @IBOutlet weak var expiredView: UIView!
    //ARC 發證日期（compliance-202610）
    @IBOutlet weak var issueBackV: UIView!
    @IBOutlet weak var issueView: UIView!
    @IBOutlet weak var issueTextfield: UITextField!
    @IBOutlet weak var issueIntroL: UILabel!
    @IBOutlet weak var issuePlaceholderL: UILabel!
    var birthDatePicker:UIDatePicker!
    var expiredDatePicker:UIDatePicker!
    var issueDatePicker:UIDatePicker!
    var nowTextIdx = 0
    
    var hasSharedCode = false
    var hasMeCode = false
    var meImg:UIImage!
    
    var birthDate:Date = Date()
    var expiredDate:Date = Date()
    var issueDate:Date = Date()
    
    @IBOutlet weak var expiredIntroL: UILabel!
    @IBOutlet weak var expiredPlaceholderL: UILabel!
    
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
        AppDelegate.shared().tempRegisterObj.phoneNum = "09\(phoneTextfield.text!)"
        AppDelegate.shared().tempRegisterObj.passwaord = passTextField.text
        AppDelegate.shared().tempRegisterObj.arcNum = arcCodeL.text
        if hasSharedCode {
            AppDelegate.shared().tempRegisterObj.shareCode =  arcTextfield.text!
        } else {
            AppDelegate.shared().tempRegisterObj.shareCode = ""
        }
        AppDelegate.shared().tempRegisterObj.birthday = birthTextfield.text!
        AppDelegate.shared().tempRegisterObj.arcDay = expiredTextfield.text!
        AppDelegate.shared().tempRegisterObj.arcIssueDay = issueTextfield.text!
        
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
            showPassBtn.setBackgroundImage(UIImage.init(named: "noview_w"), for: .normal)
        } else {
            showPassBtn.setBackgroundImage(UIImage.init(named: "view_w"), for: .normal)
        }
    }
    
    @IBAction func showRePassAction(_ sender: Any) {
        rePassTextField.isSecureTextEntry.toggle()
        
        if rePassTextField.isSecureTextEntry {
            showRePassBtn.setBackgroundImage(UIImage.init(named: "noview_w"), for: .normal)
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
            birthTextfield.becomeFirstResponder()
        } else if birthTextfield.isFirstResponder {
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
            birthTextfield.becomeFirstResponder()
        } else if textField == birthTextfield {
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
        } else if textField == birthTextfield {
            nowTextIdx = 0
            topScrollView.contentOffset = CGPoint.init(x: 0, y: birthView.frame.origin.y)
            birthBtn.backgroundColor = Color_Main_LightGray
            birthTextfield.textColor = .black
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
        } else if textField == expiredTextfield {
            nowTextIdx = 1
            topScrollView.contentOffset = CGPoint.init(x: 0, y: expiredView.frame.origin.y)
        } else if textField == issueTextfield {
            nowTextIdx = 2
            //issueView 包在容器裡，frame 是相對座標，要換算成捲動區座標，讓欄位停在日期選擇器上方
            let fieldY = issueView.convert(CGPoint.zero, to: topScrollView).y
            let maxOffsetY = max(0, topScrollView.contentSize.height - topScrollView.bounds.size.height + 300)
            topScrollView.contentOffset = CGPoint.init(x: 0, y: min(max(0, fieldY - 200), maxOffsetY))
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
        } else if textField == birthTextfield {
            if textField.text!.count == 0 {
                birthBtn.backgroundColor = Color_Main_DarkGray
                birthTextfield.textColor = .white
            } else {
                birthBtn.backgroundColor = Color_Main_LightGray
                birthTextfield.textColor = .black
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
    
    //MARK: - Date Picker
    func addDatePicker() {
        
        let dateNow = Date()
        
        if true {
            let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
            datePicker.datePickerMode = .date
            
            //datePicker.locale = NSLocale(localeIdentifier: "zh_TW") as Locale
            datePicker.date = dateNow
            datePicker.maximumDate = dateNow
            birthTextfield.inputView = datePicker
            let doneButton = UIBarButtonItem.init(title: "Xác nhận", style: .done, target: self, action: #selector(self.datePickerDone))
            let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
            birthTextfield.inputAccessoryView = toolBar
            birthDatePicker = datePicker
            if #available(iOS 14, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
        }
        
        if true {
            let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
            datePicker.datePickerMode = .date
            
            //datePicker.locale = NSLocale(localeIdentifier: "zh_TW") as Locale
            datePicker.date = dateNow
            datePicker.minimumDate = dateNow
            expiredTextfield.inputView = datePicker
            let doneButton = UIBarButtonItem.init(title: "Xác nhận", style: .done, target: self, action: #selector(self.datePickerDone))
            let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
            expiredTextfield.inputAccessoryView = toolBar
            expiredDatePicker = datePicker
            if #available(iOS 14, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
        }
        
        //ARC 發證日期：不可晚於今天
        if true {
            let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
            datePicker.datePickerMode = .date
            
            datePicker.date = dateNow
            datePicker.maximumDate = dateNow
            issueTextfield.inputView = datePicker
            let doneButton = UIBarButtonItem.init(title: "Xác nhận", style: .done, target: self, action: #selector(self.datePickerDone))
            let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
            issueTextfield.inputAccessoryView = toolBar
            issueDatePicker = datePicker
            if #available(iOS 14, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
        }
        
    }
    
    @objc func datePickerDone() {
        birthTextfield.resignFirstResponder()
        expiredTextfield.resignFirstResponder()
        issueTextfield.resignFirstResponder()
        
        if nowTextIdx == 0 {
            let date = birthDatePicker.date
            birthDate = date
            birthTextfield.text = date.toString()
        } else if nowTextIdx == 1 {
            let date = expiredDatePicker.date
            expiredPlaceholderL.isHidden = true
            expiredDate = date
            expiredTextfield.text = date.toString()
        } else if nowTextIdx == 2 {
            let date = issueDatePicker.date
            issuePlaceholderL.isHidden = true
            issueDate = date
            issueTextfield.text = date.toString()
        }
        checkNextBtnState(CheckText: true)
    }
    
    //MARK: - Utility
    func checkTextFormat() -> Bool {
        
        if accountTextfield.text?.count == 0 || phoneTextfield.text?.count == 0 || passTextField.text?.count == 0 || rePassTextField.text?.count == 0 || arcCodeL.text?.count == 0 {
            errorL.text = NSLocalizedString("Register Error Empty", comment: "")
            errorView.isHidden = false
            return false
        }
        
        //Tel
        var pass = true
        
        if phoneTextfield.text?.count != 8 {
            pass = false
        }
        
        if !pass {
            if phoneTextfield.text?.count != 8 {
                errorL.text = NSLocalizedString("Wrong Phone Format", comment: "")
            } else {
                errorL.text = NSLocalizedString("Register Error Tel", comment: "")
            }
            
            errorView.isHidden = false
            return false
        }
        
        //名字限填英文
        pass = true
        let words = accountTextfield.text
        let pred = NSPredicate(format:"SELF MATCHES %@", "[A-Za-z ]+")
        pass = pred.evaluate(with: words)
        
        if !pass {
            errorL.text = NSLocalizedString("Enter Error Only English", comment: "")
            errorView.isHidden = false
            
            return false
        }
        
        //ARC
        pass = true
        let text = arcCodeL.text!
        
        if text.count != 10 {
            return false
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
        
        //ARC 發證日期：必填、不可晚於今天、不可晚於到期日（格式皆為 yyyy-MM-dd，可直接比字串）
        let issueStr = issueTextfield.text ?? ""
        if issueStr.count == 0 {
            errorL.text = NSLocalizedString("Register Error Issue Date Empty", comment: "")
            errorView.isHidden = false
            return false
        }
        
        if issueStr > Date().toString() {
            errorL.text = NSLocalizedString("Register Error Issue Date Future", comment: "")
            errorView.isHidden = false
            return false
        }
        
        let expiredStr = expiredTextfield.text ?? ""
        if expiredStr.count > 0, issueStr > expiredStr {
            errorL.text = NSLocalizedString("Register Error Issue Date After Expired", comment: "")
            errorView.isHidden = false
            return false
        }
        
        errorView.isHidden = true
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else{
            return true
        }
        
        let textLength = text.count + string.count - range.length
        if textField == phoneTextfield, textLength>8 {
            return false
        }
        
        return true
    }
    
    func checkNextBtnState(CheckText checkNow:Bool) {
        var pass = true
        
        if birthTextfield.text!.count == 0 {
            //birthBtn.backgroundColor = Color_Main_DarkGray
            //birthTextfield.textColor = .white
        } else {
            birthBtn.backgroundColor = Color_Main_LightGray
            birthTextfield.textColor = .black
        }
        
        if accountTextfield.text?.count == 0 || birthTextfield.text?.count == 0 || expiredTextfield.text?.count == 0 || issueTextfield.text?.count == 0 || phoneTextfield.text?.count == 0 || passTextField.text?.count == 0 || rePassTextField.text?.count == 0 || arcCodeL.text?.count == 0 {
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
        arcCodeL.text = code.uppercased()
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
        arcBackV.layer.cornerRadius = 12
        arcBackV.layer.borderColor = Color_Main_LightGray.cgColor
        arcBackV.layer.borderWidth = 0.5
        expiredBackV.layer.cornerRadius = 12
        expiredBackV.layer.borderColor = UIColor.yellow.cgColor
        expiredBackV.layer.borderWidth = 1
        issueBackV.layer.cornerRadius = 12
        issueBackV.layer.borderColor = UIColor.yellow.cgColor
        issueBackV.layer.borderWidth = 1
        
        backL.text = NSLocalizedString("back", comment: "")
        accountBtn.layer.cornerRadius = accountBtn.frame.size.height/2
        birthBtn.layer.cornerRadius = birthBtn.frame.size.height/2
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
        
        accountBtn.layer.borderWidth = 0.5
        birthBtn.layer.borderWidth = 0.5
        phoneBtn.layer.borderWidth = 0.5
        passBtn.layer.borderWidth = 0.5
        rePassBtn.layer.borderWidth = 0.5
        
        accountBtn.layer.borderColor = Color_Main_LightGray.cgColor
        birthBtn.layer.borderColor = Color_Main_LightGray.cgColor
        phoneBtn.layer.borderColor = Color_Main_LightGray.cgColor
        passBtn.layer.borderColor = Color_Main_LightGray.cgColor
        rePassBtn.layer.borderColor = Color_Main_LightGray.cgColor
        
        accountTextfield.keyboardType = .asciiCapable
        passTextField.keyboardType = .asciiCapable
        rePassTextField.keyboardType = .asciiCapable
        arcTextfield.autocapitalizationType = .allCharacters
        accountTextfield.delegate = self
        birthTextfield.delegate = self
        phoneTextfield.delegate = self
        passTextField.delegate = self
        rePassTextField.delegate = self
        arcTextfield.isEnabled = false
        expiredTextfield.delegate = self
        issueTextfield.delegate = self
        
        birthTextfield.inputAccessoryView = generateToolBar()
        expiredTextfield.inputAccessoryView = generateToolBar()
        
        expiredIntroL.text = NSLocalizedString("Register Expired Title", comment: "")
        expiredPlaceholderL.text = NSLocalizedString("Register Expired Date", comment: "")
        issueIntroL.text = NSLocalizedString("Register Issue Date Title", comment: "")
        //標籤置中偏左 80，可用寬度約 98pt；英文「ARC ISSUE DATE」較長，超出外框時縮小字級
        var issueFontSize:CGFloat = 15
        while issueFontSize > 10, (issueIntroL.text! as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: issueFontSize)]).width > 98 {
            issueFontSize -= 0.5
        }
        issueIntroL.font = UIFont.systemFont(ofSize: issueFontSize)
        issuePlaceholderL.text = NSLocalizedString("Register Expired Date", comment: "")
        
        accountTextfield.inputAccessoryView = generateToolBar()
        phoneTextfield.inputAccessoryView = generateToolBar()
        passTextField.inputAccessoryView = generateToolBar()
        rePassTextField.inputAccessoryView = generateToolBar()
        
        errorView.isHidden = true
        
        accountTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register Input Name", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        birthTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register Btn Birth", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
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
        //self.simulatorNextAction()
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
        birthBtn.backgroundColor = .clear
        birthTextfield.textColor = .white
        addDatePicker()
    }
    
    func setArcText(Text text:String) {
        if text.count>0 {
            hasSharedCode = true
        }
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
        setArcCodeString(Code: "XD00000092") //XX00000037
        
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
