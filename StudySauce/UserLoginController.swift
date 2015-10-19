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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showNoConnectionDialog({
            UserLoginController.login()
        })
    }
    
    internal static func login() {
        return self.login {()}
    }
    
    internal static func login(done: () -> Void) {
        let url = AppDelegate.studySauceCom("/login")
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                NSLog("\(error?.description)")
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                // TODO: create user entity in database
                if json["csrf_token"] as? String != nil {
                    self.token = json["csrf_token"] as? String
                }
                if json["email"] as? String != nil {
                    if let user = UserLoginController.getUserByEmail(json["email"] as? String) {
                        user.id = json["id"] as? NSNumber
                        user.first = json["first"] as? String
                        user.last = json["last"] as? String
                        (UIApplication.sharedApplication().delegate as! AppDelegate).user = user
                        AppDelegate.saveContext()
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    done()
                })
            }
            catch let error as NSError {
                NSLog("\(error.description)")
            }
        })
        task.resume()
    }
    
    static func getUserByEmail(email: String?) -> User? {
        var user: User? = nil
        do {
            if email != nil {
                if let moc = AppDelegate.getContext() {
                    let fetchRequest = NSFetchRequest(entityName: "User")
                    for u in try moc.executeFetchRequest(fetchRequest) as! [User] {
                        if u.email == email {
                            user = u
                            break
                        }
                    }
                    if user == nil {
                        user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: moc) as? User
                    }
                    user!.email = email
                }
            }
        }
        catch let error as NSError {
            NSLog("\(error.description)")
        }
        return user
    }
    
    func authenticate() {
        self.postJson("/authenticate",
            params: [
                "email"        : self.email,
                "pass"         : self.pass,
                "_remember_me" : "on",
                "csrf_token"   : UserLoginController.token]
            , redirect: {(path) in
                if path == "/login" {
                    self.showDialog("Incorrect password", button: "Try again")
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