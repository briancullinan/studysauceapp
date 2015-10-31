//
//  DismissSegue.swift
//  StudySauce
//
//  Created by Brian Cullinan on 10/1/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class CardSegue : UIStoryboardSegue {
 
    override func perform() {
        let sourceViewController = self.sourceViewController;
        if let parent = sourceViewController.parentViewController as? CardController {
            let card = parent.storyboard!.instantiateViewControllerWithIdentifier("Card") as! CardController
            card.pack = parent.pack
            card.card = parent.card
            card.intermediateResponse = parent.intermediateResponse
            card.subview = self.destinationViewController
            
            if parent.transitionManager == nil {
                parent.transitionManager = CardTransitionManager()
                //parent.transitionManager!.sourceViewController = parent
            }
            else {
                parent.transitionManager!.destinationViewController = card
            }
            
            card.transitioningDelegate = parent.transitionManager
            parent.transitioningDelegate = parent.transitionManager
            
            parent.presentViewController(card, animated: true, completion: nil)
        }
    }
}


