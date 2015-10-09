//
//  MasterViewController.swift
//  StudySauce
//
//  Created by admin on 9/12/15.
//  Copyright (c) 2015 The Study Institute. All rights reserved.
//

import UIKit
import CoreData

class BetaSignupController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBAction func emailClick(sender: UIButton) {
        self.postJson("/signup-beta", params: ["email" : self.email.text], done: {(json) in 
            self.showDialog("Thank you! We will email you shortly.", button: "Go home", done: {
                self.goHome()
                return true
            })
        })
    }
    
}

