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
            inputText.isSecureTextEntry = true
            inputText.placeholder = NSLocalizedString("New password", comment: "Placeholder for reset password after the token has been retrieved from email.")
            self.inputText!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
            self.inputText!.delegate = self
       }
    }
    
    @IBAction func lastClick() {
        CardSegue.transitionManager.transitioning = true
        if self.presentingViewController is UserLoginController {
            self.performSegue(withIdentifier: "login", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "home", sender: self)
        }
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doMain {
            self.resetClick(self.resetButton)
        }
        return true
    }

    func done() {
        self.resetButton.isEnabled = true
        self.resetButton.alpha = 1
        self.resetButton.setFontColor(saucyTheme.lightColor)
        self.resetButton.setBackground(saucyTheme.secondary)
    }
    
    @IBAction func resetClick(_ sender: UIButton) {
        self.inputText.resignFirstResponder()
        doMain {
            self.resetButton.isEnabled = false
            self.resetButton.alpha = 0.85
            self.resetButton.setFontColor(saucyTheme.fontColor)
            self.resetButton.setBackground(saucyTheme.lightColor)
        }
        if self.token != nil {
            self.password = self.inputText.text
            self.showNoConnectionDialog({
                postJson("/reset", [
                    "email": self.mail as Optional<AnyObject>,
                    "token": self.token as Optional<AnyObject>,
                    "newPass": self.password as Optional<AnyObject>
                    ], redirect: {(path: String) in
                    if path == "/home" {
                        AppDelegate.goHome(self)
                    }
                })
            })
        }
        else {
            self.mail = self.inputText.text
            self.showNoConnectionDialog {
                postJson("/reset", ["email": self.mail as Optional<AnyObject>], error: {_ in
                    self.showDialog(NSLocalizedString("Invalid e-mail address", comment: "Message for when someone logs in with invalid email."), NSLocalizedString("Ok", comment: "Button for when users log in with invalid e-mail address")) {
                        doMain(self.done)
                        self.inputText.becomeFirstResponder()
                    }
                }) {(json) in
                    self.showDialog(NSLocalizedString("Your password has been reset.  Please check your email.", comment: "Password reset confirmation message"), NSLocalizedString("Go home", comment: "Return to the landing page after password is reset")) {
                        doMain(self.done)
                        // password resets don't change users until code is entered so don't bother refetching
                        AppDelegate.goHome(self)
                    }
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
}
