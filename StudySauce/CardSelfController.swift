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
    
    
    @IBOutlet weak var content: AutoSizingTextView? = nil
    @IBOutlet weak var response: AutoSizingTextView? = nil
    weak var card: Card? = nil
    
    override func viewDidLoad() {
        if let vc = self.parentViewController as? CardController {
            if content != nil {
                content!.text = vc.card?.content
            }
            if response != nil {
                let correct = vc.card?.getCorrect()?.value
                if correct == nil {
                    response!.text = "\(vc.card!.response!)"
                }
                else {
                    response!.text = "\(correct!)\n\r\(vc.card!.response!)"
                }
            }
            self.card = vc.card;
        }
    }
    
    func submitResponse(correct: Bool) {
        if let vc = self.parentViewController as? CardController {
            do {
                if let moc = AppDelegate.getContext() {
                    let newResponse = NSEntityDescription.insertNewObjectForEntityForName("Response", inManagedObjectContext: moc) as? Response
                    newResponse!.correct = correct
                    newResponse!.card = self.card
                    newResponse!.created = NSDate()
                    newResponse!.user = AppDelegate.getUser()
                    try moc.save()
                    vc.submitResponse(newResponse!)
                }
            }
            catch let error as NSError {
                NSLog(error.description)
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