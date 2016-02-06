//
//  UserRegisterController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension CollectionType where Generator.Element == NSHTTPCookie {
    func getJSON() -> [Dictionary<String,AnyObject>] {
        let result = self.map { (c: NSHTTPCookie) -> Dictionary<String,AnyObject> in
            var prop = c.properties
            prop!["HttpOnly"] = false
            prop!["Expires"] = (prop!["Expires"] as! NSDate).toRFC()
            return prop!
        }
        return result
    }
}

class UserLoginController : UIViewController, UITextFieldDelegate {
    
    internal static var token: String?
    internal var email: String?
    internal var pass: String?
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func loginClick(sender: UIButton) {
        self.email = username.text
        self.pass = password.text
        self.authenticate()
        self.username.resignFirstResponder()
        self.password.resignFirstResponder()
    }
    
    @IBAction func returnToLogin(segue: UIStoryboardSegue) {
        
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showNoConnectionDialog({
            UserLoginController.login()
        })
        self.password!.addDoneOnKeyboardWithTarget(self, action: Selector("loginClick:"))
        self.password!.delegate = self
        self.username!.addDoneOnKeyboardWithTarget(self, action: Selector("loginClick:"))
        self.username!.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doMain {
            self.loginClick(self.loginButton)
        }
        return true
    }
    
    internal static func logout(done: () -> Void = {}) {
        getJson("/logout", done: {json in
            done()
        })
    }
    
    internal static func processUsers(json: NSDictionary) -> Void {
        if let email = json["email"] as? String {
            let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies?.getJSON()
            let user = UserLoginController.getUserByEmail(email)
            user.id = json["id"] as? NSNumber
            user.first = json["first"] as? String
            user.last = json["last"] as? String
            let properties = json["properties"] as? NSDictionary
            user.setProperty("session", cookies)
            for p in properties?.allKeys ?? [] {
                user.setProperty("\(p)", properties?.valueForKey("\(p)"))
            }
            user.created = NSDate.parse(json["created"] as? String)
            user.roles = json["roles"] as? String
            for c in json["children"] as? [NSDictionary] ?? [] {
                self.processUsers(c)
            }
        }
        
        AppDelegate.saveContext()
    }
    
    internal static func home(done: () -> Void = {}) {
        
        getJson("/home", done: {
            if let json = $0 as? NSDictionary {
                
                let allFinished = {
                    AppDelegate.performContext {
                        if let email = json["email"] as? String {
                            
                            if let child = AppDelegate.list(User.self).filter({!$0.hasRole("ROLE_PARENT")}).last where AppDelegate.instance().user == nil {
                                AppDelegate.instance().user = child
                            }
                            else {
                                AppDelegate.instance().user = UserLoginController.getUserByEmail(email)
                            }
                            
                        }
                        
                        doMain(done)
                    }
                }
                
                
                AppDelegate.performContext({
                    if json["csrf_token"] as? String != nil {
                        self.token = json["csrf_token"] as? String
                    }
                    if let _ = json["email"] as? String {
                        // cookie value
                        UserLoginController.processUsers(json)
                        
                        // check if any users have marked reset database
                        if self.checkForReset(allFinished) {
                            return
                        }
                    }
                    doMain(allFinished)
                })
            }
        })
    }
    
    private static func checkForReset(allFinished: () -> Void) -> Bool {
        let url = AppDelegate.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataDemo.sqlite") as NSURL
        let users = AppDelegate.list(User.self)
        for u in users {
            if let resetTime = NSDate.parse(u.getProperty("reset_db") as? String) {
                if let fileTime = try? NSFileManager.defaultManager().attributesOfItemAtPath(url.path!)[NSFileCreationDate] as? NSDate {
                    if resetTime > fileTime! {
                        let usersDict: [NSDictionary] = users.map({
                            return [
                                "id": $0.id!,
                                "email" : $0.email!,
                                "first" : $0.first!,
                                "last" : $0.last!,
                                "properties" : $0.getAllProperties()!,
                                "roles" : $0.roles!
                            ]
                        })
                        
                        AppDelegate.resetLocalStore()
                        
                        AppDelegate.performContext {
                            for u in usersDict {
                                UserLoginController.processUsers(u)
                            }
                            doMain(allFinished)
                        }
                        return true
                    }
                }
            }
        }
        return false
    }
    
    internal static func login(done: () -> Void = {}) {
        getJson("/login", done: {
            if let json = $0 as? NSDictionary {
                // TODO: create user entity in database
                if json["csrf_token"] as? String != nil {
                    self.token = json["csrf_token"] as? String
                }
                doMain(done)
            }
        })
    }
    
    static func getUserByEmail(email: String) -> User {
        var user: User? = nil
        for u in AppDelegate.list(User.self) {
            if u.email == email {
                user = u
                break
            }
        }
        if user == nil {
            user = AppDelegate.insert(User.self)
        }
        user!.email = email
        return user!
    }
    
    func done() {
        self.loginButton.enabled = true
        self.loginButton.alpha = 1
        self.loginButton.setFontColor(saucyTheme.lightColor)
        self.loginButton.setBackground(saucyTheme.secondary)
    }
    
    func authenticate() {
        var redirect = false
        doMain {
            self.loginButton.enabled = false
            self.loginButton.alpha = 0.85
            self.loginButton.setFontColor(saucyTheme.fontColor)
            self.loginButton.setBackground(saucyTheme.lightColor)
        }
        postJson("/authenticate",
            params: [
                "email"        : self.email,
                "pass"         : self.pass,
                "_remember_me" : "on",
                "csrf_token"   : UserLoginController.token]
            , error: {_ in
                doMain(self.done)
            }, redirect: {(path) in
                if path == "/login" {
                    redirect = true
                    self.showDialog(NSLocalizedString("Incorrect password", comment: "When user log in fails because of incorrect password."), button: NSLocalizedString("Try again", comment: "Option to try again when user log in fails")) {
                        doMain(self.done)
                    }
                }
                else if path == "/home" {
                    redirect = true
                    AppDelegate.goHome(self, true) {_ in
                        doMain(self.done)
                    }
                }
                else {
                    doMain(self.done)
                }
            }, done: {(json) in
                if !redirect {
                    doMain(self.done)
                }
                if json["csrf_token"] as? String != nil {
                        UserLoginController.token = json["csrf_token"] as? String
                    }
            })
    }
}