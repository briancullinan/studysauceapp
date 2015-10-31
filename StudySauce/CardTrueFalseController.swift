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
            do {
                if let moc = AppDelegate.getContext() {
                    let newResponse = NSEntityDescription.insertNewObjectForEntityForName("Response", inManagedObjectContext: moc) as? Response
                    for a in self.card!.answers!.allObjects as! [Answer] {
                        if a.value == value {
                            newResponse!.correct = a.correct
                            newResponse!.answer = a
                            break
                        }
                    }
                    newResponse!.value = value
                    newResponse!.card = self.card
                    newResponse!.created = NSDate()
                    newResponse!.user = AppDelegate.getUser()
                    try moc.save()
                    // store intermediate and don't call this until after the correct answer is shown
                    vc.intermediateResponse = newResponse;
                    self.performSegueWithIdentifier("correct", sender: self)
                }
            }
            catch let error as NSError {
                NSLog(error.description)
            }
        }
    }
    
    @IBAction func falseClick(sender: UIButton) {
        self.saveResponse("False")
    }
    
    @IBAction func trueClick(sender: UIButton) {
        self.saveResponse("True")
    }
}
