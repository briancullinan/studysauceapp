//
//  UserInviteController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserInviteController : UIViewController, UITextFieldDelegate {
    
    internal var first: String?
    internal var last: String?
    internal var mail: String?
    internal var regCode: String?
    internal var token: String?
    internal var props: NSDictionary?

    @IBOutlet weak var registrationCode: UITextField!
    @IBOutlet weak var inviteButton: UIButton!
    
    @IBAction func returnToInvite(segue: UIStoryboardSegue) {
        
    }

    @IBAction func codeButton(sender: UIButton) {
        self.showDialog(NSLocalizedString("Ask your sponsor for an access code or contact us at admin@studysauce.com", comment: "No code instructions for contacting sponsor"), NSLocalizedString("Ok", comment: "Ok button for no code message"))
    }
    
    @IBAction func submitCode(sender: UIButton) {
        self.registrationCode.resignFirstResponder()
        self.regCode = self.registrationCode.text
        if self.regCode == "" {
            return
        }
        
        self.showNoConnectionDialog({
            self.getInvite()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registrationCode!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.registrationCode!.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doMain {
            self.submitCode(self.inviteButton)
        }
        return true
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? UserRegisterController {
            vc.registrationCode = self.regCode
            vc.first = self.first
            vc.last = self.last
            vc.mail = self.mail
            vc.token = self.token
            vc.props = self.props
        }
    }

    func done() {
        self.inviteButton.enabled = true
        self.inviteButton.alpha = 1
        self.inviteButton.setFontColor(saucyTheme.lightColor)
        self.inviteButton.setBackground(saucyTheme.secondary)
    }
    
    func getInvite() -> Void {
        doMain {
            self.inviteButton.enabled = false
            self.inviteButton.alpha = 0.85
            self.inviteButton.setFontColor(saucyTheme.fontColor)
            self.inviteButton.setBackground(saucyTheme.lightColor)
        }
        postJson("/register", ["_code": self.regCode], error: {(code) in
            doMain(self.done)
            if code == 404 {
                self.showDialog(NSLocalizedString("No matching code found", comment: "Failed to find the invite code"), NSLocalizedString("Try again", comment: "Try to enter a different invite code"))
            }
            }, redirect: {(path) in
                doMain(self.done)
                if path == "/home" {
                    AppDelegate.goHome(self, true)
                }
            }) {(json) in
                doMain(self.done)
                self.first = json["first"] as? String
                self.last = json["last"] as? String
                self.mail = json["email"] as? String
                self.token = json["csrf_token"] as? String
                self.props = json["properties"] as? NSDictionary
                
                self.performSegueWithIdentifier("register", sender: self)
        }
    }
    
}