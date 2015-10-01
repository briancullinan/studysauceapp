//
//  DismissSegue.swift
//  StudySauce
//
//  Created by Brian Cullinan on 10/1/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class DismissSegue : UIStoryboardSegue {
    
    override func perform() {
        let sourceViewController = self.sourceViewController;
        sourceViewController.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
}