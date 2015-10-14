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
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var packTitle: UILabel!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var review: UILabel!
    
    // TODO: display a summery of the results
    
    // TODO: trigger synchronize data with server
    @IBAction func retryClick(sender: UIButton) {
        var earliest: NSDate? = nil
        for c in self.pack.cards?.allObjects as! [Card] {
            if let last = c.getResponseForUser(AppDelegate.getUser()) {
                if last.correct == 0 && (earliest == nil || last.created! < earliest!) {
                    earliest = last.created!
                }
            }
        }
        
        // set from and to times for retry wrong answers
        let up = pack.getUserPackForUser(AppDelegate.getUser())
        if let moc = AppDelegate.getContext() {
            up!.retry_from = earliest
            up!.retry_to = NSDate()
            do {
                try moc.save()
            }
            catch let error as NSError {
                NSLog("\(error.localizedDescription)")
            }
        }
        
        self.performSegueWithIdentifier("prompt", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardPromptController {
            vc.pack = self.pack
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = self.pack.logo where !url.isEmpty {
            let logo = UIImage(data: NSData(contentsOfURL: NSURL(string:url)!)!)!
            self.logoImage.image = logo
        }
        else {
            self.logoImage.image = nil
        }
        self.packTitle.text = self.pack.title
        var correct = 0
        var wrong = 0
        for c in self.pack.cards?.allObjects as! [Card] {
            if let last = c.getResponseForUser(AppDelegate.getUser()) {
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

