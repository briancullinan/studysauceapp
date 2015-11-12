//
//  UIView.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

private struct AssociatedKeys {
    static var displayed = "nsh_DescriptiveName"
}

extension UIView {
    func matches() -> Self? {
        if Queryable.queryList[self.query].matches(self) {
            return self
        }
        return nil
    }
    
    var query : Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.displayed) as! Int
        }
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.displayed,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setAppearance(q: Int) {
        self.query = q
    }
}