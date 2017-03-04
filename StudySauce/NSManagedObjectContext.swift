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
    func insert<A: NSManagedObject>(_ t: A.Type) -> A {
        return NSEntityDescription.insertNewObject(forEntityName: "\(t)", into: self) as! A
    }
    
    func list<A: NSManagedObject>(_ t: A.Type) -> [A] {
        do {
            let results = try self.fetch(NSFetchRequest(entityName: "\(t)") <| {
                $0.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
                }) 
            return results as! [A]
        }
        catch let error as NSError {
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        return []
    }
}
