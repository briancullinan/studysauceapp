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
    
    @IBOutlet weak var inputText: UITextField? = nil
    
    @IBAction func returnToBlank(segue: UIStoryboardSegue) {
        
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.sharedManager().enable = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        doMain {
            if let vc = self.childViewControllers.filter({$0 is CardPromptController}).first as? CardPromptController {
                if !vc.isImage && self.inputText != nil && !CardSegue.transitionManager.transitioning {
                    self.inputText!.becomeFirstResponder()
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIView.setAnimationsEnabled(false)
        self.inputText!.resignFirstResponder()
        UIView.setAnimationsEnabled(true)
        IQKeyboardManager.sharedManager().enable = true
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
    
    @IBAction func beginEdit(sender: UITextField) {
        UIView.setAnimationsEnabled(false)
    }
    
    @IBOutlet weak var bottomHalf: NSLayoutConstraint!
    
    var _basic: BasicKeyboardController? = nil
    var _basicNumbers: BasicKeyboardController? = nil
    
    var basicKeyboard : UIView {
        if _basic == nil {
            _basic = self.storyboard!.instantiateViewControllerWithIdentifier("BasicKeyboard") as? BasicKeyboardController
            let height = 4 * saucyTheme.textSize + 4 * saucyTheme.padding
            let size = CGRectMake(0, -height, self.view.bounds.width, height)
            _basic!.view!.frame = size
            _basicNumbers!.view!.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return _basic!.view!
    }
    
    var basicNumbersKeyboard : UIView {
        if _basicNumbers == nil {
            _basicNumbers = self.storyboard!.instantiateViewControllerWithIdentifier("NumbersKeyboard") as? BasicKeyboardController
            let height = 4 * saucyTheme.textSize + 4 * saucyTheme.padding
            let size = CGRectMake(0, -height, self.view.bounds.width, height)
            _basicNumbers!.view!.frame = size
            _basicNumbers!.view!.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return _basicNumbers!.view!
    }
    

    
    override var inputView: UIView? {
        get {
            return self.basicKeyboard
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc = self.parentViewController as? CardController {
            if inputText != nil {
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
                        self.inputText?.inputViewController?.view.addSubview(self.basicNumbersKeyboard)
                        self.inputText!.inputView = self.basicNumbersKeyboard
                    }
                    else {
                        self.inputText?.inputViewController?.view.addSubview(self.basicKeyboard)
                        self.inputText!.inputView = self.basicKeyboard
                    }
                    self.inputText!.inputAccessoryView = nil
                }
                //Adding done button for textField1
                self.inputText!.addDoneOnKeyboardWithTarget(self, action: Selector("correctClick:"))
                self.inputText!.delegate = self
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "didShowKeyboard:", name: UIKeyboardDidShowNotification, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChange:", name: UIKeyboardWillChangeFrameNotification, object: nil)
            }
            self.card = vc.card
            self.view.setNeedsLayout()
        }
    }
    
    func keyboardWillChange(notification: NSNotification) {
        UIView.setAnimationsEnabled(true)
        let keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.bottomHalf.constant = keyboardFrame.size.height - 20
        NSTimer.scheduledTimerWithTimeInterval(0.1,
            target: self, selector: "updatePlay", userInfo: nil, repeats: false)
        self.view.setNeedsLayout()
    }

    func didShowKeyboard(notification: NSNotification) {
        UIView.setAnimationsEnabled(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doMain {
            self.correctClick((self.view ~> UIButton.self).first!)
        }
        return true
    }
    
    func updatePlay() {
        if let vc = self.childViewControllers.filter({$0 is CardPromptController}).first as? CardPromptController {
            CardPromptController.alignPlay(vc.content)
        }
    }
    
    @IBOutlet weak var correctButton: UIButton!
    func saveResponse(value: String) {
        self.correctButton.enabled = false
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
                    HomeController.syncResponses()
                    self.performSegueWithIdentifier("correct", sender: self)
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.inputText?.becomeFirstResponder()
    }

    @IBAction func correctClick(sender: UIButton) {
        UIView.setAnimationsEnabled(false)
        self.inputText!.resignFirstResponder()
        UIView.setAnimationsEnabled(true)
        // TODO: check for correctness and continue
        self.saveResponse(self.inputText!.text!)
    }
}