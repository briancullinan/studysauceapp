//
//  UIViewController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UIViewController {
    func getUser() -> User? {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).user
    }
    
    func getContext() -> NSManagedObjectContext? {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
}