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
        self.email.resignFirstResponder()
        self.postJson("/signup-beta", params: ["email" : self.email.text], done: {(json) in
            self.showDialog(NSLocalizedString("Thank you! We will email you shortly.", comment: "User signed up for mailing list."), button: NSLocalizedString("Go home", comment: "Return to the login/signup landing screen after beta sign up"), done: {
                self.goHome()
                return true
            })
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}

