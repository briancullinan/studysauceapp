//
//  NSObject.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/2/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    func isTypeOf(b: NSObject) -> Bool {
        return object_getClassName(self) == object_getClassName(b)
    }
}

extension UIEdgeInsets {
    
    init(_ width: CGFloat) {
        self.init(top: width, left: width, bottom: width, right: width)
    }
}