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

    
    @IBOutlet weak var answer1: UIButton? = nil
    @IBOutlet weak var answer2: UIButton? = nil
    @IBOutlet weak var answer3: UIButton? = nil
    @IBOutlet weak var answer4: UIButton? = nil
    weak var card: Card? = nil
    
    @IBAction func returnToMultiple(segue: UIStoryboardSegue) {
        
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

    override func viewDidLoad() {
        if let pvc = self.parentViewController as? CardController {
            self.card = pvc.card
            if self.answer1 != nil && self.card?.answers?.count > 0 {
                self.answer1!.titleLabel?.adjustsFontSizeToFitWidth = true
                self.answer1!.setTitle((self.card?.answers!.allObjects[0] as! Answer).value, forState: .Normal)
            }
            if self.answer2 != nil && self.card?.answers?.count > 1 {
                self.answer2!.titleLabel?.adjustsFontSizeToFitWidth = true
                self.answer2!.setTitle((self.card?.answers!.allObjects[1] as! Answer).value, forState: .Normal)
            }
            if self.answer3 != nil && self.card?.answers?.count > 2 {
                self.answer3!.titleLabel?.adjustsFontSizeToFitWidth = true
                self.answer3!.setTitle((self.card?.answers!.allObjects[2] as! Answer).value, forState: .Normal)
            }
            if self.answer4 != nil && self.card?.answers?.count > 3 {
                self.answer4!.titleLabel?.adjustsFontSizeToFitWidth = true
                self.answer4!.setTitle((self.card?.answers!.allObjects[3] as! Answer).value, forState: .Normal)
            }
        }
    }
    
    func saveResponse(value: String) {
        self.answer1?.enabled = false
        self.answer2?.enabled = false
        self.answer3?.enabled = false
        self.answer4?.enabled = false
        if let vc = self.parentViewController as? CardController {
            AppDelegate.performContext {
                let newResponse = AppDelegate.insert(Response.self)
                for a in self.card!.answers!.allObjects as! [Answer] {
                    if a.value == value {
                        newResponse.correct = a.correct
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
                vc.intermediateResponse = newResponse.correct == 1
                doMain {
                    HomeController.syncResponses()
                    self.performSegueWithIdentifier("correct", sender: self)
                }
            }
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