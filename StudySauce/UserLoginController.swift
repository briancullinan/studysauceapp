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

class UserLoginController : UIViewController {
    
    internal static var token: String?
    internal var email: String?
    internal var pass: String?
    
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
    }
    
    internal static func logout(done: () -> Void = {}) {
        getJson("/logout", done: {json in
            done()
        })
    }
    
    private static func processUsers(json: NSDictionary) -> Void {
        var ids = [NSNumber]()
        if let email = json["email"] as? String {
            let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies?.getJSON()
            let user = UserLoginController.getUserByEmail(email)
            user.id = json["id"] as? NSNumber
            ids.append(user.id!)
            user.first = json["first"] as? String
            user.last = json["last"] as? String
            user.setProperty("session", cookies)
            user.created = NSDate.parse(json["created"] as? String)
            for c in json["children"] as? [NSDictionary] ?? [] {
                let childEmail = c["email"] as? String
                if childEmail == nil {
                    continue
                }
                let child = UserLoginController.getUserByEmail(childEmail!)
                child.id = c["id"] as? NSNumber
                ids.append(child.id!)
                child.first = c["first"] as? String
                child.last = c["last"] as? String
                child.setProperty("session", cookies)
                child.created = NSDate.parse(c["created"] as? String)
            }
        }
        
        
        // remove packs that no longer exist
        for u in AppDelegate.list(User.self) {
            if ids.indexOf(u.id!) == nil {
                for up in u.user_packs?.allObjects as! [UserPack] {
                    AppDelegate.deleteObject(up)
                }
                for r in u.responses?.allObjects as! [Response] {
                    AppDelegate.deleteObject(r)
                }
                AppDelegate.deleteObject(u)
            }
        }

    }
    
    internal static func home(done: () -> Void = {}) {
        getJson("/home", done: {
            if let json = $0 as? NSDictionary {
                AppDelegate.performContext({
                    if json["csrf_token"] as? String != nil {
                        self.token = json["csrf_token"] as? String
                    }
                    if let email = json["email"] as? String {
                        // cookie value
                        UserLoginController.processUsers(json)
                        
                        AppDelegate.instance().user = UserLoginController.getUserByEmail(email)
                        AppDelegate.saveContext()
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        done()
                    })

                })
            }
        })
    }
    
    internal static func login(done: () -> Void = {}) {
        getJson("/login", done: {
            if let json = $0 as? NSDictionary {
                // TODO: create user entity in database
                if json["csrf_token"] as? String != nil {
                    self.token = json["csrf_token"] as? String
                }
                dispatch_async(dispatch_get_main_queue(), {
                    done()
                })
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
    
    func authenticate() {
        postJson("/authenticate",
            params: [
                "email"        : self.email,
                "pass"         : self.pass,
                "_remember_me" : "on",
                "csrf_token"   : UserLoginController.token]
            , redirect: {(path) in
                if path == "/login" {
                    self.showDialog(NSLocalizedString("Incorrect password", comment: "When user log in fails because of incorrect password."), button: NSLocalizedString("Try again", comment: "Option to try again when user log in fails"))
                }
                if path == "/home" {
                    self.goHome(true)
                }
            }, done: {(json) in
                if json?["csrf_token"] as? String != nil {
                        UserLoginController.token = json!["csrf_token"] as? String
                    }
            })
    }
}