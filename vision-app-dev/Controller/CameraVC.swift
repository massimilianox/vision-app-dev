//
//  ViewController.swift
//  vision-app-dev
//
//  Created by Massimiliano Abeli on 29/09/2018.
//  Copyright © 2018 Massimiliano Abeli. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController {

    var captureSession: AVCaptureSession!
    var captureOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var recognizedObjLbl: UILabel!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var outputView: RoundedShadowView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer.frame = cameraView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            if captureSession.canAddInput(input) == true {
                captureSession.addInput(input)
            }
            
            captureOutput = AVCapturePhotoOutput()
            if captureSession.canAddOutput(captureOutput) == true {
                captureSession.addOutput(captureOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
                previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                cameraView.layer.addSublayer(previewLayer)
                captureSession.startRunning()
            }
        } catch {
            debugPrint(error)
        }
    }

}

