//
//  NSManagedObjectContext.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/16/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func insert<A: NSManagedObject>(t: A.Type) -> A {
        return NSEntityDescription.insertNewObjectForEntityForName("\(t)", inManagedObjectContext: self) as! A
    }
    
    func list<A: NSManagedObject>(t: A.Type) -> [A] {
        do {
            let results = try self.executeFetchRequest(NSFetchRequest(entityName: "\(t)") <| {
                $0.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
                }) as! [A]
            return results
        }
        catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        return []
    }
}
