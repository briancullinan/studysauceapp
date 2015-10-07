//
//  UserRegisterController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserRegisterController : UIViewController {
    
    internal var registrationCode: String?
    internal var first: String?
    internal var last: String?
    internal var mail: String?
    internal var token: String?
    
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var childSwitch: UISwitch!
    @IBOutlet weak var childFirst: UITextField!
    @IBOutlet weak var childLast: UITextField!
    
    @IBAction func registerClick(sender: UIButton) {
        self.first = self.firstName.text
        self.mail = self.email.text
        self.last = self.lastName.text
        self.registerUser()
    }
    
    @IBAction func childSwitchOn(sender: AnyObject) {
        
        if childSwitch.on
        {
            childFirst.hidden = false
            childLast.hidden = false
        }
        
        else
        {
            childFirst.hidden = true
            childLast.hidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lastName.text = self.last
        firstName.text = self.first
        email.text = self.mail
    }
    
    func registerUser() {
        let code = self.registrationCode!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let first = self.first!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let last = self.last!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let email = self.mail!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let token = self.token!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let url = AppDelegate.studySauceCom("/account/create")
        let postData = "code=\(code)&first=\(first)&last=\(last)&email=\(email)&csrf_token=\(token)".dataUsingEncoding(NSUTF8StringEncoding)
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
                })
            }
            catch let error as NSError {
                NSLog("\(error.description)")
            }
        })
        task.resume()
    }
    
}