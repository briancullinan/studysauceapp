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
    
    @IBOutlet weak var inputText: UITextField!
    
    @IBAction func returnToBlank(segue: UIStoryboardSegue) {
        
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return !answered && !CardSegue.transitionManager.transitioning
    }
    
    func updateConstraints() {
        if let vc = self.childViewControllers.filter({$0 is CardPromptController}).first as? CardPromptController where !vc.isImage
            && UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft || UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight {
                self.rightMargin.active = false
                self.verticalSpace.active = false
                self.leftMargin.active = false
                
                self.horizontalSpace.active = true
                self.alignCenter.active = true
                self.equalWidths.active = true
                self.bottomHalf.constant = BasicKeyboardController.keyboardHeight - saucyTheme.padding * 3
        }
        else {
            self.horizontalSpace.active = false
            self.alignCenter.active = false
            self.equalWidths.active = false
            
            self.rightMargin.active = true
            self.verticalSpace.active = true
            self.leftMargin.active = true
            
            self.bottomHalf.constant = BasicKeyboardController.keyboardHeight + 20 * saucyTheme.multiplier() + saucyTheme.padding * 2
        }
        self.view.setNeedsLayout()
    }
    
    override func viewDidLayoutSubviews() {
        self.updateConstraints()

        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.inputText.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let vc = self.childViewControllers.filter({$0 is CardPromptController}).first as? CardPromptController where !vc.isImage && !CardSegue.reassignment {
            self.inputText!.becomeFirstResponder()
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc = self.parentViewController as? CardController {
            self.card = vc.card
            IQKeyboardManager.sharedManager().enable = false
            IQKeyboardManager.sharedManager().enableAutoToolbar = false
            
            //Adding done button for textField
            returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
            self.inputText.addDoneOnKeyboardWithTarget(self, action: Selector("correctClick:"))
            self.inputText.delegate = self
            
            let keyboard = self.card?.pack?.getProperty("keyboard") as? String
            if keyboard == "default" {
                self.inputText.keyboardType = UIKeyboardType.Default
            }
            else if keyboard == "decimal" {
                self.inputText.keyboardType = UIKeyboardType.DecimalPad
            }
            else if keyboard == "ascii" {
                self.inputText.keyboardType = UIKeyboardType.ASCIICapable
            }
            else if keyboard == "alphabet" {
                self.inputText.keyboardType = UIKeyboardType.Alphabet
            }
            else {
                // use basic keyboard
                let inputAssistantItem = self.inputText!.inputAssistantItem
                inputAssistantItem.leadingBarButtonGroups = []
                inputAssistantItem.trailingBarButtonGroups = []
                if keyboard == "number" || keyboard == "phone" {
                    self.inputText.inputView = BasicKeyboardController.basicNumbersKeyboard
                }
                else {
                    self.inputText.inputView = BasicKeyboardController.basicKeyboard
                }
                BasicKeyboardController._basic?.goLowercase()
                BasicKeyboardController.keyboardHeight = 20 * saucyTheme.multiplier() + saucyTheme.padding * 2
                BasicKeyboardController.keyboardSwitch = {
                    self.inputText.inputView = $0
                    self.inputText.reloadInputViews()
                }
                self.inputText.inputAccessoryView = UIView()
                self.inputText.reloadInputViews()
            }
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateConstraints", name: UIKeyboardWillChangeFrameNotification, object: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.answered = true
        // TODO: check for correctness and continue
        self.saveResponse(self.inputText.text!)
        return true
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