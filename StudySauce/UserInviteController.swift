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
        self.getInvite()
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
        let url: NSURL = NSURL(string: "https://cerebro.studysauce.com/register?_code=\(encoded)")!
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if error != nil {
                NSLog("\(error?.description)")
            }
            if (response as? NSHTTPURLResponse)?.statusCode == 404 {
                dispatch_async(dispatch_get_main_queue(), {
                    return self.performSegueWithIdentifier("error404", sender: self)
                })
                return
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
                    self.token = json["csrf_token"] as? String
                    if json["redirect"] as? String == "/home" {
                        self.mail = json["email"] as? String
                        return self.performSegueWithIdentifier("home", sender: self)
                    }
                    if json["activated"] as? Bool != nil {
                        self.mail = json["email"] as? String
                        return self.performSegueWithIdentifier("error301", sender: self)
                    }
                    if json["code"] as? String == nil {
                        return self.performSegueWithIdentifier("error404", sender: self)
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