//
//  AnyObject.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/13/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

infix operator <| { }

func <|<T>(obj: T, f: T -> () ) -> T {
    f(obj)
    return obj
}
