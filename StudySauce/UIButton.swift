//
//  UIButton.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    override func setFontName(name: String) {
        self.matches()?.titleLabel?.font = UIFont(name: name, size: self.titleLabel?.font.pointSize ?? 0.0)
    }
    
    override func setFontColor(color: UIColor) {
        self.matches()?.setTitleColor(color, forState: UIControlState.Normal)
        self.matches()?.titleLabel?.textColor = color
    }
}