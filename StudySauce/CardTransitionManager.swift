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
    private var flashView: AutoSizingTextView? = nil
    
    internal var reversed: Bool = false
    internal var transitioning = false
    
    override init() {
        super.init()
        
        let panGesture = UIPanGestureRecognizer()
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        panGesture.addTarget(self, action: "handleOnstagePan:")
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = false
        tap.addTarget(self, action: "handleOnstageTap:")
        AppDelegate.instance().window!.addGestureRecognizer(panGesture)
        AppDelegate.instance().window!.addGestureRecognizer(tap)

    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let vc = AppDelegate.visibleViewController()
        if let page = vc as? TutorialPageViewController {
            let total = page.presentationCountForPageViewController(page)
            let index = page.presentationIndexForPageViewController(page)
            if index < total || index > 0 {
                return true
            }
        }
        
        if vc.canPerformSegueWithIdentifier("next")
            || vc.canPerformSegueWithIdentifier("last")
            || (vc as? CardController)?.subview?.canPerformSegueWithIdentifier("next") == true
            || (vc as? CardController)?.subview?.canPerformSegueWithIdentifier("last") == true {
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
        NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: "doNextTap", userInfo: nil, repeats: false)
    }
    
    func doNextTap() {
        if !self.transitioning {
            let vc = AppDelegate.visibleViewController()
            self.interactive = false
            if let page = vc as? TutorialPageViewController {
                if let next = page.pageViewController(page, viewControllerAfterViewController: page.viewControllers![0]) {
                    page.setViewControllers([next], direction: .Forward, animated: true, completion: nil)
                    return
                }
            }

            if let card = vc as? CardController {
                if card.subview?.canPerformSegueWithIdentifier("next") == true {
                    card.subview?.performSegueWithIdentifier("next", sender: self)
                }
            }
            else {
                if vc.canPerformSegueWithIdentifier("next") {
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

                let vc = AppDelegate.visibleViewController()
                if let page = vc as? TutorialPageViewController {
                    if d > 0 {
                        if let last = page.pageViewController(page, viewControllerBeforeViewController: page.viewControllers![0]) {
                            self.transitioning = true
                            page.setViewControllers([last], direction: .Reverse, animated: true, completion: {_ in
                                self.transitioning = false
                            })
                            return
                        }
                    }
                    else {
                        if let next = page.pageViewController(page, viewControllerAfterViewController: page.viewControllers![0]) {
                            self.transitioning = true
                            page.setViewControllers([next], direction: .Forward, animated: true, completion: {_ in
                                self.transitioning = false
                            })
                            return
                        }
                    }
                }

                if let card = vc as? CardController {
                    if card.subview?.canPerformSegueWithIdentifier(d > 0 ? "last" : "next") == true {
                        self.transitioning = true
                        self.interactive = true
                        card.subview?.performSegueWithIdentifier(d > 0 ? "last" : "next", sender: self)
                    }
                }
                else {
                    if vc.canPerformSegueWithIdentifier(d > 0 ? "last" : "next") {
                        self.transitioning = true
                        self.interactive = true
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
        if next.modalPresentationStyle == .OverCurrentContext {
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
                        vis.alpha = 0.85
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
        if last.getOrientation() != UIApplication.sharedApplication().statusBarOrientation {
            last.orientation = UIApplication.sharedApplication().statusBarOrientation
            AppDelegate.instance().rerenderView(last.view)
        }
        if next.getOrientation() != UIApplication.sharedApplication().statusBarOrientation {
            next.orientation = UIApplication.sharedApplication().statusBarOrientation
            AppDelegate.instance().rerenderView(next.view)
        }
        next.view.frame = CGRect(x: 0, y: 0, width: next.view.bounds.width, height: next.view.bounds.height)
        last.view.frame = CGRect(x: 0, y: 0, width: next.view.bounds.width, height: next.view.bounds.height)

        let origLast = last
        let origColor = origLast.view.backgroundColor
        
        // if both controllers are card controllers translate embeddedView and leave navigation in place
        if last is CardController && next is CardController {
            origLast.view.backgroundColor = UIColor.clearColor()
            last = (last as! CardController).subview!
            next = (next as! CardController).subview!
        }
        
        //self.setupShadow(container)
        let moveNext = UIScreen.mainScreen().bounds.width
        var moveLast = -UIScreen.mainScreen().bounds.width
        
        if next.modalPresentationStyle == .OverCurrentContext {
            moveLast = 0.0
        }
        
        // if both controllers have nueral dark transition content
        let lastBackground = last.view.subviews.filter({v -> Bool in return v.tag == 23}).first
        let nextBackground = next.view.subviews.filter({v -> Bool in return v.tag == 23}).first
        if lastBackground != nil && nextBackground != nil {
            lastBackground!.alpha = 0
            if self.presenting {
                nextBackground!.transform = CGAffineTransformMakeTranslation(moveLast, 0)
            }
            else {
                nextBackground!.transform = CGAffineTransformMakeTranslation(0, 0)
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
        var alreadyMoved = false
        if let vc = origLast as? CardController where vc.intermediateResponse != nil && (vc.subview as? CardResponseController == nil || (vc.subview as? CardSelfController)?.correctButton != nil) {
            alreadyMoved = true
            next.view.transform = CGAffineTransformMakeTranslation(0, 0)
            last.view.transform = CGAffineTransformMakeTranslation(moveLast, 0)
            self.setupCorrectFlash(vc.intermediateResponse!.correct == 1, container: container!)
        }
        
        // move titles around
        let lastTitle = last.view.subviews.filter({v -> Bool in return v.tag == 25}).first as? UILabel
        let lastButton = last.view.subviews.filter({v -> Bool in return v.tag == 26}).first as? UIButton
        let nextTitle = next.view.subviews.filter({v -> Bool in return v.tag == 25}).first as? UILabel
        let nextButton = next.view.subviews.filter({v -> Bool in return v.tag == 26}).first as? UIButton

        if self.presenting {
            if lastButton != nil && nextButton != nil {
                lastButton!.transform = CGAffineTransformMakeTranslation(0, 0)
                nextButton!.hidden = !alreadyMoved
            }
            if lastTitle != nil && nextTitle != nil {
                lastTitle!.transform = CGAffineTransformMakeTranslation(0, 0)
                lastTitle!.alpha = 1
                if lastTitle!.text == nextTitle!.text {
                    nextTitle!.hidden = !alreadyMoved
                }
            }
        }
        else {
            if lastButton != nil && nextButton != nil {
                lastButton!.transform = CGAffineTransformMakeTranslation(moveNext, 0)
                nextButton!.hidden = !alreadyMoved
            }
            if lastTitle != nil && nextTitle != nil {
                lastTitle!.transform = CGAffineTransformMakeTranslation(moveNext, 0)
                lastTitle!.alpha = 0
                if lastTitle!.text == nextTitle!.text {
                    nextTitle!.hidden = !alreadyMoved
                }
            }
        }
        
        let duration = self.transitionDuration(transitionContext)
        
        // perform the animation!
        UIView.animateWithDuration(duration, delay: 0.0, options: [], animations: {
            if self.flashView != nil {
                self.flashView!.alpha = 0
            }
            else {
                if self.presenting {
                    next.view.transform = CGAffineTransformIdentity
                    last.view.transform = CGAffineTransformMakeTranslation(moveLast, 0)
                    if next.modalPresentationStyle == .OverCurrentContext {
                        if !UIAccessibilityIsReduceTransparencyEnabled() {
                            if let vis = next.view.subviews.filter({$0 is UIVisualEffectView}).first {
                                vis.alpha = 0.85
                            }
                        }
                        else {
                            next.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.85)
                        }
                    }
                    if lastBackground != nil && nextBackground != nil {
                        nextBackground!.transform = CGAffineTransformMakeTranslation(0, 0)
                    }
                    if lastButton != nil && nextButton != nil {
                        lastButton!.transform = CGAffineTransformMakeTranslation(moveNext, 0)
                    }
                    if lastTitle != nil && nextTitle != nil {
                        lastTitle!.transform = CGAffineTransformMakeTranslation(moveNext, 0)
                        lastTitle!.alpha = 0
                    }
                }
                else {
                    last.view.transform = CGAffineTransformMakeTranslation(0, 0)
                    next.view.transform = CGAffineTransformMakeTranslation(moveNext, 0)
                    if next.modalPresentationStyle == .OverCurrentContext {
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
                    }
                    if lastButton != nil && nextButton != nil {
                        lastButton!.transform = CGAffineTransformMakeTranslation(0, 0)
                    }
                    if lastTitle != nil && nextTitle != nil {
                        lastTitle!.transform = CGAffineTransformMakeTranslation(0, 0)
                        lastTitle!.alpha = 1
                    }
                }
            }
            
            }, completion: { finished in
                self.flashView = nil
                origLast.view.backgroundColor = origColor
                if lastBackground != nil && nextBackground != nil {
                    lastBackground!.alpha = 1
                    nextBackground!.transform = CGAffineTransformMakeTranslation(0, 0)
                }
                if nextButton != nil {
                    nextButton!.hidden = false
                }
                if nextTitle != nil {
                    nextTitle!.hidden = false
                }
                last.view.transform = CGAffineTransformMakeTranslation(0, 0)
                next.view.transform = CGAffineTransformMakeTranslation(0, 0)
                AppDelegate.instance().window!.rootViewController!.view.layer.mask = nil
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
                self.reversed = false
                self.transitioning = false

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
        self.flashView!.setManually = true
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

