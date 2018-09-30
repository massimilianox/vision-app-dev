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

enum FlashState {
    case on
    case off
}

class CameraVC: UIViewController, AVCapturePhotoCaptureDelegate, AVSpeechSynthesizerDelegate {

    var captureSession: AVCaptureSession!
    var captureOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoData: Data?
    
    var flashControlState: FlashState = .off
    
    var speechSythesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var recognizedObjLbl: UILabel!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var outputView: RoundedShadowView!
    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!
    
    @IBAction func flashBtnPressed(_ sender: Any) {
        switch flashControlState {
        case .off:
            flashBtn.setTitle("Flash on", for: .normal)
            flashControlState = .on
            break
        case .on:
            flashBtn.setTitle("Flash off", for: .normal)
            flashControlState = .off
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityMonitor.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer.frame = cameraView.bounds
        speechSythesizer.delegate = self
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
    
    // AVCapturePhotoCaptureDelegate
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
                            let unknownObjMessage = "I am not sure what it is, please try again"
                            self.identificationLbl.text = unknownObjMessage
                            self.recognizedObjLbl.text = ""
                            self.synthesizeSpeech(fromString: unknownObjMessage)
                            break
                        } else {
                            let identification = classification.identifier
                            let confidence = Int(classification.confidence * 100)
                            self.identificationLbl.text = identification
                            self.recognizedObjLbl.text = "Confidence: \(confidence)"
                            let completesentence = "I think this is a \(identification). I am \(confidence)% sure"
                            self.synthesizeSpeech(fromString: completesentence)
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
    
    // AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        cameraView.isUserInteractionEnabled = true
        activityMonitor.isHidden = true
        activityMonitor.stopAnimating()
    }
    
    func synthesizeSpeech(fromString string: String) {
        let speechUtterance = AVSpeechUtterance(string: string)
        speechSythesizer.speak(speechUtterance)
    }
    
    @objc func didTapCameraView() {
        
        cameraView.isUserInteractionEnabled = false
        activityMonitor.isHidden = false
        activityMonitor.startAnimating()
        
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        
        if flashControlState == .off {
            settings.flashMode = .off
        } else {
            settings.flashMode = .on
        }
        
        captureOutput.capturePhoto(with: settings, delegate: self)
    }

}

