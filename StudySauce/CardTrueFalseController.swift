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

class CardTrueFalseController: UIViewController {
    
    weak var card: Card? = nil
  
    override func viewDidLoad() {
        if let vc = self.parentViewController as? CardController {
            self.card = vc.card
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if let pvc = self.parentViewController as? CardController {
            self.card = pvc.card
            if let vc = segue.destinationViewController as? CardPromptController {
                vc.card = self.card
            }
            if let vc = segue.destinationViewController as? CardResponseController {
                vc.card = self.card
            }
        }
    }
    
    func saveResponse(value: String) {
        if let vc = self.parentViewController as? CardController {
            AppDelegate.performContext {
                let newResponse = AppDelegate.insert(Response.self)
                for a in self.card!.answers!.allObjects as! [Answer] {
                    if a.value == value {
                        let ex = try? NSRegularExpression(pattern: a.value!, options: [NSRegularExpressionOptions.CaseInsensitive])
                        let match = ex?.firstMatchInString(value, options: [], range:NSMakeRange(0, value.characters.count))
                        newResponse.correct = match != nil
                        newResponse.answer = a
                        break
                    }
                }
                newResponse.value = value
                newResponse.card = self.card
                newResponse.created = NSDate()
                newResponse.user = AppDelegate.getUser()
                AppDelegate.saveContext()
                // store intermediate and don't call this until after the correct answer is shown
                vc.intermediateResponse = newResponse
                vc.submitResponse(newResponse)
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier("correct", sender: self)
                })
            }
        }
    }
    
    @IBAction func falseClick(sender: UIButton) {
        self.saveResponse("false")
    }
    
    @IBAction func trueClick(sender: UIButton) {
        self.saveResponse("true")
    }
}
