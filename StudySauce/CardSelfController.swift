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
    @IBOutlet weak var wrongButton: UIButton? = nil
    weak var card: Card? = nil
    
    @IBAction func returnToPrompt(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        
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
    
    func submitResponse(correct: Bool) {
        self.correctButton?.enabled = false
        self.wrongButton?.enabled = false
        if let vc = self.parentViewController as? CardController {
            AppDelegate.performContext {
                let newResponse = AppDelegate.insert(Response.self)
                newResponse.correct = correct
                newResponse.card = self.card
                newResponse.created = NSDate()
                newResponse.user = AppDelegate.getUser()
                AppDelegate.saveContext()
                vc.intermediateResponse = newResponse.correct == 1
                doMain {
                    HomeController.syncResponses()
                    self.performSegueWithIdentifier("card", sender: self)
                }
            }
        }
    }
        
    @IBAction func wrongClick(sender: UIButton) {
        self.submitResponse(false)
    }
    
    @IBAction func correctClick(sender: UIButton) {
        self.submitResponse(true)
    }
}
