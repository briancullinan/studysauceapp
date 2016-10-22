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
    
    override func setFontName(_ name: String) {
        self.titleLabel!.font = UIFont(name: name, size: self.titleLabel!.font.pointSize ?? 0.0)
    }
    
    override func setFontSize(_ size: CGFloat) {
        self.titleLabel!.font = UIFont(name: self.titleLabel!.font.familyName ?? "", size: size)
    }

    override func setFontColor(_ color: UIColor) {
        self.setTitleColor(color, for: UIControlState())
        self.titleLabel!.textColor = color
    }
    
}
