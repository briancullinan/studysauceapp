//
//  UserAddController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 12/21/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserAddController : UIViewController {
    internal var childFirstName: String?
    internal var childLastName: String?
    @IBOutlet weak var childFirst: UITextField!
    @IBOutlet weak var childLast: UITextField!
    internal var token: String?

    @IBAction func backClick(sender: UIButton) {
        if let _ = self.presentingViewController as? UserSettingsContainerController {
            self.performSegueWithIdentifier("settings", sender: self)
        }
        else {
            self.performSegueWithIdentifier("switch", sender: self)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func addClick(sender: UIButton) {
        self.childFirst.resignFirstResponder()
        self.childLast.resignFirstResponder()
        self.childFirstName = self.childFirst.text
        self.childLastName = self.childLast.text
        if self.childFirstName != "" && self.childLastName != "" {
            let registrationInfo: Dictionary<String,AnyObject?> = [
                "csrf_token" : self.token,
                "childFirst" : self.childFirstName,
                "childLast" : self.childLastName
            ]

            self.showNoConnectionDialog({
                postJson("/account/create", params: registrationInfo, redirect: {(path) in
                    if path == "/home" {
                        UserLoginController.home { () -> Void in
                            AppDelegate.performContext {
                                let newUser = AppDelegate.list(User.self).filter({$0.created != nil }).maxElement {(x, y) in
                                    return x.created! <= y.created!
                                }
                                AppDelegate.instance().user = newUser
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.backClick(sender)
                                })
                            }
                        }
                    }
                })
            })
        }
    }
    
}