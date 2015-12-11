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
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10 * saucyTheme.multiplier(), 10 * saucyTheme.multiplier())
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10 * saucyTheme.multiplier(), 10 * saucyTheme.multiplier())
    }
}
