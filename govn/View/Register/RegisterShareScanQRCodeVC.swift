//
//  RegisterShareScanQRCodeVC.swift
//  indogo
//
//  Created by mac on 2020/7/29.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class RegisterShareScanQRCodeVC: UIViewController, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var topL: UILabel!
    @IBOutlet weak var bottomL: UILabel!
    @IBOutlet weak var scanL: UILabel!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var realScanRectView: UIView!
    
    var captureSession:AVCaptureSession!
    var capturePhotoOutput:AVCapturePhotoOutput!
    var parentVC:RegisterShareInputVC!
    var loadOnce:Bool = false
    var stopNow:Bool = false
    var allStop = false
    
    //MARK: - Utility
    func simulatorNextAction() {
        //試試測試帳號
        scanNext(Code: "10012")
    }
    
    func scanNext(Code code:String) {
        self.scanL.isHidden = true
        parentVC.setCodeString(Code:code)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func delayForQRCodeRestart() {
        stopNow = false
        if allStop != true, captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    //MARK: - QR Reader
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is contains at least one object.
        if metadataObjects.count == 0 {
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            if let outputString = metadataObj.stringValue {
                DispatchQueue.main.async { //FA20051865
                    Dlog("outputString = \(outputString)")
                    if self.stopNow || self.allStop {
                        return
                    }
                    self.stopNow = true
                    if (self.captureSession?.isRunning == true) {
                        self.captureSession.stopRunning()
                    }
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
                AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("Camera Request Agreement", comment: ""))
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
            captureMetadataOutput.metadataObjectTypes = [ AVMetadataObject.ObjectType.qr]
            
            //Initialise the video preview layer and add it as a sublayer to the viewPreview view's layer
            //let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            //videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            //videoPreviewLayer.frame = scanView.layer.bounds
            
            DispatchQueue.main.async {
                let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                previewLayer.frame = self.scanView.layer.bounds
                previewLayer.videoGravity = .resizeAspectFill
                self.scanView.layer.addSublayer(previewLayer)
                
                captureMetadataOutput.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: self.realScanRectView.frame)
                
                //start video capture
                self.captureSession?.startRunning()
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
        backBtn.layer.cornerRadius = backBtn.frame.size.height/2
        backBtn.setTitle(NSLocalizedString("back Show", comment: ""), for: .normal)
        topL.text = NSLocalizedString("Register Share Scan Top", comment: "")
        bottomL.text = NSLocalizedString("Register Share Scan Bottom", comment: "")
        scanL.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        
        if loadOnce {
            stopNow = false
            allStop = false
            return
        }
        
        loadOnce = true
        checkCameraPermission()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        allStop = true
        stopNow = true
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
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

