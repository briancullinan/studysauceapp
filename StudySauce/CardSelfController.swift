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

class CardSelfController: UIViewController {
    
    
    @IBOutlet weak var content: AutoSizingTextView? = nil
    @IBOutlet weak var response: AutoSizingTextView? = nil
    weak var card: Card? = nil
    internal var backgroundView: UIView? = nil
    
    override func viewDidLoad() {
        if let vc = self.parentViewController as? CardController {
            if content != nil {
                content!.text = vc.card?.content
                vc.transitionManager = CardTransitionManager()
                vc.transitionManager!.sourceViewController = vc
            }
            if response != nil {
                let correct = vc.card?.getCorrect()?.value
                if correct == nil {
                    response!.text = "\(vc.card!.response!)"
                }
                else {
                    response!.text = "\(correct!)\n\r\(vc.card!.response!)"
                }
                if vc.intermediateResponse != nil {
                    self.backgroundView = UIView()
                    vc.view.insertSubview(self.backgroundView!, belowSubview: vc.embeddedView)
                    self.backgroundView!.frame = CGRect(x: 0, y: 0, width: vc.view.frame.width, height: vc.view.frame.height)
                    self.backgroundView!.alpha = 1.0
                    if vc.intermediateResponse?.correct == 1 {
                        self.backgroundView!.backgroundColor = UIColor(netHex:0x078600)
                    }
                    else {
                        self.backgroundView!.backgroundColor = UIColor(netHex:0xFF0D00)
                    }
                }
            }
            self.card = vc.card;
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.backgroundView != nil {
        UIView.animateWithDuration(0.5, delay: 0.0, options: [], animations: {
            self.backgroundView!.alpha = 0.0
            }, completion: { finished in
        })
        }
    }

    func submitResponse(correct: Bool) {
        if let vc = self.parentViewController as? CardController {
            do {
                if let moc = AppDelegate.getContext() {
                    let newResponse = NSEntityDescription.insertNewObjectForEntityForName("Response", inManagedObjectContext: moc) as? Response
                    newResponse!.correct = correct
                    newResponse!.card = self.card
                    newResponse!.created = NSDate()
                    newResponse!.user = AppDelegate.getUser()
                    try moc.save()
                    vc.submitResponse(newResponse!)
                }
            }
            catch let error as NSError {
                NSLog(error.description)
            }
        }
    }
    
    @IBAction func wrongClick(sender: UIButton) {
        self.submitResponse(false)
    }
    
    @IBAction func correctClick(sender: UIButton) {
        self.submitResponse(true)
    }
    
    @IBAction func continueClick(sender: UIButton) {
        if let vc = self.parentViewController as? CardController {
            vc.submitResponse(vc.intermediateResponse!)
        }
    }
}