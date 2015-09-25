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
    
    // TODO: display a summery of the results
    
    // TODO: trigger synchronize data with server
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardPromptController {
            vc.cards = self.cards
            vc.pack = self.pack
        }
    }

}

