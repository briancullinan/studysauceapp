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
    internal var isRetention = false

    @IBAction func backClick(sender: UIButton) {
        if self.isRetention {
            self.performSegueWithIdentifier("home", sender: self)
        }
        else {
            self.performSegueWithIdentifier("packs", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.card == nil {
            if self.isRetention {
                self.card = AppDelegate.getUser()!.getRetentionCard()
            }
            else {
                self.card = self.pack.getUserPack(AppDelegate.getUser()).getRetryCard()
            }
        }
        if self.isRetention {
            self.pack = self.card!.pack
            let index = AppDelegate.getUser()!.getRetentionIndex(self.card!)
            let count = AppDelegate.getUser()!.getRetentionCount()
            self.countLabel.text = "\(index+1) of \(count)"
        }
        else {
            let index = self.pack.getUserPack(AppDelegate.getUser()).getRetryIndex(self.card!)
            let count = self.pack.getUserPack(AppDelegate.getUser()).getRetryCount()
            self.countLabel.text = "\(index+1) of \(count)"
        }
        self.packTitle.text = self.pack.title
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
            vc.isRetention = self.isRetention
        }
        if let vc = segue.destinationViewController as? CardController {
            vc.pack = self.pack
            vc.isRetention = self.isRetention
            if vc.subview != nil {
                vc.card = self.card
                vc.intermediateResponse = self.intermediateResponse
            }
        }
        if let vc = segue.destinationViewController.parentViewController as? CardController {
            vc.pack = self.pack
            vc.isRetention = self.isRetention
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
        let answer = response.answer != nil ? response.answer!.id! : 0
        let created = response.created!.toRFC().stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        getJson("/packs/responses", params: ["pack": self.pack.id!, "card": self.card!.id!, "correct": correct, "answer": answer, "created": created], done: {json -> Void in
            response.id = json as? NSNumber
            AppDelegate.saveContext()
        })
    }
}


