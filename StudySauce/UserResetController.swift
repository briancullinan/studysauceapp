//
//  UserSettingsController.swift
//  StudySauce
//
//  Created by Stephen Houghton on 10/5/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class UserResetController: UIViewController {
    
    var mail: String? = nil
    @IBOutlet weak var email: UITextField!
    
    @IBAction func resetClick(sender: UIButton) {
        self.mail = email.text
        self.showNoConnectionDialog({
            self.postJson("/reset", params: ["email": self.mail], done: {
                self.showDialog("Your password has been reset.  Please check your email.", button: "Go home", done: {
                    self.performSegueWithIdentifier("home", sender: self)
                    return true
                })
            })
        })
    }
}