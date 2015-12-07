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
    
    
    @IBOutlet weak var content: AutoSizingTextView? = nil
    weak var card: Card? = nil
  
    override func viewDidLoad() {
        if let vc = self.parentViewController as? CardController {
            if content != nil {
                content!.text = vc.card?.content
            }
            self.card = vc.card
        }
    }
    
    func saveResponse(value: String) {
        if let vc = self.parentViewController as? CardController {
            if let moc = AppDelegate.getContext() {
                let newResponse = moc.insert(Response.self)
                for a in self.card!.answers!.allObjects as! [Answer] {
                    if a.value == value {
                        let ex = try? NSRegularExpression(pattern: a.value!, options: [NSRegularExpressionOptions.CaseInsensitive])
                        let match = ex?.firstMatchInString(value, options: [], range:NSMakeRange(0, value.utf16.count))
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
                self.performSegueWithIdentifier("correct", sender: self)
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
