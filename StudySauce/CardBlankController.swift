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

class CardBlankController: UIViewController {
    
    weak var card: Card? = nil
    //var handler: IQKeyboardReturnKeyHandler? = nil
    
    @IBOutlet weak var content: AutoSizingTextView? = nil
    @IBOutlet weak var inputText: UITextField? = nil
    @IBAction func returnToBlank(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.inputText != nil {
            inputText!.becomeFirstResponder()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let _ = segue.destinationViewController as? CardBlankController {
            if self.inputText != nil {
                UIView.setAnimationsEnabled(false)
                self.inputText!.resignFirstResponder()
                UIView.setAnimationsEnabled(true)
            }
        }
    }
    
    @IBAction func beginEdit(sender: UITextField) {
        UIView.setAnimationsEnabled(false)
    }

    override func viewDidLoad() {
        if let vc = self.parentViewController as? CardController {
            if content != nil {
                content!.text = vc.card?.content
            }
            if inputText != nil {
                //Adding done button for textField1
                self.inputText?.addDoneOnKeyboardWithTarget(self, action: Selector("correctClick:"))

                NSNotificationCenter.defaultCenter().addObserver(self, selector: "didShowKeyboard:", name: UIKeyboardDidShowNotification, object: nil)
                //self.handler = IQKeyboardReturnKeyHandler(controller: self)
            }
            self.card = vc.card
        }
    }
    
    func didShowKeyboard(notification: NSNotification) {
        UIView.setAnimationsEnabled(true)
    }
    
    func saveResponse(value: String) {
        if let vc = self.parentViewController as? CardController {
            if let moc = AppDelegate.getContext() {
                let newResponse = moc.insert(Response.self)
                let answer = self.card!.getCorrect()
                newResponse.answer = answer
                let ex = try? NSRegularExpression(pattern: answer!.value!, options: [NSRegularExpressionOptions.CaseInsensitive])
                let match = ex?.firstMatchInString(value, options: [], range:NSMakeRange(0, value.utf16.count))
                newResponse.correct = match != nil
                newResponse.value = value
                newResponse.card = self.card
                newResponse.created = NSDate()
                newResponse.user = AppDelegate.getUser()
                AppDelegate.saveContext()
                // store intermediate and don't call this until after the correct answer is shown
                vc.intermediateResponse = newResponse
                vc.submitResponse(newResponse)
                self.performSegueWithIdentifier("correct", sender: self)
            }
        }
    }

    @IBAction func correctClick(sender: UIButton) {
        inputText!.resignFirstResponder()
        // TODO: check for correctness and continue
        self.saveResponse(self.inputText!.text!)
    }
}