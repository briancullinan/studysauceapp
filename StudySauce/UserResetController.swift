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

class UserResetController: UIViewController, UITextFieldDelegate {
    
    var mail: String? = nil
    var password: String? = nil
    internal var token: String? = nil
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if token != nil {
            inputText.secureTextEntry = true
            inputText.placeholder = NSLocalizedString("New password", comment: "Placeholder for reset password after the token has been retrieved from email.")
            self.inputText!.addDoneOnKeyboardWithTarget(self, action: Selector("resetClick:"))
            self.inputText!.delegate = self
       }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doMain {
            self.resetClick(self.resetButton)
        }
        return true
    }

    func done() {
        self.resetButton.enabled = true
        self.resetButton.alpha = 1
        self.resetButton.setFontColor(saucyTheme.lightColor)
        self.resetButton.setBackground(saucyTheme.secondary)
    }
    
    @IBAction func resetClick(sender: UIButton) {
        self.inputText.resignFirstResponder()
        doMain {
            self.resetButton.enabled = false
            self.resetButton.alpha = 0.85
            self.resetButton.setFontColor(saucyTheme.fontColor)
            self.resetButton.setBackground(saucyTheme.lightColor)
        }
        if self.token != nil {
            self.password = self.inputText.text
            self.showNoConnectionDialog({
                postJson("/reset", params: ["email": self.mail, "token": self.token, "newPass": self.password], redirect: {(path) in
                    if path == "/home" {
                        AppDelegate.goHome(self)
                    }
                })
            })
        }
        else {
            self.mail = self.inputText.text
            self.showNoConnectionDialog({
                postJson("/reset", params: ["email": self.mail], done: {(json) in
                    self.showDialog(NSLocalizedString("Your password has been reset.  Please check your email.", comment: "Password reset confirmation message"), button: NSLocalizedString("Go home", comment: "Return to the landing page after password is reset"), done: {
                        doMain(self.done)
                            // password resets don't change users until code is entered so don't bother refetching
                            AppDelegate.goHome(self)
                        
                    })
                })
            })
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true)
    }
    
}