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
    internal var childrenCount = 1
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var childSwitch: UISwitch!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var childHeight: NSLayoutConstraint!
    @IBOutlet weak var children: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addChild(sender: UIButton) {
        self.childrenCount++
        self.childHeight.constant = CGFloat(self.childrenCount * 60) * saucyTheme.multiplier()
        self.children.reloadData()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60 * saucyTheme.multiplier()
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

        if self.first != "" && self.last != "" && self.mail != "" && self.password != "" {
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
            children.hidden = false
            addButton.hidden = false
        }
        else
        {
            children.hidden = true
            addButton.hidden = true
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lastName.text = self.last
        self.firstName.text = self.first
        self.email.text = self.mail
        self.childHeight.constant = CGFloat(self.childrenCount * 60) * saucyTheme.multiplier()
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
                registrationInfo["childFirst"] = ($0 ~> (UITextField.self ~* T.nthOfType(0))).first!.text
                registrationInfo["childLast"] = ($0 ~> (UITextField.self ~* T.nthOfType(1))).first!.text
            }
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
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true)
    }
}