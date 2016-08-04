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
    internal var token: String?
    var returnKeyHandler: IQKeyboardReturnKeyHandler? = nil
    @IBOutlet weak var childFirst: UITextField!
    @IBOutlet weak var childLast: UITextField!
    @IBOutlet weak var inviteCode: TextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var schoolSystem: TextField!
    @IBOutlet weak var schoolYear: TextField!
    @IBOutlet weak var schoolName: TextField!
    
    @IBAction func backClick(sender: UIButton) {
        CardSegue.transitionManager.transitioning = true
        let last = self.presentingViewController
        last?.dismissViewControllerAnimated(true, completion: {
            last?.viewDidAppear(true)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.childFirst!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.childFirst!.delegate = self
        self.childLast!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.childLast!.delegate = self
        self.schoolSystem.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.schoolSystem.delegate = self
        self.schoolYear.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.schoolYear.delegate = self
        self.schoolName.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.schoolName.delegate = self
        
        //IQKeyboardManager.sharedManager().enable = false
        //IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace = true
        //IQKeyboardManager.sharedManager().enableAutoToolbar = false
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        
        self.assignSelectKeyboard(self.schoolSystem)
        self.assignSelectKeyboard(self.schoolYear)
        self.assignSelectKeyboard(self.schoolName)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserAddController.reshowKeyboard), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func reshowKeyboard() {
        doMain {
            if self.switched != nil {
                let switchTo = self.switched!
                self.switched = nil
                switchTo.becomeFirstResponder()
                UIView.setAnimationsEnabled(true)
            }
        }
    }

    var switched: UITextField? = nil
    @IBAction func textFieldDidBeginEditing(textField: UITextField) {
        doMain {
            self.switched = textField
        }
    }
    
    @IBAction func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.schoolSystem || textField == self.schoolYear || textField == self.schoolName {
            UIView.setAnimationsEnabled(false)
            doMain {
                self.childFirst.resignFirstResponder()
                self.childLast.resignFirstResponder()
            }
        }
        else {
            self.switched = nil
        }
    }
    
    func assignSelectKeyboard(input: TextField) {
        input.tintColor = UIColor.clearColor()
        input.inputView = BasicKeyboardController.pickerKeyboard
        BasicKeyboardController.keyboardHeight = 20 * saucyTheme.multiplier() + saucyTheme.padding * 2
        BasicKeyboardController.keyboardSwitch = {
            input.inputView = $0
            input.reloadInputViews()
        }
        input.reloadInputViews()
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
        self.schoolSystem.resignFirstResponder()
        self.schoolYear.resignFirstResponder()
        self.schoolName.resignFirstResponder()
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
            self.showNoConnectionDialog {
                postJson("/account/create", registrationInfo,
                    error: {code in
                    self.done()
                    if code == 404 {
                        self.showDialog(NSLocalizedString("Invite code not found", comment: "Message for invite code not found when adding a child user"), NSLocalizedString("Try again", comment: "Try again button for adding a child when invite code is not found"))
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
                    }) {_ in
                        self.done()
                }
            }
        }
    }
}