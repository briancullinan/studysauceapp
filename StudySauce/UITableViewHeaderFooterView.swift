//
//  UITableViewHeaderFooterView.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/13/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewHeaderFooterView {
    
    override func setBackground(_ color: UIColor) {
        self.contentView.setValue(color, forKey: "backgroundColor")
    }

}
