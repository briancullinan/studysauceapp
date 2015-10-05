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
            if let moc = AppDelegate.getContext() {
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
        let url = AppDelegate.studySauceCom("/response?pack=\(self.pack.id!)&card=\(self.card.id!)&correct=1")
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            
        })
        task.resume()
        if self.pack.getCardForUser((UIApplication.sharedApplication().delegate as! AppDelegate).user) == nil {
            self.performSegueWithIdentifier("results", sender: self)
        }
        else {
            self.performSegueWithIdentifier("prompt", sender: self)
        }
    }
    
    @IBAction func wrongClick(sender: UIButton, forEvent event: UIEvent) {
        do {
            if let moc = AppDelegate.getContext() {
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
        let url = AppDelegate.studySauceCom("/response?pack=\(self.pack.id!)&card=\(self.card.id!)&correct=0")
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            
        })
        task.resume()
        if self.pack.getCardForUser((UIApplication.sharedApplication().delegate as! AppDelegate).user) == nil {
            self.performSegueWithIdentifier("results", sender: self)
        }
        else {
            self.performSegueWithIdentifier("prompt", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardPromptController {
            vc.pack = self.pack
        }
        if let vc = segue.destinationViewController as? PackResultsController {
            vc.pack = self.pack
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.response.text = self.card.response
    }
}

