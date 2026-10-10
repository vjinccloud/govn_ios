//
//  RegisterIDCameraVC.swift
//  indogo
//
//  Created by mac on 2020/8/4.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class RegisterIDCameraVC: UIViewController, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var bottomL: UILabel!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var resultImgV: UIImageView!
    @IBOutlet weak var coverImgV: UIImageView!
    @IBOutlet weak var coverImgWidthConstrain: NSLayoutConstraint!
    @IBOutlet weak var nextBtnWidthConstrain: NSLayoutConstraint!
    @IBOutlet weak var nextBtnUpDistanceConstrain: NSLayoutConstraint!
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private  var photoOutPut: AVCapturePhotoOutput!
    private var captureDevice: AVCaptureDevice!
    
    var tempImg:UIImage!
    var loadOnce:Bool = false
    var stopNow:Bool = false
    var allStop = false
    
    var takePhotoType:PhotoIDType = PhotoIDType.front
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        #if targetEnvironment(simulator)
        //模擬器直接秀下一步
        self.tempImg = UIImage.init(named: "close.png")
        self.nextStep()
        #else
        guard let photoOutPut = photoOutPut else {
            checkCameraPermission()
            return
        }
        let settings = AVCapturePhotoSettings()
        photoOutPut.capturePhoto(with: settings, delegate: self)
        #endif
    }

    func nextStep() {
        guard let viewControllers = self.navigationController?.viewControllers else {
            return
        }
        
        for firstViewController in viewControllers {
            if takePhotoType == .front || takePhotoType == .back {
                if firstViewController is RegisterIDTakePhotoVC {
                    let nextVC = firstViewController as! RegisterIDTakePhotoVC
                    nextVC.setTakedPic(Type: takePhotoType, Img: tempImg!.fixedOrientationToLandscape()!)
                    self.navigationController?.popToViewController(nextVC, animated: true)
                    break
                }
            } else if takePhotoType == .frontFromEdit || takePhotoType == .backFromEdit {
                if firstViewController is MemberEditVC {
                    let nextVC = firstViewController as! MemberEditVC
                    nextVC.setTakedPic(Type: takePhotoType, Img: tempImg!.fixedOrientationToLandscape()!)
                    self.navigationController?.popToViewController(nextVC, animated: true)
                    break
                }
            } else if takePhotoType == .passport {
                if firstViewController is RegisterIDSignVC {
                    let nextVC = firstViewController as! RegisterIDSignVC
                    nextVC.setTakedPic(Type: takePhotoType, Img: tempImg!.fixedOrientationToLandscape()!)
                    self.navigationController?.popToViewController(nextVC, animated: true)
                    break
                }
            } else if takePhotoType == .passportFromEdit {
                if firstViewController is MemberEditVC {
                    let nextVC = firstViewController as! MemberEditVC
                    nextVC.setTakedPic(Type: takePhotoType, Img: tempImg!.fixedOrientationToLandscape()!)
                    self.navigationController?.popToViewController(nextVC, animated: true)
                    break
                }
            }
            
        }
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        nextStep()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        hideTakedImg()
    }
    
    //MARK: - Camera
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
        tempImg = image
        showTakedImg()
    }
    
    func showTakedImg() {
        resultImgV.image = tempImg
        
        resultImgV.isHidden = false
        nextBtn.isHidden = true
        confirmView.isHidden = false
        scanView.isHidden = true
    }
    
    func hideTakedImg() {
        resultImgV.isHidden = true
        nextBtn.isHidden = false
        confirmView.isHidden = true
        scanView.isHidden = false
    }
    
    func initCamera() {
        
        guard AVCaptureDevice.default(for: AVMediaType.video) != nil else {
            Dlog("無攝影裝置")
            #if targetEnvironment(simulator)
            //模擬器直接秀下一步
            //self.simulatorNextAction()
            #else
            
            #endif
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous deivce object
            // Initialize the captureSession object
            captureSession = AVCaptureSession()
            
            // Set the input device on the capture session
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
            let devices = deviceDiscoverySession.devices
            for device in devices {
                if device.position == .back {
                    self.captureDevice = device
                }
            }
            
            let input = try AVCaptureDeviceInput(device: self.captureDevice)
            captureSession?.addInput(input)
            
            DispatchQueue.main.async {
                self.photoOutPut = AVCapturePhotoOutput()
                self.photoOutPut.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
                if self.captureSession.canAddOutput(self.photoOutPut) {
                    self.captureSession.addOutput(self.photoOutPut)
                }
                
                let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                previewLayer.frame = self.scanView.layer.bounds
                previewLayer.videoGravity = .resizeAspectFill
                self.scanView.layer.addSublayer(previewLayer)
                
                //start video capture
                self.captureSession?.startRunning()
                self.setContinuousAutoFocus()
                self.setZoomFactor(2.0) // 放大2倍
            }
            
                   
        } catch {
            //If any error occurs, simply print it out
            print(error)
            return
        }
    }
    
    func setContinuousAutoFocus() {
        guard let device = self.captureDevice else { return }
        do {
            try device.lockForConfiguration()
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            device.unlockForConfiguration()
        } catch {
            print("Error Unable to lock configuration: \(error.localizedDescription)")
        }
    }
    
    func setZoomFactor(_ zoomFactor: CGFloat) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = min(max(zoomFactor, 1.0), device.activeFormat.videoMaxZoomFactor)
            device.unlockForConfiguration()
        } catch {
            print("Error setting zoom factor: \(error)")
        }
    }
    
    //MARK: - Utility
    //檢查相機權限
    func checkCameraPermission() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            self.initCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (access) in
                DispatchQueue.main.async {
                    if access {
                        self.initCamera()
                    } else {
                        self.showCameraPermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            self.showCameraPermissionAlert()
        default:
            break
        }
    }

    //相機權限被拒絕時,提示前往設定,不開相機
    func showCameraPermissionAlert() {
        let alert = UIAlertController(title: "Camera Access Required",
                                      message: "Camera access is required to take the photo. Please enable camera permission in Settings.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("back", comment: "")
        backL.adjustsFontSizeToFitWidth = true
        bottomL.text = NSLocalizedString("bottom for forgoet sec2", comment: "")
        
        scanView.layer.cornerRadius = 25
        resultImgV.layer.cornerRadius = 25
        scanView.clipsToBounds = true
        resultImgV.clipsToBounds = true
        
        resultImgV.isHidden = true
        
        cancelBtn.layer.cornerRadius = cancelBtn.frame.size.height/2
        cancelBtn.backgroundColor = .clear
        cancelBtn.layer.borderColor = Color_Main_Red.cgColor
        cancelBtn.layer.borderWidth = 0.5
        confirmBtn.layer.cornerRadius = confirmBtn.frame.size.height/2
        
        confirmView.isHidden = true
        
        cancelBtn.setTitle(NSLocalizedString("Register Self Photo Retake B", comment: ""), for: .normal)
        confirmBtn.setTitle(NSLocalizedString("Register Self Photo Confrim B", comment: ""), for: .normal)
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
        
        hideTakedImg()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if takePhotoType == PhotoIDType.front || takePhotoType == PhotoIDType.frontFromEdit {
            backL.text = NSLocalizedString("Register ID Photo Title Front", comment: "")
        } else if takePhotoType == PhotoIDType.back || takePhotoType == PhotoIDType.backFromEdit {
            backL.text = NSLocalizedString("Register ID Photo Title Back", comment: "")
            bottomL.text = NSLocalizedString("maek sure all barcode in box", comment: "")
        }
        
        if self.view.frame.size.width<321 {
            /*
            Dlog("special handling")
            coverImgWidthConstrain.constant = -40
            nextBtnWidthConstrain.constant = 80
            nextBtnUpDistanceConstrain.constant = 10*/
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
