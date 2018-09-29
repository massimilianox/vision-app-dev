//
//  RoundedShadowView.swift
//  vision-app-dev
//
//  Created by Massimiliano Abeli on 29/09/2018.
//  Copyright © 2018 Massimiliano Abeli. All rights reserved.
//

import UIKit

class RoundedShadowView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 14
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = self.frame.height / 2
    }
}
