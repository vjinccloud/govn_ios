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
        
        registerStep1()
    }
    
    //MARK: - API
    //註冊第一步：送文字資料（含 arc_issue_date），成功後進簡訊驗證頁
    func registerStep1() {
        let obj = AppDelegate.shared().tempRegisterObj
        let parameters:Parameters = ["name":obj.account!,
                                     "phone":obj.phoneNum!,
                                     "arc_no":obj.arcNum!,
                                     "password":UtilityTool().sha256(Code: obj.passwaord!),
                                     "share_member_id":obj.shareCode,
                                     "arc_expire_date":obj.arcDay,
                                     "arc_issue_date":obj.arcIssueDay,
                                     "birthday":obj.birthday]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_RegisterStep1;
        //不印參數，避免密碼雜湊出現在 log
        Dlog("todoEndpoint=\(todoEndpoint)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil, let data = response.data, let responseStr = String.init(data: data, encoding: String.Encoding.utf8) else {
                    print("error calling on \(todoEndpoint)")
                    AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                
                Dlog("responseStr = \(responseStr)")
                let result = APIHandle().getResponseState(ResponseStr: responseStr, APIStr: todoEndpoint, SubStr: "")
                
                if result == ResponseState.ok {
                    //簡訊頁顯示的手機號碼
                    AppDelegate.shared().forgotPassTempPhone = obj.phoneNum!
                    let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterEnterSMSCodeVC") as? RegisterEnterSMSCodeVC
                    self.navigationController?.pushViewController(nextVC!, animated: true)
                } else {
                    //6001 帳號不存在、6002 已註冊或使用中等，顯示後端訊息
                    var msg = AppDelegate.shared().apiBackContentStr
                    if msg == "" {
                        msg = NSLocalizedString("API Timeout", comment: "")
                    }
                    AppDelegate.shared().showAlertWithWindow(self, Message: msg)
                }
        }
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
        if textField == accountTextfield {
            accountBtn.backgroundColor = Color_Main_LightGray
            accountTextfield.textColor = .black
        } else if textField == birthTextfield {
            nowTextIdx = 0
            birthBtn.backgroundColor = Color_Main_LightGray
            birthTextfield.textColor = .black
        } else if textField == phoneTextfield {
            phoneBtn.backgroundColor = Color_Main_LightGray
            phoneTextfield.textColor = .black
        } else if textField == passTextField {
            passBtn.backgroundColor = Color_Main_LightGray
            passTextField.textColor = .black
        } else if textField == rePassTextField {
            rePassBtn.backgroundColor = Color_Main_LightGray
            rePassTextField.textColor = .black
        } else if textField == expiredTextfield {
            nowTextIdx = 1
        } else if textField == issueTextfield {
            nowTextIdx = 2
        }
        //鍵盤已經在畫面上（例如按 Next 換欄位、鍵盤高度沒變時系統不一定再發 keyboardWillShow），
        //這裡補一次「被蓋住才捲」的檢查；鍵盤還沒出現時由 keyboardWillShow 處理
        if let keyboardTop = keyboardTopInView {
            scrollFieldIntoViewIfCovered(textField, keyboardTopInView: keyboardTop, duration: 0.25)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
    
    //MARK: - Keyboard（需求 7：標準鍵盤避讓，不再把欄位捲到頂）
    ///鍵盤（含日期選擇器 inputView）頂端在 self.view 座標的 y；nil 表示鍵盤沒顯示
    var keyboardTopInView:CGFloat? = nil
    ///欄位下緣與鍵盤頂端至少留的距離
    let keyboardFieldGap:CGFloat = 12
    
    func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    ///目前是第一回應者的欄位
    func currentEditingTextField() -> UITextField? {
        let fields:[UITextField?] = [accountTextfield, birthTextfield, phoneTextfield, passTextField, rePassTextField, expiredTextfield, issueTextfield, arcTextfield]
        return fields.compactMap { $0 }.first { $0.isFirstResponder }
    }
    
    ///欄位所在的整列容器，捲動時以整列為準
    func containerView(for textField: UITextField) -> UIView {
        if textField == accountTextfield { return accountView }
        if textField == birthTextfield { return birthView }
        if textField == phoneTextfield { return phoneView }
        if textField == passTextField { return passView }
        if textField == rePassTextField { return rePassView }
        if textField == expiredTextfield { return expiredView }
        if textField == issueTextfield { return issueView }
        return textField
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo,
              let frameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.25
        //鍵盤 frame 是螢幕座標，換成 self.view 座標；高度用通知的值，日期選擇器 inputView 高度不同也適用
        let keyboardFrame = view.convert(frameValue.cgRectValue, from: nil)
        let scrollFrame = topScrollView.convert(topScrollView.bounds, to: view)
        //捲動區底部已由 safe area 自動加了 inset（adjustedContentInset），只補鍵盤多蓋住的部分
        let overlap = max(0, scrollFrame.maxY - keyboardFrame.minY - topScrollView.safeAreaInsets.bottom)
        keyboardTopInView = keyboardFrame.minY
        
        topScrollView.contentInset.bottom = overlap
        topScrollView.verticalScrollIndicatorInsets.bottom = overlap
        
        if let field = currentEditingTextField() {
            scrollFieldIntoViewIfCovered(field, keyboardTopInView: keyboardFrame.minY, duration: duration)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.25
        keyboardTopInView = nil
        //只把 inset 歸零，不捲回頂端；offset 超出範圍時交給 UIScrollView 自己夾回
        UIView.animate(withDuration: duration) {
            self.topScrollView.contentInset.bottom = 0
            self.topScrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
    
    ///只有欄位（整列）會被鍵盤蓋住時才用 scrollRectToVisible 捲最小幅度；沒被蓋住完全不捲
    func scrollFieldIntoViewIfCovered(_ textField: UITextField, keyboardTopInView keyboardTop: CGFloat, duration: TimeInterval) {
        let container = containerView(for: textField)
        let rectInView = container.convert(container.bounds, to: view)
        let scrollFrame = topScrollView.convert(topScrollView.bounds, to: view)
        let visibleBottom = min(scrollFrame.maxY, keyboardTop)
        //欄位下緣 + 間距 仍在鍵盤上方就不動；欄位上緣被捲動區頂端遮住也不處理（使用者自己捲上去的）
        guard rectInView.maxY + keyboardFieldGap > visibleBottom else { return }
        
        var rectInScroll = container.convert(container.bounds, to: topScrollView)
        rectInScroll.size.height += keyboardFieldGap
        topScrollView.layoutIfNeeded()
        UIView.animate(withDuration: duration) {
            self.topScrollView.scrollRectToVisible(rectInScroll, animated: false)
        }
    }
    
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
        
        //ARC 發證日期：最晚今天、最早往前 10 年（與 Android 一致，見規格決定紀錄 2026-10-16）
        if true {
            let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
            datePicker.datePickerMode = .date
            
            datePicker.date = dateNow
            datePicker.maximumDate = dateNow
            datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -10, to: dateNow)
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
        registerKeyboardObservers()
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
