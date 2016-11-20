//
//  UserRegisterController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

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
    
    
    @IBAction func addChild(_ sender: UIButton) {
        //self.childrenCount++
    }
    
    @IBAction func registerClick(_ sender: UIButton) {
        self.firstName.resignFirstResponder()
        self.lastName.resignFirstResponder()
        self.email.resignFirstResponder()
        self.password.resignFirstResponder()
        
        self.first = self.firstName.text
        self.last = self.lastName.text
        self.mail = self.email.text
        self.child = self.childSwitch.isOn
        self.pass = self.password.text

        if self.first != "" && self.last != "" && self.mail != "" && self.pass != "" {
            if self.isValidEmail(self.mail!) {
                self.registerUser()
            }
            else {
                let _ = self.showDialog(NSLocalizedString("Invalid e-mail address", comment: "Message for when someone registers with invalid email."), NSLocalizedString("Ok", comment: "Button for when users registers with invalid e-mail address")) {
                    self.email.becomeFirstResponder()
                }
            }
        }
    }
    
    @IBAction func switchClick(_ sender: UIButton) {
        self.childSwitch.setOn(!self.childSwitch.isOn, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lastName.text = self.last
        self.firstName.text = self.first
        self.email.text = self.mail
        self.childSwitch.isOn = true
        self.childSwitch.isHidden = false
        self.childButton.isHidden = false
        //self.addButton.hidden = false
        if self.props?["child_required"] as? Bool == true {
            self.childSwitch.isOn = true
            self.childSwitch.isHidden = true
            self.childButton.isHidden = true
            //self.addButton.hidden = false
        }
        if self.props?["child_disabled"] as? Bool == true {
            self.firstName.placeholder = NSLocalizedString("First name", comment: "Placeholder text for first name registration")
            self.childSwitch.isOn = false
            self.childSwitch.isHidden = true
            self.childButton.isHidden = true
            //self.addButton.hidden = true
        }
        self.lastName!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.lastName!.delegate = self
        self.firstName!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.firstName!.delegate = self
        self.email!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.email!.delegate = self
        self.password!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.password!.delegate = self
        IQKeyboardManager.sharedManager().enable = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doMain {
            self.registerClick(self.registerButton)
        }
        return true
    }

    func done() {
        self.registerButton.isEnabled = true
        self.registerButton.alpha = 1
        self.registerButton.setFontColor(saucyTheme.lightColor)
        self.registerButton.setBackground(saucyTheme.secondary)
    }
    
    func registerUser() {
        let registrationInfo: Dictionary<String,AnyObject?> = [
            "code" : self.registrationCode as Optional<AnyObject>,
            "first" : self.first as Optional<AnyObject>,
            "last" : self.last as Optional<AnyObject>,
            "email" : self.mail as Optional<AnyObject>,
            "password" : self.pass as Optional<AnyObject>,
            "hasChild" : (self.child == true ? "true" : "false") as AnyObject,
            "csrf_token" : self.token as AnyObject
        ]
        doMain {
            self.registerButton.isEnabled = false
            self.registerButton.alpha = 0.85
            self.registerButton.setFontColor(saucyTheme.fontColor)
            self.registerButton.setBackground(saucyTheme.lightColor)
        }
        self.showNoConnectionDialog {
            var redirect = false
            postJson("/account/create", registrationInfo, error: {_ in
                doMain(self.done)
                }, redirect: {(path: String) in
                    // check for register child redirect
                    if path == "/register/child" {
                        redirect = true
                        UserLoginController.home {
                            self.performSegue(withIdentifier: "addChild", sender: self)
                            doMain (self.done)
                        }
                    }
                    // login was a success!
                    if path == "/home" {
                        redirect = true
                        AppDelegate.goHome(self, true) {_ in
                            doMain (self.done)
                        }
                    }
                    if path == "/login" {
                        redirect = true
                        let _ = self.showDialog(NSLocalizedString("Existing account found", comment: "Can't create account because same email address is already used"), NSLocalizedString("Log in instead", comment: "Log in instead of registering for a new account")) {
                            self.performSegue(withIdentifier: "login", sender: self)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
}

extension UIViewController {
    
    func isValidEmail(_ testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
