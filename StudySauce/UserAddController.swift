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
    internal var code: String?
    @IBOutlet weak var childFirst: UITextField!
    @IBOutlet weak var childLast: UITextField!
    @IBOutlet weak var inviteCode: TextField!
    internal var token: String?

    func lastClick() {
        CardSegue.transitionManager.transitioning = true
        let last = self.presentingViewController
            last?.dismissViewControllerAnimated(true, completion: {
            last?.viewDidAppear(true)
        })
    }
    
    @IBAction func backClick(sender: UIButton) {
        self.lastClick()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func addClick(sender: UIButton) {
        self.childFirst.resignFirstResponder()
        self.childLast.resignFirstResponder()
        self.childFirstName = self.childFirst.text
        self.childLastName = self.childLast.text
        self.code = self.inviteCode.text
        if self.childFirstName != "" && self.childLastName != "" && self.code != "" {
            let registrationInfo: Dictionary<String,AnyObject?> = [
                "csrf_token" : self.token,
                "childFirst" : self.childFirstName,
                "childLast" : self.childLastName,
                "_code" : self.code
            ]

            self.showNoConnectionDialog({
                postJson("/account/create", params: registrationInfo, error: {code in
                    if code == 404 {
                        self.showDialog(NSLocalizedString("Invite code not found", comment: "Message for invite code not found when adding a child user"), button: NSLocalizedString("Try again", comment: "Try again button for adding a child when invite code is not found"))
                    }
                    }, redirect: {(path) in
                    if path == "/home" {
                        UserLoginController.home { () -> Void in
                            AppDelegate.performContext {
                                let newUser = AppDelegate.list(User.self).filter({$0.created != nil }).maxElement {(x, y) in
                                    return x.created! <= y.created!
                                }
                                AppDelegate.instance().user = newUser
                                doMain {
                                    self.lastClick()
                                }
                            }
                        }
                    }
                })
            })
        }
    }
    
}