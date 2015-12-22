//
//  UserAddController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 12/21/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserAddController : UIViewController {
    
    @IBAction func backClick(sender: UIButton) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addClick(sender: UIButton) {
        
    }
    
}