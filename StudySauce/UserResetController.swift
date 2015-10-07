//
//  UserSettingsController.swift
//  StudySauce
//
//  Created by Stephen Houghton on 10/5/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class UserResetController: UIViewController {
    
    var mail: String? = nil
    @IBOutlet weak var email: UITextField!
    
    @IBAction func resetClick(sender: UIButton) {
        self.mail = email.text
        self.reset({
            self.performSegueWithIdentifier("reset", sender: self)
        })
    }
    
    func reset(done: () -> Void) -> Void {
        let email = self.mail!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        let url = AppDelegate.studySauceCom("/reset")
        let postData = "email=\(email)".dataUsingEncoding(NSUTF8StringEncoding)
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
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                // TODO: create user entity in database
                if json["csrf_token"] as? String != nil {
                    
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
}