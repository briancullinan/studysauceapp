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

class CardSelfController: UIViewController {
    
    
    @IBOutlet weak var correctButton: UIButton? = nil
    @IBOutlet weak var content: AutoSizingTextView? = nil
    @IBOutlet weak var response: AutoSizingTextView? = nil
    weak var card: Card? = nil
    
    @IBAction func returnToPrompt(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        if let vc = self.parentViewController as? CardController {
            if content != nil {
                content!.text = vc.card?.content
            }
            if response != nil {
                let correct = vc.card?.getCorrect()
                if correct == nil || correct!.value == nil {
                    response!.text = "\(vc.card!.response!)"
                }
                else {
                    let ex = try? NSRegularExpression(pattern: correct!.value!, options: NSRegularExpressionOptions.CaseInsensitive)
                    let match = ex?.firstMatchInString(correct!.value!, options: [], range:NSMakeRange(0, correct!.value!.utf16.count))
                    let matched = match?.rangeAtIndex(0)
                    response!.text = "\(correct!.value!)\n\r\(vc.card!.response!)"
                }
            }
            self.card = vc.card;
        }
    }
    
    func submitResponse(correct: Bool) {
        if let vc = self.parentViewController as? CardController {
            if let moc = AppDelegate.getContext() {
                let newResponse = moc.insert(Response.self)
                newResponse.correct = correct
                newResponse.card = self.card
                newResponse.created = NSDate()
                newResponse.user = AppDelegate.getUser()
                AppDelegate.saveContext()
                vc.intermediateResponse = newResponse
                vc.submitResponse(newResponse)
            }
            self.performSegueWithIdentifier("card", sender: self)
        }
    }
        
    @IBAction func wrongClick(sender: UIButton) {
        self.submitResponse(false)
    }
    
    @IBAction func correctClick(sender: UIButton) {
        self.submitResponse(true)
    }
}
