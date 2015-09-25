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

class CardPromptController: UIViewController {

    @IBOutlet weak var prompt: UITextView!
    internal var pack: Pack!
    internal var card: Card!
    internal var cards = [Card]()
    // load the card content, display and available answers
    
    func getData(completionHandler: ([Card], NSError!) -> Void) -> Void {
        var packs = [Card]()
        if let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Card")
            do {
                for p in try moc.executeFetchRequest(fetchRequest) as! [Card] {
                    packs.insert(p, atIndex: 0)
                }
                completionHandler(packs, nil)
            }
            catch let error as NSError {
                NSLog("Failed to retrieve record: \(error.localizedDescription)")
            }
            let url: NSURL = NSURL(string: "https://cerebro.studysauce.com/cards?pack=\(self.pack.id!)")!
            let ses = NSURLSession.sharedSession()
            let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
                if (error != nil) {
                    return completionHandler([], error)
                }
                
                do {
                    // TODO: remove packs that no longer exist
                    for p in packs {
                        moc.deleteObject(p)
                        packs.removeAtIndex(packs.indexOf(p)!)
                    }
                    
                    // load packs from server
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    for pack in json as! NSArray {
                        var newPack: Card?
                        for p in packs {
                            if p.id == pack["id"] as? NSNumber {
                                newPack = p
                            }
                        }
                        if newPack == nil {
                            newPack = NSEntityDescription.insertNewObjectForEntityForName("Card", inManagedObjectContext: moc) as? Card
                        }
                        
                        newPack!.content = pack["content"] as? String
                        newPack!.response = pack["response"] as? String
                        newPack!.id = pack["id"] as? NSNumber
                        newPack!.pack = self.pack
                        newPack!.created = pack["created"] as? NSDate
                        packs.insert(newPack!, atIndex: 0)
                        try moc.save()
                    }
                    completionHandler(packs, nil)
                }
                catch let error as NSError {
                    completionHandler([], error)
                }
            })
            task.resume()
        }
    }

    // TODO: check the answer for correctness
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.cards.count == 0 {
            self.getData { (data, error) -> Void in
                self.cards = data;
                dispatch_async(dispatch_get_main_queue(), {
                    // randomly choose a card
                    self.selectCard()
                })
            }
        }
        else {
            self.selectCard()
        }
    }
    
    func selectCard() -> Card? {
        if self.cards.count > 0 {
            // TODO: count the max number of responses for each card in the pack, pick the card with the least number of responses
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
            if least != nil {
                self.card = least
                self.prompt.text = self.card.content
            }
        }
        return nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardResponseController {
            vc.card = self.card
            vc.pack = self.pack
            vc.cards = self.cards
        }
    }

    
}

