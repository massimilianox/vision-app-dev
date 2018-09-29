//
//  ViewController.swift
//  vision-app-dev
//
//  Created by Massimiliano Abeli on 29/09/2018.
//  Copyright © 2018 Massimiliano Abeli. All rights reserved.
//

import UIKit

class CameraVC: UIViewController {

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


}

