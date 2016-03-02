//
//  CardPromptController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/23/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CardBlankController: UIViewController, UITextFieldDelegate {
    
    weak var card: Card? = nil
    var returnKeyHandler: IQKeyboardReturnKeyHandler? = nil
    var answered = false
    
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var verticalSpace: NSLayoutConstraint!
    @IBOutlet weak var rightMargin: NSLayoutConstraint!
    
    @IBOutlet weak var horizontalSpace: NSLayoutConstraint!
    @IBOutlet weak var alignCenter: NSLayoutConstraint!
    @IBOutlet weak var equalWidths: NSLayoutConstraint!
    
    @IBOutlet weak var bottomHalf: NSLayoutConstraint!
    
    @IBOutlet weak var inputText: UITextField? = nil
    
    @IBAction func returnToBlank(segue: UIStoryboardSegue) {
        
    }
    
    override func canBecomeFirstResponder() -> Bool {
        let result = !answered && !CardSegue.transitionManager.transitioning && AppDelegate.visibleViewController() == self.parentViewController
        return result
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        doMain {
            if !CardSegue.transitionManager.transitioning && AppDelegate.visibleViewController() == self.parentViewController {
                if let vc = self.childViewControllers.filter({$0 is CardPromptController}).first as? CardPromptController where !vc.isImage && self.inputText != nil {
                    self.inputText!.becomeFirstResponder()
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        doMain {
            if let vc = self.childViewControllers.filter({$0 is CardPromptController}).first as? CardPromptController where !vc.isImage && self.inputText != nil {
                let keyboardHeight = 4 * saucyTheme.textSize + 8 * saucyTheme.padding
                if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight {
                    self.rightMargin.active = false
                    self.verticalSpace.active = false
                    self.leftMargin.active = false
                    
                    self.horizontalSpace.active = true
                    self.alignCenter.active = true
                    self.equalWidths.active = true
                    self.bottomHalf.constant = keyboardHeight - saucyTheme.padding * 3
                }
                else {
                    self.bottomHalf.constant = keyboardHeight + 20 * saucyTheme.multiplier() + saucyTheme.padding * 2
                }
            }
            else {
                self.bottomHalf.constant = 20 * saucyTheme.multiplier() + saucyTheme.padding * 4
            }
            
            self.view.setNeedsLayout()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.setAnimationsEnabled(false)
        self.inputText!.resignFirstResponder()
        UIView.setAnimationsEnabled(true)
    }
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let pvc = self.parentViewController as? CardController {
            self.card = pvc.card
            if let vc = segue.destinationViewController as? CardPromptController {
                vc.card = self.card
                vc.parent = self
            }
            if let vc = segue.destinationViewController as? CardResponseController {
                vc.card = self.card
            }
        }
    }
        
    var _basic: BasicKeyboardController? = nil
    var _basicNumbers: BasicKeyboardController? = nil
    
    var basicKeyboard : UIView {
        if _basic == nil {
            _basic = self.storyboard!.instantiateViewControllerWithIdentifier("BasicKeyboard") as? BasicKeyboardController
            let height = 4 * saucyTheme.textSize + 8 * saucyTheme.padding
            let size = CGRectMake(0, 0, self.view.bounds.width, height)
            _basic!.view!.frame = size
            _basic!.view!.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return _basic!.view!
    }
    
    var basicNumbersKeyboard : UIView {
        if _basicNumbers == nil {
            _basicNumbers = self.storyboard!.instantiateViewControllerWithIdentifier("NumbersKeyboard") as? BasicKeyboardController
            let height = 4 * saucyTheme.textSize + 8 * saucyTheme.padding
            let size = CGRectMake(0, 0, self.view.bounds.width, height)
            _basicNumbers!.view!.frame = size
            _basicNumbers!.view!.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return _basicNumbers!.view!
    }
    
    @IBAction func beginEdit(sender: UITextField) {
        UIView.setAnimationsEnabled(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc = self.parentViewController as? CardController {
            self.card = vc.card
            
            if inputText != nil {
                IQKeyboardManager.sharedManager().enable = false
                IQKeyboardManager.sharedManager().enableAutoToolbar = false
                //Adding done button for textField
                returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
                self.inputText!.addDoneOnKeyboardWithTarget(self, action: Selector("correctClick:"))
                self.inputText!.delegate = self
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "didShowKeyboard:", name: UIKeyboardDidShowNotification, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "didHideKeyboard:", name: UIKeyboardDidHideNotification, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChange:", name: UIKeyboardWillChangeFrameNotification, object: nil)
                
                let keyboard = self.card?.pack?.getProperty("keyboard") as? String
                if keyboard == "default" {
                    self.inputText!.keyboardType = UIKeyboardType.Default
                }
                else if keyboard == "decimal" {
                    self.inputText!.keyboardType = UIKeyboardType.DecimalPad
                }
                else if keyboard == "ascii" {
                    self.inputText!.keyboardType = UIKeyboardType.ASCIICapable
                }
                else if keyboard == "alphabet" {
                    self.inputText!.keyboardType = UIKeyboardType.Alphabet
                }
                else {
                    // use basic keyboard
                    let inputAssistantItem = self.inputText!.inputAssistantItem
                    inputAssistantItem.leadingBarButtonGroups = []
                    inputAssistantItem.trailingBarButtonGroups = []
                    if keyboard == "number" || keyboard == "phone" {
                        self.inputText!.inputView = self.basicNumbersKeyboard
                    }
                    else {
                        self.inputText!.inputView = self.basicKeyboard
                    }
                    self.inputText!.inputAccessoryView = UIView()
                    self.inputText?.reloadInputViews()
                }
            }
        }
    }
    
    func keyboardWillChange(notification: NSNotification) {
        
        let keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight {
            self.bottomHalf.constant = keyboardFrame.size.height - saucyTheme.padding * 3
        }
        else {
            self.bottomHalf.constant = keyboardFrame.size.height + 20 * saucyTheme.multiplier() + saucyTheme.padding * 2
        }
        
        NSTimer.scheduledTimerWithTimeInterval(0.1,
            target: self, selector: "updatePlay", userInfo: nil, repeats: false)
        self.view.setNeedsLayout()
        UIView.setAnimationsEnabled(true)
    }

    func didHideKeyboard(notification: NSNotification) {
        self.horizontalSpace.active = false
        self.alignCenter.active = false
        self.equalWidths.active = false
        
        self.rightMargin.active = true
        self.verticalSpace.active = true
        self.leftMargin.active = true

        self.bottomHalf.constant = 20 * saucyTheme.multiplier() + saucyTheme.padding * 4
        self.view.setNeedsLayout()
    }
    
    func didShowKeyboard(notification: NSNotification) {
        UIView.setAnimationsEnabled(true)
        if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight {
            self.rightMargin.active = false
            self.verticalSpace.active = false
            self.leftMargin.active = false
            
            self.horizontalSpace.active = true
            self.alignCenter.active = true
            self.equalWidths.active = true
            self.view.setNeedsLayout()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.answered = true
        // TODO: check for correctness and continue
        self.saveResponse(self.inputText!.text!)
        return true
    }
    
    func updatePlay() {
        if let vc = self.childViewControllers.filter({$0 is CardPromptController}).first as? CardPromptController {
            vc.alignPlay(vc.content)
        }
    }
    
    func saveResponse(value: String) {
        if let vc = self.parentViewController as? CardController {
            AppDelegate.performContext {
                let newResponse = AppDelegate.insert(Response.self)
                let answer = self.card!.getCorrect()
                newResponse.answer = answer
                let pattern = answer!.value!
                let ex = try? NSRegularExpression(pattern: pattern, options: [NSRegularExpressionOptions.CaseInsensitive])
                let match = ex?.firstMatchInString(value, options: [], range:NSMakeRange(0, value.characters.count))
                newResponse.correct = match != nil
                newResponse.value = value
                newResponse.card = self.card
                newResponse.created = NSDate()
                newResponse.user = AppDelegate.getUser()
                AppDelegate.saveContext()
                // store intermediate and don't call this until after the correct answer is shown
                vc.intermediateResponse = newResponse.correct == 1
                doMain {
                    self.performSegueWithIdentifier("correct", sender: self)
                }
                HomeController.syncResponses(self.card!.pack!)
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.inputText?.becomeFirstResponder()
    }
}