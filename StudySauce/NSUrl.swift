//
//  NSUrl.swift
//  StudySauce
//
//  Created by Brian Cullinan on 10/13/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation


extension NSURL {
    func getKeyVals() -> Dictionary<String, String?> {
        var results = [String:String?]()
        let keyValues = self.query?.componentsSeparatedByString("&")
        if keyValues?.count > 0 {
            for pair in keyValues! {
                let kv = pair.componentsSeparatedByString("=")
                if kv.count > 1 {
                    results.updateValue(kv[1], forKey: kv[0])
                }
            }
            
        }
        return results
    }
}