//
//  CardPromptController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/23/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

import UIKit

class PackResultsController: UIViewController {
    internal var pack: Pack!
    
    @IBOutlet weak var percent: UILabel!
    // TODO: display a summery of the results
    
    // TODO: trigger synchronize data with server
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardPromptController {
            vc.pack = self.pack
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var correct = 0
        var wrong = 0
        var retryFrom: NSDate? = nil
        var retryTo: NSDate? = nil
        for c in self.pack.cards?.allObjects as! [Card] {
            let last = c.responses!.allObjects[c.responses!.count-1] as! Response
            if last.correct == 1 {
                correct++
            }
            else {
                wrong++
                if retryFrom == nil || last.created!.isLessThanDate(retryFrom!) {
                    retryFrom = last.created
                }
                if retryTo == nil || last.created!.isGreaterThanDate(retryTo!) {
                    retryTo = last.created
                }
            }
        }
        
        // set from and to times for retry wrong answers
        if retryFrom != nil && retryTo != nil {
            let up = pack.getUserPackForUser((UIApplication.sharedApplication().delegate as! AppDelegate).user)
            if let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
                up?.retry_from = retryFrom
                up?.retry_to = retryTo
                do {
                    try moc.save()
                }
                catch let error as NSError {
                    NSLog("\(error.localizedDescription)")
                }
            }
        }
        
        let score = Int32(round(Double(correct) / Double(correct + wrong) * 100.0));
        percent.text = "\(score)%"
    }
    
}

