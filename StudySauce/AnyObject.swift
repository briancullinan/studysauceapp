//
//  AnyObject.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/13/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

infix operator <| { }

func <|<T: AnyObject>(obj: T, f: T -> () ) -> T {
    f(obj)
    return obj
}

func doMain (block: () -> Void) {
    dispatch_async(dispatch_get_main_queue(), block)
}

func doBackground(block: () -> Void) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), block)
}