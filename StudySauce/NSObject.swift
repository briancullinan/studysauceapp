//
//  NSObject.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/2/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

extension NSObject {
    func isTypeOf(b: NSObject) -> Bool {
        return object_getClassName(self) == object_getClassName(b)
    }
}