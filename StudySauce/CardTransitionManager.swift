//
//  CardTransitionManager.swift
//  StudySauce
//
//  Created by Brian Cullinan on 10/29/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class CardTransitionManager: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
    
    private var presenting = false
    private var interactive = false
    private var flashView: UITextView? = nil
    var panGesture: UIPanGestureRecognizer? = nil
    var tap: UITapGestureRecognizer? = nil
    
    internal var reversed: Bool = false
    internal var transitioning = false
    
    override init() {
        super.init()
        doMain {
        self.panGesture = UIPanGestureRecognizer()
        self.panGesture!.delegate = self
        self.panGesture!.cancelsTouchesInView = false
        self.panGesture!.addTarget(self, action: #selector(CardTransitionManager.handleOnstagePan(_:)))
        self.tap = UITapGestureRecognizer()
        self.tap!.delegate = self
        self.tap!.numberOfTapsRequired = 1
        self.tap!.cancelsTouchesInView = false
        self.tap!.addTarget(self, action: #selector(CardTransitionManager.handleOnstageTap(_:)))
        AppDelegate.instance().window!.addGestureRecognizer(self.panGesture!)
        AppDelegate.instance().window!.addGestureRecognizer(self.tap!)
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        AppDelegate.lastTouch = NSDate()
        
        if touch.view is UIButton {
            return false
        }
        
        let vc = AppDelegate.visibleViewController()
        
        if vc.canPerformSegueWithIdentifier("next")
            || vc.canPerformSegueWithIdentifier("last")
            || (vc as? CardController)?.subview?.canPerformSegueWithIdentifier("next") == true
            || (vc as? CardController)?.subview?.canPerformSegueWithIdentifier("last") == true
            || vc.respondsToSelector(Selector("lastClick"))
            || vc.respondsToSelector(Selector("nextClick"))
        {
            if !self.transitioning {
                return true
            }
        }
        return false
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /*
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let tap = gestureRecognizer as? UITapGestureRecognizer {
            self.handleOnstageTap(tap)
            return true
        }
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            self.handleOnstagePan(pan)
            return true
        }
        return false
    }
    */
    
    func handleOnstageTap(tap: UITapGestureRecognizer) {
        NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: #selector(CardTransitionManager.doNextTap), userInfo: nil, repeats: false)
    }
    
    func doNextTap() {
        if !self.transitioning {
            let vc = AppDelegate.visibleViewController()
            self.interactive = false
            
            if vc.respondsToSelector(Selector("nextClick")) {
                vc.performSelector(Selector("nextClick"))
            }

            if let card = vc as? CardController {
                if card.subview?.canPerformSegueWithIdentifier("next") == true {
                    self.transitioning = true
                    card.subview?.performSegueWithIdentifier("next", sender: self)
                }
            }
            else {
                if vc.canPerformSegueWithIdentifier("next") {
                    self.transitioning = true
                    vc.performSegueWithIdentifier("next", sender: self)
                }
            }
        }
    }
    
    func handleOnstagePan(pan: UIPanGestureRecognizer){
        
        // how much distance have we panned in reference to the parent view?
        let translation = pan.translationInView(pan.view!)
        
        // do some math to translate this to a percentage based value
        let d =  translation.x / CGRectGetWidth(pan.view!.bounds)
        
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
        case UIGestureRecognizerState.Changed:
            fallthrough
        case UIGestureRecognizerState.Began:
            // set our interactive flag to true
            if d != 0 && !self.transitioning {
                self.interactive = true
                
                let vc = AppDelegate.visibleViewController()
                
                if d > 0 && vc.respondsToSelector(Selector("lastClick")) {
                    vc.performSelector(Selector("lastClick"))
                }
                else if vc.respondsToSelector(Selector("nextClick")) {
                    vc.performSelector(Selector("nextClick"))
                }

                if let card = vc as? CardController {
                    if card.subview?.canPerformSegueWithIdentifier(d > 0 ? "last" : "next") == true {
                        self.transitioning = true
                        card.subview?.performSegueWithIdentifier(d > 0 ? "last" : "next", sender: self)
                    }
                }
                else {
                    if vc.canPerformSegueWithIdentifier(d > 0 ? "last" : "next") {
                        self.transitioning = true
                        vc.performSegueWithIdentifier(d > 0 ? "last" : "next", sender: self)
                    }
                }
                
            }
            // trigger the start of the transition
            else if d < -0.02 {
                // update progress of the transition
                self.updateInteractiveTransition(-d)
            }
            else if d > 0.02 {
                self.updateInteractiveTransition(d)
            }
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            if self.interactive {
                // return flag to false and finish the transition
                self.interactive = false
                self.transitioning = false
                if d < -0.1 || d > 0.2 {
                    // threshold crossed: finish
                    self.finishInteractiveTransition()
                }
                else {
                    // threshold not met: cancel
                    self.cancelInteractiveTransition()
                }
            }
        }
    }
    
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    
    // animate a change from one viewcontroller to another
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitioning = true

        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView()
        
        // create a tuple of our screens
        let screens : (from:UIViewController, to:UIViewController) = (
            transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!,
            transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)
        
        // assign references to our menu view controller and the 'bottom' view controller from the tuple
        // remember that our menuViewController will alternate between the from and to view controller depending if we're presenting or dismissing
        var next = !self.presenting ? screens.from : screens.to 
        var last = !self.presenting ? screens.to : screens.from
        
        // add the both views to our view controller
        if next.modalPresentationStyle == .OverCurrentContext && last.modalPresentationStyle != .OverCurrentContext {
            container!.addSubview(last.view)
            container!.addSubview(next.view)
            if self.presenting {
                if !UIAccessibilityIsReduceTransparencyEnabled() {
                    if let vis = next.view.subviews.filter({$0 is UIVisualEffectView}).first {
                        vis.alpha = 0
                    }
                }
                else {
                    next.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
                }
            }
            else {
                if !UIAccessibilityIsReduceTransparencyEnabled() {
                    if let vis = next.view.subviews.filter({$0 is UIVisualEffectView}).first {
                        vis.alpha = 1
                    }
                }
                else {
                    next.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.85)
                }
            }
        }
        else {
            container!.addSubview(next.view)
            container!.addSubview(last.view)
        }
        last.view.transform = CGAffineTransformMakeTranslation(0, 0)
        next.view.transform = CGAffineTransformMakeTranslation(0, 0)
        next.view.bounds = UIScreen.mainScreen().bounds
        last.view.bounds = UIScreen.mainScreen().bounds
        next.view.frame = CGRect(x: 0, y: 0, width: next.view.bounds.width, height: next.view.bounds.height)
        last.view.frame = CGRect(x: 0, y: 0, width: next.view.bounds.width, height: next.view.bounds.height)
        if last.getOrientation() != UIApplication.sharedApplication().statusBarOrientation {
            last.orientation = UIApplication.sharedApplication().statusBarOrientation
            AppDelegate.rerenderView(last.view)
        }
        if next.getOrientation() != UIApplication.sharedApplication().statusBarOrientation {
            next.orientation = UIApplication.sharedApplication().statusBarOrientation
            AppDelegate.rerenderView(next.view)
        }

        let origLast = last
        let origColor = origLast.view.backgroundColor
        
        // if both controllers are card controllers translate embeddedView and leave navigation in place
        if last is CardController && next is CardController {
            origLast.view.backgroundColor = UIColor.clearColor()
            last = (last as! CardController).subview!
            next = (next as! CardController).subview!
        }
        
        //self.setupShadow(container)
        var moveNext = UIScreen.mainScreen().bounds.width
        var moveLast = -UIScreen.mainScreen().bounds.width
        
        if next.modalPresentationStyle == .OverCurrentContext && last.modalPresentationStyle != .OverCurrentContext {
            moveLast = 0.0
        }
        
        // if both controllers have nueral dark transition content
        let lastBackground = (last.view ~> (UIVisualEffectView.self ~* {$0.tag == 23})).first
        let nextBackground = (next.view ~> (UIVisualEffectView.self ~* {$0.tag == 23})).first
        nextBackground?.transform = CGAffineTransformMakeTranslation(0, 0)
        lastBackground?.transform = CGAffineTransformMakeTranslation(0, 0)
        if lastBackground != nil && nextBackground != nil {
            if self.presenting {
                nextBackground!.hidden = false
                lastBackground!.hidden = true
                nextBackground!.transform = CGAffineTransformMakeTranslation(-moveNext, 0)
                lastBackground!.transform = CGAffineTransformMakeTranslation(0, 0)
            }
            else {
                nextBackground!.hidden = false
                lastBackground!.hidden = true
                nextBackground!.transform = CGAffineTransformMakeTranslation(0, 0)
                lastBackground!.transform = CGAffineTransformMakeTranslation(-moveLast, 0)
            }
        }

        // prepare menu items to slide in
        if self.presenting {
            last.view.transform = CGAffineTransformMakeTranslation(0, 0)
            next.view.transform = CGAffineTransformMakeTranslation(moveNext, 0)
        }
        else {
            last.view.transform = CGAffineTransformMakeTranslation(moveLast, 0)
            next.view.transform = CGAffineTransformMakeTranslation(0, 0)
        }
        if let vc = origLast as? CardController where vc.intermediateResponse != nil && (vc.subview as? CardResponseController == nil || (vc.subview as? CardSelfController)?.correctButton != nil) {
            next.view.transform = CGAffineTransformMakeTranslation(0, 0)
            last.view.transform = CGAffineTransformMakeTranslation(moveLast, 0)
            moveNext = 0.0
            self.setupCorrectFlash(vc.intermediateResponse!, container: container!)
        }
        
        // move titles around
        let lastTitle = (last.view ~> (UILabel.self ~* {$0.tag == 25})).first
        let lastButton = (last.view ~> (UIView.self ~* {$0.tag == 26}))
        let nextTitle = (next.view ~> (UILabel.self ~* {$0.tag == 25})).first
        let nextButton = (next.view ~> (UIView.self ~* {$0.tag == 26}))

        var alwaysHidden = false
        if nextTitle?.hidden == true {
            alwaysHidden = true
        }
        
        lastButton.each {$0.transform = CGAffineTransformMakeTranslation(0, 0)}
        nextButton.each {$0.transform = CGAffineTransformMakeTranslation(0, 0)}

        if self.presenting {
            if lastButton.count > 0 && nextButton.count > 0 {
                lastButton.each {$0.transform = CGAffineTransformMakeTranslation(0, 0)}
                nextButton.each {$0.transform = CGAffineTransformMakeTranslation(-moveNext, 0)}
            }
            if lastTitle != nil && nextTitle != nil {
                lastTitle!.transform = CGAffineTransformMakeTranslation(0, 0)
                lastTitle!.alpha = 1
            }
        }
        else {
            if lastButton.count > 0 && nextButton.count > 0 {
                lastButton.each {$0.transform = CGAffineTransformMakeTranslation(-moveLast, 0)}
                nextButton.each {$0.transform = CGAffineTransformMakeTranslation(0, 0)}
            }
            if lastTitle != nil && nextTitle != nil {
                lastTitle!.transform = CGAffineTransformMakeTranslation(-moveLast, 0)
                lastTitle!.alpha = 0
            }
        }
        
        let duration = self.transitionDuration(transitionContext)
        last.view.hidden = false
        next.view.hidden = false
        
        // perform the animation!
        UIView.animateWithDuration(duration, delay: 0.0, options: [], animations: {
            if self.flashView != nil {
                self.flashView!.alpha = 0
            }
            else {
                if self.presenting {
                    next.view.transform = CGAffineTransformIdentity
                    last.view.transform = CGAffineTransformMakeTranslation(moveLast, 0)
                    if next.modalPresentationStyle == .OverCurrentContext && last.modalPresentationStyle != .OverCurrentContext {
                        if !UIAccessibilityIsReduceTransparencyEnabled() {
                            if let vis = next.view.subviews.filter({$0 is UIVisualEffectView}).first {
                                vis.alpha = 1
                            }
                        }
                        else {
                            next.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.85)
                        }
                    }
                    if lastBackground != nil && nextBackground != nil {
                        nextBackground!.transform = CGAffineTransformMakeTranslation(0, 0)
                        lastBackground!.transform = CGAffineTransformMakeTranslation(moveLast, 0)
                    }
                    if lastButton.count > 0 && nextButton.count > 0 {
                        lastButton.each {$0.transform = CGAffineTransformMakeTranslation(-moveLast, 0)}
                        nextButton.each {$0.transform = CGAffineTransformMakeTranslation(0, 0)}
                    }
                    if lastTitle != nil && nextTitle != nil {
                        lastTitle!.transform = CGAffineTransformMakeTranslation(-moveLast, 0)
                        lastTitle!.alpha = 0
                    }
                }
                else {
                    last.view.transform = CGAffineTransformMakeTranslation(0, 0)
                    next.view.transform = CGAffineTransformMakeTranslation(moveNext, 0)
                    if next.modalPresentationStyle == .OverCurrentContext && last.modalPresentationStyle != .OverCurrentContext {
                        if !UIAccessibilityIsReduceTransparencyEnabled() {
                            if let vis = next.view.subviews.filter({$0 is UIVisualEffectView}).first {
                                vis.alpha = 0
                            }
                        }
                        else {
                            next.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
                        }
                    }
                    if lastBackground != nil && nextBackground != nil {
                        nextBackground!.transform = CGAffineTransformMakeTranslation(moveLast, 0)
                        lastBackground!.transform = CGAffineTransformMakeTranslation(0, 0)
                    }
                    if lastButton.count > 0 && nextButton.count > 0 {
                        lastButton.each {$0.transform = CGAffineTransformMakeTranslation(0, 0)}
                        nextButton.each {$0.transform = CGAffineTransformMakeTranslation(-moveNext, 0)}
                    }
                    if lastTitle != nil && nextTitle != nil {
                        lastTitle!.transform = CGAffineTransformMakeTranslation(0, 0)
                        lastTitle!.alpha = 1
                    }
                }
            }
            
            }, completion: { finished in
                self.flashView = nil
                next.view.transform = CGAffineTransformIdentity
                last.view.transform = CGAffineTransformIdentity
                origLast.view.backgroundColor = origColor
                if !alwaysHidden && nextTitle != nil {
                    nextTitle!.hidden = false
                }
                if lastBackground != nil && nextBackground != nil {
                    if self.presenting {
                        nextBackground!.hidden = false
                    }
                    else {
                        lastBackground!.hidden = false
                    }
                }
                AppDelegate.instance().window!.rootViewController!.view.layer.mask = nil
                // tell our transitionContext object that we've finished animating
                if(transitionContext.transitionWasCancelled()){
                    
                    transitionContext.completeTransition(false)
                    if self.presenting {
                        if next.modalPresentationStyle != .OverCurrentContext {
                            next.view.hidden = true
                        }
                    }
                    else {
                        last.view.hidden = true
                    }
                    // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                    UIApplication.sharedApplication().keyWindow!.addSubview(screens.from.view)
                    
                }
                else {
                    
                    transitionContext.completeTransition(true)
                    if self.presenting {
                        if next.modalPresentationStyle != .OverCurrentContext {
                            last.view.hidden = true
                        }
                    }
                    else {
                        next.view.hidden = true
                    }
                    // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                    UIApplication.sharedApplication().keyWindow!.addSubview(screens.to.view)
                    
                }
                self.reversed = false
                self.transitioning = false
                AppDelegate.setAnalytics()
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
        self.flashView = UITextView()
        container.addSubview(self.flashView!)
        self.flashView!.alpha = 1.0
        self.flashView!.textColor = UIColor.whiteColor()
        self.flashView!.textAlignment = NSTextAlignment.Center
        self.flashView!.font = UIFont.systemFontOfSize(250.0)
        self.flashView!.frame = CGRect(x: 0, y: 0, width: container.frame.width, height: container.frame.height)
        if correct {
            self.flashView!.text = "✔︎"
            self.flashView!.backgroundColor = UIColor(0x078600)
        }
        else {
            self.flashView!.text = "✘"
            self.flashView!.backgroundColor = UIColor(0xFF0D00)
        }
        var topCorrect = (self.flashView!.bounds.size.height - self.flashView!.contentSize.height * self.flashView!.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        self.flashView!.contentInset.top = topCorrect
    }
    
    // return how many seconds the transiton animation will take
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // return the animataor when presenting a viewcontroller
    // rememeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = !self.reversed
        return self
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = self.reversed
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

