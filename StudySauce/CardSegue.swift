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
 
    static var transitionManager: CardTransitionManager = CardTransitionManager()
    
    override func perform() {
        var last: UIViewController = self.sourceViewController
        var next: UIViewController = self.destinationViewController
        if let parent = last.parentViewController as? CardController {
            last = parent
            
            // only set subview for displaying response if answer is wrong, otherwise show next card
            if (next as? CardController) == nil && (parent.intermediateResponse == nil || parent.intermediateResponse!.correct != 1) {
                // answer was wrong so definitely show card
                let card = last.storyboard!.instantiateViewControllerWithIdentifier("Card") as! CardController
                card.subview = next
                card.intermediateResponse = parent.intermediateResponse
                next = card
            }
            else {
                // get a new card to show
                let nextCard = parent.isRetention ? AppDelegate.getUser()?.getRetentionCard() : parent.pack.getRetryCard(AppDelegate.getUser())
                if nextCard == nil {
                    let results = last.storyboard!.instantiateViewControllerWithIdentifier("Results") as! PackResultsController
                    results.pack = parent.pack
                    next = results
                }
                else {
                    if let card = next as? CardController {
                        card.card = nextCard
                        next = card
                    }
                    else {
                        let card = last.storyboard!.instantiateViewControllerWithIdentifier("Card") as! CardController
                        card.card = nextCard
                        card.pack = parent.pack
                        next = card
                    }
                }
            }
            parent.prepareForSegue(self, sender: self)
        }
        
        // only do transition at this point, no swiping available unless it is set up beforehand
        next.transitioningDelegate = CardSegue.transitionManager
        last.transitioningDelegate = CardSegue.transitionManager
        
        last.presentViewController(next, animated: true, completion: nil)
    }
}


