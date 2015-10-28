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

class CardMultipleController: UIViewController {

    
    @IBOutlet weak var response: AutoSizingTextView? = nil
    @IBOutlet weak var content: AutoSizingTextView? = nil
    @IBOutlet weak var answer1: UIButton? = nil
    @IBOutlet weak var answer2: UIButton? = nil
    @IBOutlet weak var answer3: UIButton? = nil
    @IBOutlet weak var answer4: UIButton? = nil
    weak var card: Card? = nil
 
    override func viewDidLoad() {
        if let vc = self.parentViewController as? CardController {
            if content != nil {
                content!.text = vc.card?.content
            }
            if response != nil {
                response!.text = "\(vc.card!.getCorrect()!.value!)\n\r\(vc.card!.response!)"
            }
            if answer1 != nil && vc.card?.answers?.count > 0 {
                answer1!.setTitle((vc.card?.answers!.allObjects[0] as! Answer).value, forState: .Normal)
            }
            if answer2 != nil && vc.card?.answers?.count > 1 {
                answer2!.setTitle((vc.card?.answers!.allObjects[1] as! Answer).value, forState: .Normal)
            }
            if answer3 != nil && vc.card?.answers?.count > 2 {
                answer3!.setTitle((vc.card?.answers!.allObjects[2] as! Answer).value, forState: .Normal)
            }
            if answer4 != nil && vc.card?.answers?.count > 3 {
                answer4!.setTitle((vc.card?.answers!.allObjects[3] as! Answer).value, forState: .Normal)
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
    
    @IBAction func continueClick(sender: UIButton) {
        if let vc = self.parentViewController as? CardController {
            vc.submitResponse(vc.intermediateResponse!)
        }
    }
    
    @IBAction func answer1Click(sender: UIButton) {
        self.saveResponse(sender.titleForState(.Normal)!)
    }
    
    @IBAction func answer2Click(sender: UIButton) {
        self.saveResponse(sender.titleForState(.Normal)!)
    }
    
    @IBAction func answer3Click(sender: UIButton) {
        self.saveResponse(sender.titleForState(.Normal)!)
    }
    
    @IBAction func answer4Click(sender: UIButton) {
        self.saveResponse(sender.titleForState(.Normal)!)
    }
}