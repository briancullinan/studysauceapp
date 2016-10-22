//
//  AnyObject.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/13/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

infix operator <|

func <|<T: AnyObject>(obj: T, f: (T) -> () ) -> T {
    f(obj)
    return obj
}

func doMain (_ block: @escaping () -> Void) {
    DispatchQueue.main.async(execute: block)
}

func doBackground(_ block: @escaping () -> Void) {
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: block)
}
