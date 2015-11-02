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
            
            var next: UIViewController
            
            // only set subview for displaying response if answer is wrong, otherwise show next card
            if (self.destinationViewController as? CardController) == nil && (parent.intermediateResponse == nil || parent.intermediateResponse!.correct != 1) {
                // answer was wrong so definitely show card
                let card = parent.storyboard!.instantiateViewControllerWithIdentifier("Card") as! CardController
                card.pack = parent.pack
                card.card = parent.card
                card.intermediateResponse = parent.intermediateResponse
                card.subview = self.destinationViewController
                if parent.transitionManager != nil {
                    parent.transitionManager!.destinationViewController = card
                }
                next = card
            }
            else {
                // get a new card to show
                let nextCard = parent.pack.getCardForUser((UIApplication.sharedApplication().delegate as! AppDelegate).user)
                if nextCard == nil {
                    let results = parent.storyboard!.instantiateViewControllerWithIdentifier("Results") as! PackResultsController
                    results.pack = parent.pack
                    parent.presentViewController(results, animated: true, completion: nil)
                    return
                }
                else {
                    let card = self.destinationViewController as? CardController ?? parent.storyboard!.instantiateViewControllerWithIdentifier("Card") as! CardController
                    card.pack = parent.pack
                    card.card = nextCard
                    next = card
                }
            }
            
            // only do transition at this point, no swiping available unless it is set up beforehand
            if parent.transitionManager == nil {
                parent.transitionManager = CardTransitionManager()
            }
            
            next.transitioningDelegate = parent.transitionManager
            parent.transitioningDelegate = parent.transitionManager
            
            parent.presentViewController(next, animated: true, completion: nil)
        }
    }
}


