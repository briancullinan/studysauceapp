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
    
    func setFontName(name: String) {
        self.matches()?.titleLabel?.font = UIFont(name: name, size: self.titleLabel?.font.pointSize ?? 0.0)
    }
}