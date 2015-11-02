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
    internal var backgroundView: AutoSizingTextView? = nil
    private var enterPanGesture: UIScreenEdgePanGestureRecognizer!
    
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
                if vc.intermediateResponse?.correct != 1 {
                    self.enterPanGesture = UIScreenEdgePanGestureRecognizer()
                    self.enterPanGesture.addTarget(self, action:"handleOnstagePan:")
                    self.enterPanGesture.edges = UIRectEdge.Right
                    self.view.addGestureRecognizer(self.enterPanGesture)
                }
            }
            self.card = vc.card;
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
            self.performSegueWithIdentifier("next", sender: self)
        }
    }
    
    func handleOnstagePan(pan: UIPanGestureRecognizer){
        // how much distance have we panned in reference to the parent view?
        let translation = pan.translationInView(pan.view!)
        
        // do some math to translate this to a percentage based value
        let d =  translation.x / CGRectGetWidth(pan.view!.bounds)
        
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
            default: // .Ended, .Cancelled, .Failed ...
            
            // return flag to false and finish the transition
            if(d > 0.2 || d < -0.2){
                // threshold crossed: finish
                if let vc = self.parentViewController as? CardController {
                    vc.intermediateResponse = nil
                }
                self.performSegueWithIdentifier("next", sender: self)
            }
            else {
                // threshold not met: cancel
            }
        }
    }
    
    @IBAction func wrongClick(sender: UIButton) {
        self.submitResponse(false)
    }
    
    @IBAction func correctClick(sender: UIButton) {
        self.submitResponse(true)
    }
    
}