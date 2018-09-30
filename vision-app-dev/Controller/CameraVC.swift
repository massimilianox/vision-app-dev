//
//  ViewController.swift
//  vision-app-dev
//
//  Created by Massimiliano Abeli on 29/09/2018.
//  Copyright © 2018 Massimiliano Abeli. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate {

    var captureSession: AVCaptureSession!
    var captureOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCameraView))
        tap.numberOfTapsRequired = 1
        
        
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
                cameraView.addGestureRecognizer(tap)
                captureSession.startRunning()
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            debugPrint(error as Any)
        } else {
            photoData = photo.fileDataRepresentation()
            let image = UIImage(data: photoData!)
            captureImageView.image = image
            
            do {
                let model = try VNCoreMLModel(for: SqueezeNet().model )
                let request = VNCoreMLRequest(model: model) { (request, error) in
                    guard let results = request.results as? [VNClassificationObservation] else { return }
                    
                    for classification in results {
                        if classification.confidence < 0.5 {
                            self.identificationLbl.text = "I am not sure what it is, please try again"
                            self.recognizedObjLbl.text = ""
                            break
                        } else {
                            self.identificationLbl.text = classification.identifier
                            self.recognizedObjLbl.text = "Confidence: \(Int(classification.confidence * 100))"
                            break
                        }
                    }
                    
                }
                let handler = VNImageRequestHandler(data: photoData!)
                try handler.perform([request])
            } catch {
                debugPrint(error)
            }
            
            print("Process photo end");
        }
    }
    
    @objc func didTapCameraView() {
        let settings = AVCapturePhotoSettings()
        
//        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
//        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType, kCVPixelBufferWidthKey as String: 160, kCVPixelBufferHeightKey as String: 160]
//        settings.previewPhotoFormat = previewFormat as? [String : Any]
        
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        
        captureOutput.capturePhoto(with: settings, delegate: self)
        
    }

}

