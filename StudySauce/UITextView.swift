//
//  UITextView.swift
//  StudySauce
//
//  Created by Stephen Houghton on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit
extension UITextView {
    
    func setFontFamily(family: String) {
        self.font = UIFont(name: family, size: self.font?.pointSize ?? 0.0)
    }
    
}