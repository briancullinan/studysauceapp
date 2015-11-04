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
    internal var subview: UIViewController? = nil {
        didSet {
            self.addChildViewController(self.subview!)
        }
    }

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
        self.embeddedView.addSubview(self.subview!.view)
        dispatch_async(dispatch_get_main_queue(),{
            self.subview!.view.frame = CGRectMake(0, 0, self.embeddedView.frame.size.width, self.embeddedView.frame.size.height);
            self.subview!.didMoveToParentViewController(self)
        })
            
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PackResultsController {
            vc.pack = self.pack
        }
        if let vc = segue.destinationViewController as? CardController {
            vc.pack = self.pack
            if vc.subview != nil {
                vc.card = self.card
                vc.intermediateResponse = self.intermediateResponse
            }
        }
        if let vc = segue.destinationViewController.parentViewController as? CardController {
            vc.pack = self.pack
            if vc.subview != nil {
                vc.card = self.card
                vc.intermediateResponse = self.intermediateResponse
            }
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
    }
}


