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
    @IBOutlet weak var registrationCode2: UITextField!
    
    @IBAction func returnToInvite(segue: UIStoryboardSegue) {
        
    }

    @IBAction func submitCode(sender: UIButton) {
        self.registrationCode.resignFirstResponder()
        self.regCode = self.registrationCode.text
        if self.regCode == "" {
            return
        }
        
        self.showNoConnectionDialog({
            self.getInvite()
        })
    }
    
    @IBAction func submitCode2(sender: UIButton) {
        self.registrationCode2.resignFirstResponder()
        self.regCode = self.registrationCode2.text
        if self.regCode == "" {
            return
        }
        
        self.showNoConnectionDialog({
            self.getInvite()
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? UserRegisterController {
            vc.registrationCode = self.regCode
            vc.first = self.first
            vc.last = self.last
            vc.mail = self.mail
            vc.token = self.token
        }
    }
    
    func getInvite() -> Void {
        postJson("/register", params: ["_code": self.regCode], error: {(code) in
            if code == 404 {
                self.showDialog(NSLocalizedString("No matching code found", comment: "Failed to find the invite code"), button: NSLocalizedString("Try again", comment: "Try to enter a different invite code"))
            }
            }, redirect: {(path) in
                if path == "/home" {
                    self.goHome(true)
                }
            }, done: {(json) in
                self.first = json!["first"] as? String
                self.last = json!["last"] as? String
                self.mail = json!["email"] as? String
        })
    }
    
}