//
//  ForgotPassScanVC.swift
//  indogo
//
//  Created by mac on 2020/7/15.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class ForgotPassScanVC: UIViewController, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate, CustomAlertDelegate {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var topL: UILabel!
    @IBOutlet weak var bottomL: UILabel!
    @IBOutlet weak var scanL: UILabel!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var scanMaskView: UIView!
    
    var captureSession:AVCaptureSession!
    var capturePhotoOutput:AVCapturePhotoOutput!
    
    var loadOnce:Bool = false
    var stopNow:Bool = false
    var allStop = false
    
    var wrongTimes = 0
    var countDownTimer:Timer!
    
    public var fromType:ScanParentType = ScanParentType.forgotPass
    
    //MARK: - Utility
    func customAlertnextAction(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        self.stopNow = false
        self.captureSession.startRunning()
        
        if countDownTimer == nil {
            countDownTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(countDownEnd), userInfo: nil, repeats: false)
        }
    }
    
    func customAlertnextActionSecond(Ref obj: CustomAlertView) {
        
    }
    
    func simulatorNextAction() {
        //試試測試帳號
        //Delay一下
        DispatchQueue.main.async {
            //self.scanNext(Code: "XC00000092")
        }
    }
    
    func scanNext(Code code:String) {
        
        //檢查限制為 C,D,8,9 其餘跳出格式錯誤
        //"scan format wrong"
        var checkedWrong = true
        if code.count < 2 {
            checkedWrong = true
        } else {
            let singleWord = code.getSubString(Start: 1, EndNotInclude: 2).lowercased()
            Dlog("singleWord = \(singleWord)")
            if singleWord == "c" || singleWord == "d" || singleWord == "8" || singleWord == "9" {
                checkedWrong = false
            }
        }
        
        if checkedWrong {
            if wrongTimes == 3 {
                //改成跳新的一頁
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArcScanWrong") as? ArcScanWrong
                nextVC!.fromType = fromType
                self.navigationController?.pushViewController(nextVC!, animated: true)
            } else {
                wrongTimes += 1;
                
                let window = UIApplication.shared.keyWindow
                let customAlert = CustomAlertView.init(frame: self.view.frame)
                customAlert.initSimpleAlert(Title: "", Content: NSLocalizedString("scan format wrong" , comment: ""), NextBtn1Str: NSLocalizedString("ok" , comment: ""))
                window!.addSubview(customAlert)
                customAlert.customDelegate = self
            }
            /*
            //改成跳新的一頁
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArcScanWrong") as? ArcScanWrong
            nextVC!.fromType = fromType
            self.navigationController?.pushViewController(nextVC!, animated: true)
            */
            return
        }
        
        scanL.isHidden = true
        
        let parameters:Parameters = ["arc_no":code]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_CheckMemExist;
        AppDelegate.shared().alamofireManagerWithTimeout.request(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("responseStr = \(responseStr ?? "")")
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                AppDelegate.shared().forgotPassTempMemID = code
                if result == ResponseState.ok {
                    if self.fromType == .register { //回登入畫面帶入帳密？
                        AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("Register Member Exist" , comment: ""))
                        self.navigationController?.popToRootViewController(animated: true)
                    } else if self.fromType == .forgotPass {
                        //有電話
                        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassCheckPhoneVC") as? ForgotPassCheckPhoneVC
                        nextVC?.checkType = 0
                        self.navigationController?.pushViewController(nextVC!, animated: true)
                    }
                    
                } else if result == ResponseState.member_not_exist {
                    //會員不存在，註冊
                    if self.fromType == .register { //回到註冊畫面
                        guard let viewControllers = self.navigationController?.viewControllers else {
                            return
                        }

                        for firstViewController in viewControllers {
                            if firstViewController is RegisterInputVC {
                                let nextVC = firstViewController as! RegisterInputVC
                                nextVC.setArcCodeString(Code: code)
                                self.navigationController?.popToViewController(nextVC, animated: true)
                                break
                            }
                        }
                        
                        return
                    } else if self.fromType == .forgotPass {
                        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassCheckPhoneVC") as? ForgotPassCheckPhoneVC
                        nextVC?.checkType = 1
                        self.navigationController?.pushViewController(nextVC!, animated: true)
                    }
                    
                    /*
                    let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassCheckPhoneVC") as? ForgotPassCheckPhoneVC
                    nextVC?.checkType = 1
                    self.navigationController?.pushViewController(nextVC!, animated: true)*/
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    @objc func delayForQRCodeRestart() {
        stopNow = false
        if allStop != true, captureSession?.isRunning == false {
            captureSession.startRunning()
            
            if countDownTimer == nil {
                countDownTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(countDownEnd), userInfo: nil, repeats: false)
            }
        }
        /*
        if allStop != true, captureSession?.isRunning == false {
            captureSession.startRunning()
        }*/
    }
    
    //MARK: - QR Reader
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is contains at least one object.
        if metadataObjects.count == 0 {
            return
        }
        
        //self.captureSession?.stopRunning()
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.code39 {
            if let outputString = metadataObj.stringValue {
                DispatchQueue.main.async { //FA20051865
                    Dlog("outputString = \(outputString)")
                    if self.stopNow || self.allStop {
                        return
                    }
                    self.stopNow = true
                    if (self.captureSession?.isRunning == true) {
                        if self.countDownTimer != nil, self.countDownTimer.isValid {
                            self.countDownTimer.invalidate()
                            self.countDownTimer = nil;
                        }
                        self.captureSession.stopRunning()
                    }
                    /*
                    if (self.captureSession?.isRunning == true) {
                        self.captureSession.stopRunning()
                    }*/
                    self.scanNext(Code: outputString)
                }
            }
        }
        
    }
    
    //檢查相機權限
    func checkCameraPermission() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (access) in
            print("access = \(access)")
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authStatus {
            case .authorized:
                self.initCamera()
                break
            case .denied, .restricted, .notDetermined:
                AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("Camera Photo Request Agreement", comment: ""))
                break
            default:
                break
            }
        }
    }
    
    func initCamera() {
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            Dlog("無攝影裝置")
            #if targetEnvironment(simulator)
            //模擬器直接秀下一步
            self.simulatorNextAction()
            #else
            
            #endif
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous deivce object
            let input = try AVCaptureDeviceInput(device: captureDevice)
                   
            // Initialize the captureSession object
            
            captureSession = AVCaptureSession()
                   
            // Set the input device on the capture session
            captureSession?.addInput(input)
            
            // Get an instance of ACCapturePhotoOutput class
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
                   
            // Set the output on the capture session
            captureSession?.addOutput(capturePhotoOutput!)
            captureSession?.sessionPreset = .high
                   
            // Initialize a AVCaptureMetadataOutput object and set it as the input device
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
                   
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [ AVMetadataObject.ObjectType.code39]
            
            //Initialise the video preview layer and add it as a sublayer to the viewPreview view's layer
            
            DispatchQueue.main.async { [self] in
                
                let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                previewLayer.frame = self.scanView.layer.bounds
                previewLayer.videoGravity = .resizeAspectFill
                self.scanView.layer.addSublayer(previewLayer)
                
                captureMetadataOutput.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: self.scanMaskView.frame)
                
                //start video capture
                self.captureSession?.startRunning()
                
                if self.countDownTimer == nil {
                    self.countDownTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(countDownEnd), userInfo: nil, repeats: false)
                }
                
                self.scanL.isHidden = false
                self.scanL.blink()
            }
            
                   
        } catch {
            //If any error occurs, simply print it out
            print(error)
            return
        }
    }
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("back", comment: "")
        topL.text = NSLocalizedString("top for forget arc scan", comment: "")
        topL.isHidden = true
        scanL.text = NSLocalizedString("scanning", comment: "")
        bottomL.text = NSLocalizedString("bottom for forgoet sec", comment: "")
        scanL.isHidden = true
    }
    
    @objc func countDownEnd() {
        if countDownTimer != nil, countDownTimer.isValid {
            countDownTimer.invalidate()
            countDownTimer = nil;
        }
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArcScanWrong") as? ArcScanWrong
        nextVC!.fromType = fromType
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            
            if (captureSession?.isRunning == false) {
                captureSession.startRunning()
                
                self.scanL.isHidden = false
                self.scanL.blink()
                
                if countDownTimer == nil {
                    countDownTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(countDownEnd), userInfo: nil, repeats: false)
                }
            }
            
            wrongTimes = 0
            stopNow = false
            allStop = false
            return
        }
        /*
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        
        if loadOnce {
            stopNow = false
            allStop = false
            return
        }*/
        
        loadOnce = true
        checkCameraPermission()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        allStop = true
        stopNow = true
        
        if (captureSession?.isRunning == true) {
            if countDownTimer != nil, countDownTimer.isValid {
                countDownTimer.invalidate()
                countDownTimer = nil;
            }
            captureSession.stopRunning()
        }
        
        /*
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }*/
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
