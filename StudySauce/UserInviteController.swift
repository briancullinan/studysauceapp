//
//  UserInviteController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserInviteController : UIViewController {
    
    internal var first: String?
    internal var last: String?
    internal var mail: String?
    internal var regCode: String?
    internal var token: String?

    @IBOutlet weak var registrationCode: UITextField!
    
    @IBAction func submitCode(sender: UIButton) {
        self.regCode = self.registrationCode.text
        self.showNoConnectionDialog({
            self.getInvite()
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? UserRegisterController {
            vc.registrationCode = self.registrationCode.text
            vc.first = self.first
            vc.last = self.last
            vc.mail = self.mail
            vc.token = self.token
        }
    }
    
    func getInvite() -> Void {
        let encoded = self.regCode!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let url = AppDelegate.studySauceCom("/register?_code=\(encoded)")
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                NSLog("\(error?.description)")
            }
            if (response as? NSHTTPURLResponse)?.statusCode == 404 {
                self.showDialog("No matching code found", button: "Try again")
                return
            }
            if (response as? NSHTTPURLResponse)?.statusCode == 301 {
                self.showDialog("Existing account found", button: "Log in instead", done: {
                    self.performSegueWithIdentifier("login", sender: self)
                    return false
                })
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                dispatch_async(dispatch_get_main_queue(), {
                    // change this if we want to register without a code
                    self.token = json["csrf_token"] as? String
                    if json["redirect"] as? String == "/home" {
                        self.mail = json["email"] as? String
                        UserLoginController.login({
                            return self.performSegueWithIdentifier("home", sender: self)
                        })
                        return
                    }
                    if json["activated"] as? Bool != nil {
                        self.mail = json["email"] as? String
                        self.showDialog("Existing account found", button: "Log in instead", done: {
                            self.performSegueWithIdentifier("login", sender: self)
                            return true
                        })
                        return
                    }
                    if json["code"] as? String == nil {
                        self.showDialog("No matching code found", button: "Try again")
                        return
                    }
                    self.first = json["first"] as? String
                    self.last = json["last"] as? String
                    self.mail = json["email"] as? String
                    self.performSegueWithIdentifier("register", sender: self)
                })
            }
            catch let error as NSError {
                NSLog("\(error.description)")
            }
        })
        task.resume()
    }
}