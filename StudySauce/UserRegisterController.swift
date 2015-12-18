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
    internal var child: Bool?
    internal var childFirstName: String?
    internal var childLastName: String?
    internal var token: String?
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var childSwitch: UISwitch!
    @IBOutlet weak var childFirst: UITextField!
    @IBOutlet weak var childLast: UITextField!
    
    @IBAction func registerClick(sender: UIButton) {
        self.firstName.resignFirstResponder()
        self.lastName.resignFirstResponder()
        self.email.resignFirstResponder()
        self.childFirst.resignFirstResponder()
        self.childLast.resignFirstResponder()
        
        self.first = self.firstName.text
        self.last = self.lastName.text
        self.mail = self.email.text
        self.child = self.childSwitch.on
        self.childFirstName = self.childFirst.text
        self.childLastName = self.childLast.text
        if self.first != "" && self.last != "" && self.mail != "" &&
            (self.child != true || self.childFirstName != "" && self.childLastName != "") {
            self.registerUser()
        }
    }
    
    @IBAction func switchClick(sender: UIButton) {
        self.childSwitch.setOn(!self.childSwitch.on, animated: true)
        self.childSwitchOn(self.childSwitch)
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
        var registrationInfo: Dictionary<String,AnyObject?> = [
            "code" : self.registrationCode,
            "first" : self.first,
            "last" : self.last,
            "email" : self.mail,
            "csrf_token" : self.token
        ]
        if self.child == true {
            registrationInfo["childFirst"] = self.childFirstName
            registrationInfo["childLast"] = self.childLastName
        }
        
        self.showNoConnectionDialog({
            postJson("/account/create", params: registrationInfo, redirect: {(path) in
                    // login was a success!
                    if path == "/home" {
                        self.goHome(true)
                    }
                    if path == "/login" {
                        self.showDialog(NSLocalizedString("Existing account found", comment: "Can't create account because same email address is already used"), button: NSLocalizedString("Log in instead", comment: "Log in instead of registering for a new account"), done: {
                            self.performSegueWithIdentifier("login", sender: self)
                        })
                    }
            })
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}