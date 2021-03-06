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
import IQKeyboardManagerSwift

extension Collection where Iterator.Element == HTTPCookie {
    func getJSON() -> [Dictionary<String, AnyObject>] {
        let result = self.map { (c: HTTPCookie) -> Dictionary<String, AnyObject> in
            let prop = c.properties
            var saveCookie = [String:Any]()
            for p in prop! {
                if p.key == HTTPCookiePropertyKey(rawValue: "HttpOnly") {
                    saveCookie[p.key.rawValue] = false
                }
                else if p.key == HTTPCookiePropertyKey(rawValue: "Expires") {
                    saveCookie[p.key.rawValue] = (p.value as? Date)?.toRFC()
                }
                else {
                    saveCookie[p.key.rawValue] = "\(p.value)"
                }
            }
            return saveCookie as [String:AnyObject]
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
    
    @IBAction func loginClick(_ sender: UIButton) {
        self.email = username.text
        self.pass = password.text
        self.username.resignFirstResponder()
        self.password.resignFirstResponder()
        
        if self.isValidEmail(self.email!) {
            self.authenticate()
        }
        else {
            let _ = self.showDialog(NSLocalizedString("Invalid e-mail address", comment: "Message for when someone logs in with invalid email."), NSLocalizedString("Ok", comment: "Button for when users log in with invalid e-mail address")) {
                self.username.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func returnToLogin(_ segue: UIStoryboardSegue) {
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showNoConnectionDialog({
            UserLoginController.login()
        })
        self.password!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.password!.delegate = self
        self.username!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.username!.delegate = self
        IQKeyboardManager.sharedManager().enable = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doMain {
            self.loginClick(self.loginButton)
        }
        return true
    }
    
    internal static func logout(_ done: @escaping () -> Void = {}) {
        getJson("/logout") {json in
            AppDelegate.instance().user = nil
            let _ = AppDelegate.resetLocalStore()
            done()
        }
    }
    
    internal static func filterDomain(_ users: [User]) -> [User] {
        return users.filter{
            if let data = Data.init(base64Encoded: $0.getProperty("session") as! String) {
                let cookies = NSKeyedUnarchiver.unarchiveObject(with: data) as! [[String : AnyObject]]

                return cookies.filter{
                    return "\($0["Domain"]!)" == AppDelegate.domain}.count > 0
            }
            return false
        }
    }

    internal static func processUsers(_ json: NSDictionary) -> Void {
        if let email = json["email"] as? String {
            let cookies = HTTPCookieStorage.shared.cookies?.getJSON()
            let user = UserLoginController.getUserByEmail(email)
            user.id = json["id"] as? NSNumber
            user.first = json["first"] as? String
            user.last = json["last"] as? String
            let properties = json["properties"] as? NSDictionary
            for p in properties?.allKeys ?? [] {
                user.setProperty("\(p)", properties?.value(forKey: "\(p)") as AnyObject?)
            }
            user.setProperty("session", cookies as AnyObject?)
            user.created = Date.parse(json["created"] as? String)
            user.roles = json["roles"] as? String
            for c in json["children"] as? [NSDictionary] ?? [] {
                self.processUsers(c)
            }
        }
        
        AppDelegate.saveContext()
    }
    
    internal static func home(_ done: @escaping () -> Void = {}) {
        
        getJson("/home") {
            if let json = $0 as? NSDictionary {
                
                let allFinished = {
                    AppDelegate.performContext {
                        if let email = json["email"] as? String {
                            
                            if let child = AppDelegate.list(User.self).filter({!$0.hasRole("ROLE_PARENT")}).last , AppDelegate.instance().user == nil {
                                AppDelegate.instance().user = child
                            }
                            else {
                                AppDelegate.instance().user = UserLoginController.getUserByEmail(email)
                            }
                            
                        }
                        
                        doMain(done)
                    }
                }
                
                
                AppDelegate.performContext {
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
                }
            }
        }
    }
    
    fileprivate static func checkForReset(_ allFinished: @escaping () -> Void) -> Bool {
        let url = AppDelegate.applicationDocumentsDirectory.appendingPathComponent("StudySauceCache.sqlite") as URL
        let users = AppDelegate.list(User.self)
        for u in users {
            if let resetTime = Date.parse(u.getProperty("reset_db") as? String) {
                if let fileTime = try? FileManager.default.attributesOfItem(atPath: url.path)[FileAttributeKey.creationDate] as? Date {
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
                        
                        let _ = AppDelegate.resetLocalStore()
                        
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
    
    internal static func login(_ done: @escaping () -> Void = {}) {
        getJson("/login") {
            if let json = $0 as? NSDictionary {
                // TODO: create user entity in database
                if json["csrf_token"] as? String != nil {
                    self.token = json["csrf_token"] as? String
                }
                doMain(done)
            }
        }
    }
    
    static func getUserByEmail(_ email: String) -> User {
        var user: User? = nil
        for u in UserLoginController.filterDomain(AppDelegate.list(User.self)) {
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
        self.loginButton.isEnabled = true
        self.loginButton.alpha = 1
        self.loginButton.setFontColor(saucyTheme.lightColor)
        self.loginButton.setBackground(saucyTheme.secondary)
    }
    
    func authenticate() {
        var redirect = false
        doMain {
            self.loginButton.isEnabled = false
            self.loginButton.alpha = 0.85
            self.loginButton.setFontColor(saucyTheme.fontColor)
            self.loginButton.setBackground(saucyTheme.lightColor)
        }
        postJson("/authenticate", [
                "email"        : self.email as Optional<AnyObject>,
                "pass"         : self.pass as Optional<AnyObject>,
                "_remember_me" : "on" as Optional<AnyObject>,
                "csrf_token"   : UserLoginController.token as Optional<AnyObject>]
            , error: {_ in
                
                doMain(self.done)
            }, redirect: {(json: AnyObject) in
                if json["redirect"] as? String == "/login" && (json["exception"] as? String)?.contains("does not exist") == true {
                    redirect = true
                    let _ = self.showDialog(NSLocalizedString("User does not exist", comment: "When user log in fails because account does not exist."), NSLocalizedString("Try again", comment: "Option to try again when user does not exist")) {
                        doMain(self.done)
                    }
                }
                else if json["redirect"] as? String == "/login" {
                    redirect = true
                    let _ = self.showDialog(NSLocalizedString("Incorrect password", comment: "When user log in fails because of incorrect password."), NSLocalizedString("Try again", comment: "Option to try again when user log in fails")) {
                        doMain(self.done)
                    }
                }
                else if json["redirect"] as? String == "/home" {
                    redirect = true
                    AppDelegate.goHome(self, true) {_ in
                        doMain(self.done)
                    }
                }
                else {
                    doMain(self.done)
                }
            }) {(json) in
                if !redirect {
                    doMain(self.done)
                }
                if json["csrf_token"] as? String != nil {
                        UserLoginController.token = json["csrf_token"] as? String
                    }
            }
    }
}
