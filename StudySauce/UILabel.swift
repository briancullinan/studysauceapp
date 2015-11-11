//
//  UILabel.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit
extension UILabel {
    func setFontFamily(family: String) {
        self.font = UIFont(name: family, size: self.font.pointSize)
    }
    
    func setFontColor(color: UIColor) {
        self.textColor = color
    }
}