//
//  UserInviteController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserInviteController : UIViewController {
    
    internal var first: String?
    internal var last: String?
    internal var mail: String?
    internal var regCode: String?
    internal var token: String?

    @IBOutlet weak var registrationCode: UITextField!
    
    @IBAction func submitCode(sender: UIButton) {
        self.regCode = self.registrationCode.text
        self.showNoConnectionDialog({
            self.getInvite()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? UserRegisterController {
            vc.registrationCode = self.registrationCode.text
            vc.first = self.first
            vc.last = self.last
            vc.mail = self.mail
            vc.token = self.token
        }
    }
    
    func getInvite() -> Void {
        var is_error_or_redirect = false
        self.postJson("/register", params: ["_code": self.regCode], error: {(code) in
            is_error_or_redirect = true
            if code == 404 {
                self.showDialog("No matching code found", button: "Try again")
                return
            }
            if code == 301 {
                self.showDialog("Existing account found", button: "Log in instead", done: {
                    dispatch_async(dispatch_get_main_queue(),{
                        self.performSegueWithIdentifier("login", sender: self)
                    })
                    return true
                })
            }
            }, redirect: {(path) in
                is_error_or_redirect = true
                if path == "/home" {
                    self.goHome()
                    return
                }
            }, done: {(json) in
                self.first = json["first"] as? String
                self.last = json["last"] as? String
                self.mail = json["email"] as? String
                if !is_error_or_redirect {
                    self.performSegueWithIdentifier("register", sender: self)
                }
        })
    }
    
}