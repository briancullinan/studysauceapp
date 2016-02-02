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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let vc = self.childViewControllers.filter({$0 is CardPromptController}).first as? CardPromptController {
            if !vc.isImage &&  self.inputText != nil {
                inputText!.becomeFirstResponder()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
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
    
    @IBAction func beginEdit(sender: UITextField) {
        UIView.setAnimationsEnabled(false)
    }
    
    override func viewDidLoad() {
        if let vc = self.parentViewController as? CardController {
            if inputText != nil {
                let keyboard = self.card?.pack?.getProperty("keyboard") as? String
                if keyboard == "number" {
                    self.inputText!.keyboardType = UIKeyboardType.NumberPad
                }
                if keyboard == "phone" {
                    self.inputText!.keyboardType = UIKeyboardType.PhonePad
                }
                if keyboard == "decimal" {
                    self.inputText!.keyboardType = UIKeyboardType.DecimalPad
                }
                if keyboard == "ascii" {
                    self.inputText!.keyboardType = UIKeyboardType.ASCIICapable
                }
                if keyboard == "alphabet" {
                    self.inputText!.keyboardType = UIKeyboardType.Alphabet
                }
                //Adding done button for textField1
                self.inputText!.addDoneOnKeyboardWithTarget(self, action: Selector("correctClick:"))
                self.inputText!.delegate = self
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "didShowKeyboard:", name: UIKeyboardDidShowNotification, object: nil)
            }
            self.card = vc.card
        }
    }
    
    func didShowKeyboard(notification: NSNotification) {
        UIView.setAnimationsEnabled(true)
        //let keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        if let _ = self.childViewControllers.filter({$0 is CardPromptController}).first as? CardPromptController {
            NSTimer.scheduledTimerWithTimeInterval(0.1,
                target: self, selector: "updatePlay", userInfo: nil, repeats: false)
        }
        //UIView.animateWithDuration(0.1, animations: { () -> Void in
        //    self.bottomConstraint.constant = keyboardFrame.size.height + 20
        //})
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
                vc.intermediateResponse = newResponse
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