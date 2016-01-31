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
    @IBOutlet weak var goHome: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
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
        }
        else {
            // next time card is loaded retries will be repopulated
            let up = self.pack.getUserPack(AppDelegate.getUser())
            if self.percent.text == "100%" {
                up.getRetries(true)
            }
            else {
                // only wrong
                var retries = up.getRetries().filter{c -> Bool in return c.getResponse(AppDelegate.getUser())?.correct != 1}
                retries.shuffleInPlace()
                up.retries = retries.map { c -> String in return "\(c.id!)" }.joinWithSeparator(",")
                up.retry_to = NSDate()
                AppDelegate.saveContext()
            }
        }
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
        var correct = 0
        var wrong = 0
        let cards = self.isRetention ? AppDelegate.getUser()!.getRetention().map{AppDelegate.get(Card.self, $0)!} : self.pack.cards?.allObjects as! [Card]
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
        self.percent.text = "\(score)%"
        
        self.goHome.hidden = true
        self.crossButton.hidden = false
        self.checkButton.hidden = false
        
        // set up buttons and text
        if self.isRetention {
            self.packTitle.text = "Today's cards"
            if score == 100 {
                self.review.text = NSLocalizedString("Congratulations!\r\nYou answered all of today's questions correctly.", comment: "Big button all correct")
                self.goHome.hidden = false
                self.crossButton.hidden = true
                self.checkButton.hidden = true
            }
            else {
                self.review.text = NSLocalizedString("Go back through what you missed?", comment: "Big button with wrong answers")
            }
        }
        else {
            self.packTitle.text = self.pack.title
            if score == 100 {
                self.review.text = NSLocalizedString("Congratulations!\r\nYou answered all the questions correctly.\r\n\r\nStart again?", comment: "Pack summary all correct")
            }
            else {
                self.review.text = NSLocalizedString("Go back through what you missed?", comment: "Pack summary with wrong answers")
            }
        }
    }
    
}

