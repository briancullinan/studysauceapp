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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserLoginController.login()
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
                if let moc = AppDelegate.getContext() {
                    if json["email"] as? String != nil {
                        var user: User? = nil
                        let fetchRequest = NSFetchRequest(entityName: "User")
                        for u in try moc.executeFetchRequest(fetchRequest) as! [User] {
                            if u.email == json["email"] as? String {
                                user = u
                            }
                        }
                        if user == nil {
                            user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: moc) as? User
                        }
                        user!.email = json["email"] as? String
                        user!.id = json["id"] as? NSNumber
                        user!.first = json["first"] as? String
                        user!.last = json["last"] as? String
                        (UIApplication.sharedApplication().delegate as! AppDelegate).user = user
                        try moc.save()
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
    
    func authenticate() {
        //let code = self.registrationCode!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let pass = self.pass!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let email = self.email!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let token = UserLoginController.token!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let url = AppDelegate.studySauceCom("/authenticate")
        let postData = "email=\(email)&pass=\(pass)&_remember_me=on&csrf_token=\(token)".dataUsingEncoding(NSUTF8StringEncoding)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(String(postData!.length), forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                NSLog("\(error?.description)")
            }
            if (response as? NSHTTPURLResponse)?.statusCode == 301 {
                dispatch_async(dispatch_get_main_queue(), {
                    return self.performSegueWithIdentifier("error301", sender: self)
                })
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                dispatch_async(dispatch_get_main_queue(), {
                    // change this if we want to register without a code
                    if json["redirect"] as? String != nil && json["redirect"] as! String == "/home" {
                        UserLoginController.login({
                            self.performSegueWithIdentifier("home", sender: self)
                        })
                    }
                    if json["csrf_token"] as? String != nil {
                        UserLoginController.token = json["csrf_token"] as? String
                    }
                    if json["exception"] as? String != nil {
                        if json["exception"] as! String == "Bad credentials" {
                            self.performSegueWithIdentifier("incorrect", sender: self)
                        }
                    }
                })
            }
            catch let error as NSError {
                NSLog("\(error.description)")
            }
        })
        task.resume()
    }
}