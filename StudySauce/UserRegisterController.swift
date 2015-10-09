//
//  UserRegisterController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserRegisterController : UIViewController {
    
    internal var registrationCode: String?
    internal var first: String?
    internal var last: String?
    internal var mail: String?
    internal var token: String?
    
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var childSwitch: UISwitch!
    @IBOutlet weak var childFirst: UITextField!
    @IBOutlet weak var childLast: UITextField!
    
    @IBAction func registerClick(sender: UIButton) {
        self.first = self.firstName.text
        self.mail = self.email.text
        self.last = self.lastName.text
        self.showNoConnectionDialog({
            self.registerUser()
        })
    }
    
    @IBAction func childSwitchOn(sender: AnyObject) {
        
        if childSwitch.on
        {
            childFirst.hidden = false
            childLast.hidden = false
        }
        
        else
        {
            childFirst.hidden = true
            childLast.hidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lastName.text = self.last
        firstName.text = self.first
        email.text = self.mail
    }
    
    func registerUser() {
        self.postJson("/account/create", params: [
            "code" : self.registrationCode,
            "first" : self.first,
            "last" : self.last,
            "email" : self.mail,
            "csrf_token" : self.token
            ], redirect: {(path) in
                // login was a success!
                if path == "/home" {
                    self.goHome()
                }
            }, error: {(code) in
                if code == 301 {
                    self.showDialog("Existing account found", button: "Log in instead", done: {
                        dispatch_async(dispatch_get_main_queue(),{
                            self.performSegueWithIdentifier("login", sender: self)
                        })
                        return true
                    })
                }
            })
    }
    
}