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

class PackResultsController: UIViewController {
    internal var pack: Pack!
    
    @IBOutlet weak var packTitle: UILabel!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var review: UILabel!
    
    internal var isRetention = false
    
    @IBAction func backClick(sender: UIButton) {
        self.doReset()
        if self.isRetention {
            self.performSegueWithIdentifier("home", sender: self)
        }
        else {
            self.performSegueWithIdentifier("packs", sender: self)
        }
    }
    
    @IBAction func retryClick(sender: AnyObject) {
        self.doReset()
        if self.isRetention {
            if self.percent.text == "100%" {
                self.performSegueWithIdentifier("home", sender: self)
            }
            else {
                self.performSegueWithIdentifier("card", sender: self)
            }
        }
        else {
            self.performSegueWithIdentifier("card", sender: self)
        }
    }
    
    func doReset() {
        if self.isRetention {
            // force homescreen to update with new retention cards
            AppDelegate.getUser()!.getRetention(true)
            AppDelegate.getUser()!.retention_to = NSDate()
        }
        else {
            let up = self.pack.getUserPack(AppDelegate.getUser())
            // next time card is loaded retries will be repopulated
            var retries = up.getRetries().filter{c -> Bool in return c.getResponse(AppDelegate.getUser())?.correct != 1}
            retries.shuffleInPlace()
            up.retries = retries.map { c -> String in return "\(c.id!)" }.joinWithSeparator(",")
            up.retry_to = NSDate()
        }
        AppDelegate.saveContext()
    }
    // TODO: display a summery of the results

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let vc = segue.destinationViewController as? CardController {
            vc.pack = self.pack
            vc.isRetention = self.isRetention
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add up results differently when loading from a retention pack
        if self.isRetention {
            self.packTitle.text = "Today's cards"
        }
        else {
            self.packTitle.text = self.pack.title
        }
        var correct = 0
        var wrong = 0
        let cards = self.isRetention ? AppDelegate.getUser()!.getRetention() : self.pack.cards?.allObjects as! [Card]
        for c in cards {
            if let last = c.getResponse(AppDelegate.getUser()) {
                if last.correct == 1 {
                    correct++
                }
                else {
                    wrong++
                }
            }
        }
        
        let score = Int32(round(Double(correct) / Double(correct + wrong) * 100.0));
        percent.text = "\(score)%"
    }
    
}

