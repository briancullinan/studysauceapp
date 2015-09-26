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
    internal var cards = [Card]()
    
    @IBOutlet weak var percent: UILabel!
    // TODO: display a summery of the results
    
    // TODO: trigger synchronize data with server
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardPromptController {
            vc.cards = self.cards
            vc.pack = self.pack
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var correct = 0
        var wrong = 0
        for c in self.cards {
            let last = c.responses!.allObjects[c.responses!.count-1] as! Response
            if last.correct == 1 {
                correct++
            }
            else {
                wrong++
            }
        }
        
        let score = Int32(round(Double(correct) / Double(correct + wrong) * 100.0));
        percent.text = "\(score)%"
    }

}

