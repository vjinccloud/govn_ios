//
//  RegisterSelfPhotoVC.swift
//  indogo
//
//  Created by mac on 2020/7/29.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class RegisterSelfPhotoVC: UIViewController, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var scanView: UIView!
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private  var photoOutPut: AVCapturePhotoOutput!
    private var captureDevice: AVCaptureDevice!
    
    var loadOnce:Bool = false
    var stopNow:Bool = false
    var allStop = false
    
    var takePhotoType:PhotoIDType = PhotoIDType.normal
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func captureAction(_ sender: Any) {
        #if targetEnvironment(simulator)
        //模擬器直接秀下一步
        self.nextStepForSimulator()
        #else
        let settings = AVCapturePhotoSettings()
        photoOutPut.capturePhoto(with: settings, delegate: self)
        #endif
    }
    
    func nextStepForSimulator() {
        //RegisterSelfPhotoStep2VC
        let image = UIImage.init(named: "close.png")
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDAndSelfPhotoStep2VC") as? RegisterIDAndSelfPhotoStep2VC
        nextVC?.tempImg = image
        nextVC?.takePhotoType = takePhotoType
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - Camera
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        //RegisterSelfPhotoStep2VC
        let image = UIImage(data: imageData)
        
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDAndSelfPhotoStep2VC") as? RegisterIDAndSelfPhotoStep2VC
        nextVC?.tempImg = image
        nextVC?.takePhotoType = takePhotoType
        self.navigationController?.pushViewController(nextVC!, animated: true)
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
                if device.position == .front {
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
            }
            
                   
        } catch {
            //If any error occurs, simply print it out
            print(error)
            return
        }
    }
    
    //MARK: - Utility
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
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("back", comment: "")
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
