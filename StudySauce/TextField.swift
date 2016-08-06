//
//  TextField.swift
//  StudySauce
//
//  Created by Brian Cullinan on 12/9/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class TextField: UITextField {
    internal var padding: UIEdgeInsets = UIEdgeInsets(saucyTheme.padding)
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, self.padding)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, self.padding)
    }
    
}
