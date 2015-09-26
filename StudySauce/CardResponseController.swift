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

class CardResponseController: UIViewController {
    
    internal var pack: Pack!
    internal var cards = [Card]()
    internal var card: Card!
    
    @IBOutlet internal weak var response: UITextView!
    // TODO: control which card comes next using local store
    
    // TODO: Store response in the database
    
    @IBAction func correctClick(sender: UIButton, forEvent event: UIEvent) {
        do {
            if let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
                let newResponse = NSEntityDescription.insertNewObjectForEntityForName("Response", inManagedObjectContext: moc) as? Response
                newResponse!.correct = true
                newResponse!.card = self.card
                newResponse!.created = NSDate()
                try moc.save()
            }
        }
        catch let error as NSError {
            NSLog(error.description)
        }
        let url: NSURL = NSURL(string: "https://cerebro.studysauce.com/response?pack=\(self.pack.id!)&card=\(self.card.id!)&correct=1")!
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            
            })
        task.resume()
        self.selectCard()
    }
    
    @IBAction func wrongClick(sender: UIButton, forEvent event: UIEvent) {
        do {
            if let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
                let newResponse = NSEntityDescription.insertNewObjectForEntityForName("Response", inManagedObjectContext: moc) as? Response
                newResponse!.correct = false
                newResponse!.card = self.card
                newResponse!.created = NSDate()
                try moc.save()
            }
        }
        catch let error as NSError {
            NSLog(error.description)
        }
        let url: NSURL = NSURL(string: "https://cerebro.studysauce.com/response?pack=\(self.pack.id!)&card=\(self.card.id!)&correct=1")!
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            
        })
        task.resume()
        self.selectCard()
    }
    
    func selectCard() -> Void {
        if self.cards.count > 0 {
            // count the max number of responses for each card in the pack, if all the cards have the same number of responses, show results page
            var most: Card?
            var least: Card?
            for c in self.cards {
                if most == nil || c.responses!.count > most!.responses!.count {
                    most = c
                }
                if least == nil || c.responses!.count < least!.responses!.count {
                    least = c
                }
            }
            if least != nil && most != nil && least!.responses!.count == most!.responses!.count {
                self.performSegueWithIdentifier("results", sender: self)
                return
            }
        }
        self.performSegueWithIdentifier("prompt", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardPromptController {
            vc.cards = self.cards
            vc.pack = self.pack
        }
        if let vc = segue.destinationViewController as? PackResultsController {
            vc.cards = self.cards
            vc.pack = self.pack
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.response.text = self.card.response
    }
}

