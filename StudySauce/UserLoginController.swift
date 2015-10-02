//
//  UserRegisterController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserLoginController : UIViewController {
    
    internal var token: String?
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
        
        self.login()
    }
    
    func login() {
        let url: NSURL = NSURL(string: "https://cerebro.studysauce.com/login?XDEBUG_SESSION_START=PHPSTORM")!
        let request = NSMutableURLRequest(URL: url)
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
                    if json["csrf_token"] as? String != nil {
                        self.token = json["csrf_token"] as? String
                    }
                    if json["error"] as? String != nil {
                        if json["error"] as! String == "Bad credentials" {
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
    
    func authenticate() {
        //let code = self.registrationCode!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let pass = self.pass!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let email = self.email!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let token = self.token!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let url: NSURL = NSURL(string: "https://cerebro.studysauce.com/authenticate?XDEBUG_SESSION_START=PHPSTORM")!
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
                        self.performSegueWithIdentifier("home", sender: self)
                    }
                    if json["redirect"] as? String != nil && json["redirect"] as! String == "/login" {
                        self.login()
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