//
//  UserRegisterController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserRegisterController : UIViewController, UITextFieldDelegate {
    
    internal var registrationCode: String?
    internal var first: String?
    internal var last: String?
    internal var mail: String?
    internal var child: Bool?
    internal var token: String?
    internal var pass: String?
    internal var props: NSDictionary?
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var childSwitch: UISwitch!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var childButton: UIButton!
    @IBOutlet weak var childFirst: TextField!
    @IBOutlet weak var childLast: TextField!
    
    
    @IBAction func addChild(sender: UIButton) {
        //self.childrenCount++
    }
    
    @IBAction func registerClick(sender: UIButton) {
        self.firstName.resignFirstResponder()
        self.lastName.resignFirstResponder()
        self.email.resignFirstResponder()
        self.password.resignFirstResponder()
        
        self.first = self.firstName.text
        self.last = self.lastName.text
        self.mail = self.email.text
        self.child = self.childSwitch.on
        self.pass = self.password.text

        if self.first != "" && self.last != "" && self.mail != "" && self.password != "" {
            if self.isValidEmail(self.mail!) {
                self.registerUser()
            }
            else {
                self.showDialog(NSLocalizedString("Invalid e-mail address", comment: "Message for when someone registers with invalid email."), NSLocalizedString("Ok", comment: "Button for when users registers with invalid e-mail address")) {
                    self.email.becomeFirstResponder()
                }
            }
        }
    }
    
    @IBAction func switchClick(sender: UIButton) {
        self.childSwitch.setOn(!self.childSwitch.on, animated: true)
        self.childSwitchOn(self.childSwitch)
    }
    
    @IBAction func childSwitchOn(sender: AnyObject) {
        
        if childSwitch.on
        {
            self.childFirst.hidden = false
            self.childLast.hidden = false
            //self.addButton.hidden = false
        }
        else
        {
            self.childFirst.hidden = true
            self.childLast.hidden = true
            //self.addButton.hidden = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lastName.text = self.last
        self.firstName.text = self.first
        self.email.text = self.mail
        self.childSwitch.on = true
        self.childSwitch.hidden = false
        self.childButton.hidden = false
        //self.addButton.hidden = false
        self.childFirst.hidden = false
        self.childLast.hidden = false
        if self.props?["child_required"] as? Bool == true {
            self.childSwitch.on = true
            self.childSwitch.hidden = true
            self.childButton.hidden = true
            self.childFirst.hidden = false
            self.childLast.hidden = false
            //self.addButton.hidden = false
        }
        if self.props?["child_disabled"] as? Bool == true {
            self.firstName.placeholder = NSLocalizedString("First name", comment: "Placeholder text for first name registration")
            self.childSwitch.on = false
            self.childSwitch.hidden = true
            self.childButton.hidden = true
            self.childFirst.hidden = true
            self.childLast.hidden = true
            //self.addButton.hidden = true
        }
        self.lastName!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.lastName!.delegate = self
        self.firstName!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.firstName!.delegate = self
        self.email!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.email!.delegate = self
        self.childFirst!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.childFirst!.delegate = self
        self.childLast!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.childLast!.delegate = self
        IQKeyboardManager.sharedManager().enable = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doMain {
            self.registerClick(self.registerButton)
        }
        return true
    }

    func done() {
        self.registerButton.enabled = true
        self.registerButton.alpha = 1
        self.registerButton.setFontColor(saucyTheme.lightColor)
        self.registerButton.setBackground(saucyTheme.secondary)
    }
    
    func registerUser() {
        var registrationInfo: Dictionary<String,AnyObject?> = [
            "code" : self.registrationCode,
            "first" : self.first,
            "last" : self.last,
            "email" : self.mail,
            "password" : self.pass,
            "csrf_token" : self.token
        ]
        if self.child == true {
            registrationInfo["childFirst"] = self.childFirst.text
            registrationInfo["childLast"] = self.childLast.text
        }
        doMain {
            self.registerButton.enabled = false
            self.registerButton.alpha = 0.85
            self.registerButton.setFontColor(saucyTheme.fontColor)
            self.registerButton.setBackground(saucyTheme.lightColor)
        }
        self.showNoConnectionDialog {
            var redirect = false
            postJson("/account/create", registrationInfo, error: {_ in
                doMain(self.done)
                }, redirect: {(path) in
                    // login was a success!
                    if path == "/home" {
                        redirect = true
                        AppDelegate.goHome(self, true) {_ in
                            doMain (self.done)
                        }
                    }
                    if path == "/login" {
                        redirect = true
                        self.showDialog(NSLocalizedString("Existing account found", comment: "Can't create account because same email address is already used"), NSLocalizedString("Log in instead", comment: "Log in instead of registering for a new account")) {
                            self.performSegueWithIdentifier("login", sender: self)
                            doMain (self.done)
                        }
                    }
                }) {_ in
                    if !redirect {
                        doMain(self.done)
                    }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true)
    }
}

extension UIViewController {
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
}