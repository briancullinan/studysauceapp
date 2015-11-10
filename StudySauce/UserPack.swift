//
//  UserPack.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/29/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData

class UserPack: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    func getRetries() -> [Card] {
        if self.retries == nil || self.retries == "" {
            return []
        }
        return self.retries!.componentsSeparatedByString(",").map{r -> Card? in
            return self.pack?.getCardById(Int(r)!)
        }.filter{ x -> Bool in
            return x != nil
        }.map{c -> Card in
            return c!
        }
    }
}
