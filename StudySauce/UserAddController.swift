//
//  UserAddController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 12/21/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserAddController : UIViewController, UITextFieldDelegate {
    internal var childFirstName: String?
    internal var childLastName: String?
    internal var code: String?
    @IBOutlet weak var childFirst: UITextField!
    @IBOutlet weak var childLast: UITextField!
    @IBOutlet weak var inviteCode: TextField!
    @IBOutlet weak var addButton: UIButton!
    internal var token: String?
    
    @IBAction func backClick(sender: UIButton) {
        CardSegue.transitionManager.transitioning = true
        let last = self.presentingViewController
        last?.dismissViewControllerAnimated(true, completion: {
            last?.viewDidAppear(true)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.inviteCode!.addDoneOnKeyboardWithTarget(self, action: Selector("addClick:"))
        self.inviteCode!.delegate = self
        self.childFirst!.addDoneOnKeyboardWithTarget(self, action: Selector("addClick:"))
        self.childFirst!.delegate = self
        self.childLast!.addDoneOnKeyboardWithTarget(self, action: Selector("addClick:"))
        self.childLast!.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doMain {
            self.addClick(self.addButton)
        }
        return true
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func done() {
        doMain {
            self.addButton.enabled = true
            self.addButton.alpha = 1
            self.addButton.setFontColor(saucyTheme.lightColor)
            self.addButton.setBackground(saucyTheme.secondary)
        }
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
            doMain {
                self.addButton.enabled = false
                self.addButton.alpha = 0.85
                self.addButton.setFontColor(saucyTheme.fontColor)
                self.addButton.setBackground(saucyTheme.lightColor)
            }
            self.showNoConnectionDialog({
                postJson("/account/create", params: registrationInfo,
                    done: {_ in
                        self.done()
                    }, error: {code in
                    self.done()
                    if code == 404 {
                        self.showDialog(NSLocalizedString("Invite code not found", comment: "Message for invite code not found when adding a child user"), button: NSLocalizedString("Try again", comment: "Try again button for adding a child when invite code is not found"))
                    }
                    }, redirect: {(path) in
                        self.done()
                    if path == "/home" {
                        UserLoginController.home { () -> Void in
                            AppDelegate.performContext {
                                let newUser = AppDelegate.list(User.self).filter({$0.created != nil }).maxElement {(x, y) in
                                    return x.created! <= y.created!
                                }
                                AppDelegate.instance().user = newUser
                                doMain {
                                    let last = self.presentingViewController
                                    last?.dismissViewControllerAnimated(true, completion: {
                                        AppDelegate.goHome(last)
                                    })
                                }
                            }
                        }
                    }
                })
            })
        }
    }
    
}