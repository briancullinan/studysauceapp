//
//  UserRegisterController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserRegisterController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    internal var registrationCode: String?
    internal var first: String?
    internal var last: String?
    internal var mail: String?
    internal var child: Bool?
    internal var token: String?
    internal var pass: String?
    internal var props: NSDictionary?
    internal var childrenCount = 1 {
        didSet {
            self.childHeight.constant = CGFloat(self.childrenCount) * (saucyTheme.textSize + saucyTheme.padding * 2)
            self.children.reloadData()
        }
    }
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var childSwitch: UISwitch!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var childHeight: NSLayoutConstraint!
    @IBOutlet weak var children: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var childButton: UIButton!
    
    @IBAction func addChild(sender: UIButton) {
        self.childrenCount++
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return saucyTheme.textSize + saucyTheme.padding * 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.childrenCount
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

        if self.first != "" && self.last != "" && self.mail != "" && self.password != "" && self.isValidEmail(self.mail!) {
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
            self.children.hidden = false
            //self.addButton.hidden = false
        }
        else
        {
            self.children.hidden = true
            //self.addButton.hidden = true
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lastName.text = self.last
        self.firstName.text = self.first
        self.email.text = self.mail
        self.childHeight.constant = CGFloat(self.childrenCount) * (saucyTheme.textSize + saucyTheme.padding * 2)
        self.childSwitch.on = true
        self.childSwitch.hidden = false
        self.childButton.hidden = false
        //self.addButton.hidden = false
        self.children.hidden = false
        if self.props?["child_required"] as? Bool == true {
            self.childSwitch.on = true
            self.childSwitch.hidden = true
            self.childButton.hidden = true
            self.children.hidden = false
            //self.addButton.hidden = false
        }
        if self.props?["child_disabled"] as? Bool == true {
            self.firstName.placeholder = NSLocalizedString("First name", comment: "Placeholder text for first name registration")
            self.childSwitch.on = false
            self.childSwitch.hidden = true
            self.childButton.hidden = true
            self.children.hidden = true
            //self.addButton.hidden = true
        }
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
            "pass" : self.pass,
            "csrf_token" : self.token
        ]
        if self.child == true {
            (self.view ~> UITableViewCell.self).each {
                registrationInfo["childFirst"] = ($0 ~> (UITextField.self ~* 1)).first!.text
                registrationInfo["childLast"] = ($0 ~> (UITextField.self ~* 2)).first!.text
            }
        }
        doMain {
            self.registerButton.enabled = false
            self.registerButton.alpha = 0.85
            self.registerButton.setFontColor(saucyTheme.fontColor)
            self.registerButton.setBackground(saucyTheme.lightColor)
        }
        self.showNoConnectionDialog({
            postJson("/account/create", params: registrationInfo, error: {_ in
                doMain(self.done)
                }, done: {_ in
                    doMain(self.done)
                }, redirect: {(path) in
                    doMain (self.done)
                    // login was a success!
                    if path == "/home" {
                        AppDelegate.goHome(self, true)
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
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true)
    }
}