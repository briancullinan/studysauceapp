//
//  NotificationManager.swift
//  StudySauce
//
//  Created by Brian Cullinan on 2/22/16.
//  Copyright © 2016 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class NotificationManager {
    fileprivate var observerTokens: [AnyObject] = []
    
    deinit {
        deregisterAll()
    }
    
    func deregisterAll() {
        for token in observerTokens {
            NotificationCenter.default.removeObserver(token)
        }
        
        observerTokens = []
    }
    
    func registerObserver(_ name: String!, block: @escaping ((Notification!) -> Void)) {
        let newToken = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: name), object: nil, queue: nil, using: block)
        
        observerTokens.append(newToken)
    }
    
    func registerObserver(_ name: String!, forObject object: AnyObject!, block: @escaping ((Notification!) -> Void)) {
        let newToken = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: name), object: object, queue: nil, using: block)
        
        observerTokens.append(newToken)
    }
}
