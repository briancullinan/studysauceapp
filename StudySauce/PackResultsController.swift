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
    
    @IBAction func retryClick(sender: AnyObject) {
        let up = self.pack.getUserPackForUser(AppDelegate.getUser())
        let retries = up.getRetries().filter{c -> Bool in return c.getResponse(AppDelegate.getUser())?.correct != 1}
        up.retries = retries.map { c -> String in return "\(c.id!)" }.joinWithSeparator(",")
        up.retry_to = NSDate()
        AppDelegate.saveContext()
        
        self.performSegueWithIdentifier("card", sender: self)
    }
    // TODO: display a summery of the results

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardController {
            vc.pack = self.pack
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.packTitle.text = self.pack.title
        var correct = 0
        var wrong = 0
        for c in self.pack.cards?.allObjects as! [Card] {
            if let last = c.getResponse(AppDelegate.getUser()) {
                if last.correct == 1 {
                    correct++
                }
                else {
                    wrong++
                }
            }
        }
        
        if wrong == 0 {
            review.text = "Start over?"
        }
        
        let score = Int32(round(Double(correct) / Double(correct + wrong) * 100.0));
        percent.text = "\(score)%"
    }
    
}

