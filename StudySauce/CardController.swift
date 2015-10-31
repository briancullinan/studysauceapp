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

class CardController: UIViewController {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var packTitle: UILabel!
    @IBOutlet weak var embeddedView: UIView!
    internal var intermediateResponse: Response? = nil
    internal var pack: Pack!
    internal var card: Card? = nil
    internal var subview: UIViewController? = nil
    var transitionManager: CardTransitionManager? = nil

    // TODO: check the answer for correctness

    override func viewDidLoad() {
        super.viewDidLoad()
                
        if card == nil {
            self.card = self.pack.getCardForUser(AppDelegate.getUser())
        }
        self.packTitle.text = self.pack.title
        let index = self.pack.getIndexForCard(self.card!, user: AppDelegate.getUser())
        let count = self.pack.getCardCount(AppDelegate.getUser())
        self.countLabel.text = "\(index) of \(count)"
        if self.subview == nil {
            var view = "Default"
            if self.card?.response_type == "mc" {
                view = "Multiple"
            }
            else if self.card?.response_type == "tf" {
                view = "TrueFalse"
            }
            else if self.card?.response_type == "sa" {
                view = "Blank"
            }
            self.subview = self.storyboard!.instantiateViewControllerWithIdentifier(view)
        }
        dispatch_async(dispatch_get_main_queue(),{
            self.addChildViewController(self.subview!)
            self.subview!.view.frame = CGRectMake(0, 0, self.embeddedView.frame.size.width, self.embeddedView.frame.size.height);
            self.embeddedView.addSubview(self.subview!.view)
            self.subview!.didMoveToParentViewController(self)
        })
            
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PackResultsController {
            vc.pack = self.pack
        }
    }
    
    // TODO: control which card comes next using local store
    
    // TODO: Store response in the database
    
    internal func submitResponse(response: Response) {
        let correct = response.correct != nil && response.correct == 1
        let answer = response.answer != nil ? response.answer!.id : 0
        let url = AppDelegate.studySauceCom("/packs/responses?pack=\(self.pack.id!)&card=\(self.card!.id!)&correct=\(correct)&answer=\(answer)")
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            
        })
        task.resume()
        let card = self.pack.getCardForUser((UIApplication.sharedApplication().delegate as! AppDelegate).user)
        if card == nil {
            self.performSegueWithIdentifier("results", sender: self)
        }
        else {
            let nextCard = self.storyboard!.instantiateViewControllerWithIdentifier("Card") as? CardController
            let manager = CardTransitionManager()
            nextCard!.pack = self.pack
            nextCard!.card = card
            nextCard?.transitioningDelegate = manager
            self.transitioningDelegate = manager
            self.presentViewController(nextCard!, animated: true, completion: { () -> Void in
                
            })
        }
    }

}

