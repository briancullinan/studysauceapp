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
    var password: String? = nil
    internal var token: String? = nil
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    
    @IBAction func resetClick(sender: UIButton) {
        self.email.resignFirstResponder()
        self.mail = email.text
        self.showNoConnectionDialog({
            self.postJson("/reset", params: ["email": self.mail], done: {(json) in 
                self.showDialog("Your password has been reset.  Please check your email.", button: "Go home", done: {
                    // password resets don't change users until code is entered so don't bother refetching
                    self.goHome()
                    return true
                })
            })
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func resetClick2(sender: AnyObject) {
        self.pass.resignFirstResponder()
        self.password = self.pass.text
        self.showNoConnectionDialog({
            self.postJson("/reset", params: ["email": self.mail, "token": self.token, "newPass": self.password], redirect: {(path) in
                if path == "/home" {
                    self.goHome()
                }
            })
        })
    }
}