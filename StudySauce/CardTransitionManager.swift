//
//  CardTransitionManager.swift
//  StudySauce
//
//  Created by Brian Cullinan on 10/29/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class CardTransitionManager: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    private var presenting = false
    private var interactive = false
    private var flashView: AutoSizingTextView? = nil
    internal var reversed: Bool = false
    
    private var enterPanGesture: UIPanGestureRecognizer!
    private var tap: UITapGestureRecognizer!
    var sourceViewController: CardController! {
        didSet {
            if self.enterPanGesture == nil {
                self.enterPanGesture = UIPanGestureRecognizer()
                self.enterPanGesture.addTarget(self, action:"handleOnstagePan:")
                self.tap = UITapGestureRecognizer()
                self.tap.addTarget(self, action: "handleOnstageTap:")
                self.tap.numberOfTapsRequired = 1
            }
            //else if oldValue != nil {
            //    oldValue.view.removeGestureRecognizer(self.enterPanGesture)
            //    oldValue.view.removeGestureRecognizer(self.tap)
            //}
            self.sourceViewController.view.addGestureRecognizer(self.enterPanGesture)
            self.sourceViewController.view.addGestureRecognizer(self.tap)
        }
    }
    
    private var exitPanGesture: UIPanGestureRecognizer!
    
    var destinationViewController: CardController! {
        didSet {
            if self.exitPanGesture == nil {
                self.exitPanGesture = UIPanGestureRecognizer()
                self.exitPanGesture.addTarget(self, action:"handleOffstagePan:")
            }
            //else if oldValue != nil {
            //    oldValue.view.addGestureRecognizer(self.exitPanGesture)
            //}
            self.destinationViewController.view.addGestureRecognizer(self.exitPanGesture)
        }
    }
    
    func handleOnstageTap(tap: UITapGestureRecognizer) {
        self.sourceViewController.subview?.performSegueWithIdentifier("next", sender: self)
    }
    
    func handleOnstagePan(pan: UIPanGestureRecognizer){
        // how much distance have we panned in reference to the parent view?
        let translation = pan.translationInView(pan.view!)
        
        // do some math to translate this to a percentage based value
        let d =  translation.x / CGRectGetWidth(pan.view!.bounds)
        
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
            
        case UIGestureRecognizerState.Began:
            // set our interactive flag to true
            self.interactive = true
            
            // trigger the start of the transition
            self.sourceViewController.subview?.performSegueWithIdentifier("next", sender: self)
            break
            
        case UIGestureRecognizerState.Changed:
            if d < 0.02 {
                // update progress of the transition
                self.updateInteractiveTransition(-d)
            }
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            
            // return flag to false and finish the transition
            self.interactive = false
            if d < -0.1 {
                // threshold crossed: finish
                self.finishInteractiveTransition()
            }
            else {
                // threshold not met: cancel
                self.cancelInteractiveTransition()
            }
        }
    }
    
    // pretty much the same as 'handleOnstagePan' except
    // we're panning from right to left
    // perfoming our exitSegeue to start the transition
    func handleOffstagePan(pan: UIPanGestureRecognizer){
        
        let translation = pan.translationInView(pan.view!)
        let d =  translation.x / CGRectGetWidth(pan.view!.bounds)
        
        switch (pan.state) {
            
        case UIGestureRecognizerState.Began:
            self.interactive = true
            self.destinationViewController.subview?.performSegueWithIdentifier("last", sender: self)
            break
            
        case UIGestureRecognizerState.Changed:
            if d > 0.02 {
                self.updateInteractiveTransition(d)
            }
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            self.interactive = false
            if d > 0.1 {
                self.finishInteractiveTransition()
            }
            else {
                self.cancelInteractiveTransition()
            }
        }
    }
    
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    
    // animate a change from one viewcontroller to another
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView()
        
        // create a tuple of our screens
        let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!, transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
        
        // assign references to our menu view controller and the 'bottom' view controller from the tuple
        // remember that our menuViewController will alternate between the from and to view controller depending if we're presenting or dismissing
        var next = !self.presenting ? screens.from : screens.to 
        var last = !self.presenting ? screens.to : screens.from
        
        // add the both views to our view controller
        if self.presenting {
            next.preferredContentSize = CGSizeMake(last.view.frame.width, last.view.frame.height)
        }
        else {
            last.preferredContentSize = CGSizeMake(next.view.frame.width, next.view.frame.height)
        }
        container!.addSubview(last.view)
        container!.addSubview(next.view)

        let parent = next
        let origLast = last
        let origColor = parent.view.backgroundColor
        if last as? CardController != nil && next as? CardController != nil {
            parent.view.backgroundColor = UIColor.clearColor()
            last = (last as! CardController).subview!
            next = (next as! CardController).subview!
        }
        
        //self.setupShadow(container)

        // prepare menu items to slide in
        if (self.presenting){
            last.view.transform = self.offStage(0.0)
            next.view.transform = self.offStage(last.view.frame.width)
        }
        else {
            last.view.transform = self.offStage(-next.view.frame.width)
            next.view.transform = self.offStage(0.0)
        }
        if let vc = origLast as? CardController where vc.intermediateResponse != nil && (vc.subview as? CardSelfController == nil || (vc.subview as! CardSelfController).correctButton != nil) {
            next.view.transform = self.offStage(0.0)
            last.view.transform = self.offStage(-last.view.frame.width)
            self.setupCorrectFlash(vc.intermediateResponse!.correct == 1, container: container!)
        }
        
        let duration = self.transitionDuration(transitionContext)
        
        // perform the animation!
        UIView.animateWithDuration(duration, delay: 0.0, options: [], animations: {
            if self.flashView != nil {
                self.flashView!.alpha = 0
            }
            else {
                if self.presenting {
                    next.view.transform = self.offStage(0.0)
                    last.view.transform = self.offStage(-last.view.frame.width)
                }
                else {
                    last.view.transform = self.offStage(0.0)
                    next.view.transform = self.offStage(next.view.frame.width)
                }
            }
            
            }, completion: { finished in
                self.flashView = nil
                parent.view.backgroundColor = origColor
                // tell our transitionContext object that we've finished animating
                if(transitionContext.transitionWasCancelled()){
                    
                    transitionContext.completeTransition(false)
                    // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                    UIApplication.sharedApplication().keyWindow!.addSubview(screens.from.view)
                    
                }
                else {
                    
                    transitionContext.completeTransition(true)
                    // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                    UIApplication.sharedApplication().keyWindow!.addSubview(screens.to.view)
                    
                }
                
        })
        
    }
    
    /*
    func setupShadow(container: CardController) -> Void {
        let shadowPath = UIBezierPath(rect: last.embeddedView.bounds)
        last.embeddedView.clipsToBounds = false
        last.embeddedView.layer.masksToBounds = false
        last.embeddedView.layer.shadowColor = UIColor.blackColor().CGColor
        last.embeddedView.layer.shadowOffset = CGSizeMake(10, 0)
        last.embeddedView.layer.shadowRadius = 5
        last.embeddedView.layer.shadowOpacity = 0.4
        last.embeddedView.layer.shadowPath = shadowPath.CGPath;
        last.view.layer.masksToBounds = false
        last.view.clipsToBounds = false
    }
*/
    
    func setupCorrectFlash(correct: Bool, container: UIView) {
        self.flashView = AutoSizingTextView()
        container.addSubview(self.flashView!)
        self.flashView!.setManually = true // only use vertical center alignment benefits of this control, do not automatically set fond size
        self.flashView!.alpha = 1.0
        self.flashView!.textColor = UIColor.whiteColor()
        self.flashView!.textAlignment = NSTextAlignment.Center
        self.flashView!.font = UIFont.systemFontOfSize(250.0)
        self.flashView!.frame = CGRect(x: 0, y: 0, width: container.frame.width, height: container.frame.height)
        if correct {
            self.flashView!.text = "✔︎"
            self.flashView!.backgroundColor = UIColor(netHex:0x078600)
        }
        else {
            self.flashView!.text = "✘"
            self.flashView!.backgroundColor = UIColor(netHex:0xFF0D00)
        }
    }
    
    func offStage(amount: CGFloat) -> CGAffineTransform {
        return CGAffineTransformMakeTranslation(amount, 0)
    }
    
    // return how many seconds the transiton animation will take
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // return the animataor when presenting a viewcontroller
    // rememeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = !reversed
        return self
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = reversed
        return self
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return self.interactive ? self : nil
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
}

