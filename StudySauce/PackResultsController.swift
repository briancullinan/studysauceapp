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
    
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var retry: UIButton!
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
        for c in self.pack.cards?.allObjects as! [Card] {
            let last = c.responses!.sortedArrayUsingDescriptors([NSSortDescriptor(key: "created", ascending: false)])[0] as! Response
            if last.correct == 1 {
                correct++
            }
            else {
                wrong++
            }
        }
        
        if wrong == 0 {
            retry.hidden = true
        }
        
        // set from and to times for retry wrong answers
        let up = pack.getUserPackForUser((UIApplication.sharedApplication().delegate as! AppDelegate).user)
        if let moc = self.getContext() {
            up!.retry_from = NSDate()
            up!.retry_to = NSDate()
            do {
                try moc.save()
            }
            catch let error as NSError {
                NSLog("\(error.localizedDescription)")
            }
        }
        
        let score = Int32(round(Double(correct) / Double(correct + wrong) * 100.0));
        percent.text = "\(score)%"
    }
    
}

