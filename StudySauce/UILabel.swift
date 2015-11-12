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
    func setFontName(family: String) {
        self.matches()?.font = UIFont(name: family, size: self.font.pointSize)
    }
    
    func setFontColor(color: UIColor) {
        self.matches()?.textColor = color
    }
}