//
//  RegisterShareInputVC.swift
//  indogo
//
//  Created by mac on 2020/7/27.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation
import Alamofire

class RegisterShareInputVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var introL: UILabel!
    @IBOutlet weak var scanL: UILabel!
    @IBOutlet weak var msgL: UILabel!
    @IBOutlet weak var divL: UILabel!
    @IBOutlet weak var belowL: UILabel!
    @IBOutlet weak var downBtn: UIButton!
    @IBOutlet weak var textBgV: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var scanBgV: UIView!
    @IBOutlet weak var inputMoreSpaceView: UIView!
    @IBOutlet weak var textBackV: UIView!
    @IBOutlet weak var topScrollView: UIScrollView!
    
    var parentVC:RegisterInputVC!
    
    //MARK: - API
    func checkBtnState() {
        if inputTextField.text!.count>0 {
            scanBgV.alpha = 0.2
            textBgV.backgroundColor = Color_Main_LightGray
            inputTextField.textColor = .black
            downBtn.backgroundColor = Color_Main_Red
        } else {
            scanBgV.alpha = 1
            textBgV.backgroundColor = .clear
            inputTextField.textColor = .white
            downBtn.backgroundColor = .clear
        }
    }
    
    //MARK: - Button-Action
    public func setCodeString(Code code:String) {
        inputTextField.text = code
        checkBtnState()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterShareScanQRCodeVC") as? RegisterShareScanQRCodeVC
        nextVC?.parentVC = self
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func downAction(_ sender: Any) {
        if inputTextField.text == "" {
            return
        }
        parentVC.setArcText(Text:inputTextField.text!)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Text Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        topScrollView.contentOffset = CGPoint.init(x: 0, y: textBackV.frame.origin.y)
        inputMoreSpaceView.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputMoreSpaceView.isHidden = true
        checkBtnState()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        backL.text = NSLocalizedString("Register Share Input Title", comment: "")
        introL.text = NSLocalizedString("Register Share Input Top", comment: "")
        belowL.adjustsFontSizeToFitWidth = true
        downBtn.layer.cornerRadius = downBtn.frame.size.height/2
        
        scanL.text = NSLocalizedString("Register Share Input Scan", comment: "")
        scanL.adjustsFontSizeToFitWidth = true
        msgL.text = NSLocalizedString("Register Share Input Msg", comment: "")
        msgL.adjustsFontSizeToFitWidth = true
        divL.text = NSLocalizedString("Register Share Input Div", comment: "")
        belowL.text = NSLocalizedString("Register Share Input Below", comment: "")
        
        downBtn.backgroundColor = .clear
        downBtn.setTitleColor(.white, for: .normal)
        downBtn.layer.borderWidth = 0.5
        downBtn.layer.borderColor = Color_Main_Red.cgColor
        
        scanBgV.layer.borderWidth = 0.5
        scanBgV.layer.borderColor = UIColor.white.cgColor
        scanBgV.layer.cornerRadius = 20
        
        textBgV.layer.borderWidth = 0.5
        textBgV.layer.borderColor = UIColor.white.cgColor
        textBgV.layer.cornerRadius = textBgV.frame.size.height/2
        
        downBtn.setTitle(NSLocalizedString("submit Upper", comment: ""), for: .normal)
        inputMoreSpaceView.isHidden = true
        
        inputTextField.delegate = self
        inputTextField.keyboardType = .numberPad
        inputTextField.attributedPlaceholder = NSAttributedString(string: "MID", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
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
