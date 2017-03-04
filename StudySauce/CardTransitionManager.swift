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
    
    fileprivate var presenting = false
    fileprivate var interactive = false
    fileprivate var flashView: UITextView? = nil
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        AppDelegate.lastTouch = Date()
        
        if touch.view is UIButton {
            return false
        }
        
        let vc = AppDelegate.visibleViewController()
        
        if vc.canPerformSegueWithIdentifier("next")
            || vc.canPerformSegueWithIdentifier("last")
            || (vc as? CardController)?.subview?.canPerformSegueWithIdentifier("next") == true
            || (vc as? CardController)?.subview?.canPerformSegueWithIdentifier("last") == true
            || vc.responds(to: Selector("lastClick"))
            || vc.responds(to: Selector("nextClick"))
        {
            if !self.transitioning {
                return true
            }
        }
        return false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
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
    
    func handleOnstageTap(_ tap: UITapGestureRecognizer) {
        Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(CardTransitionManager.doNextTap), userInfo: nil, repeats: false)
    }
    
    func doNextTap() {
        if !self.transitioning {
            let vc = AppDelegate.visibleViewController()
            self.interactive = false
            
            if vc.responds(to: Selector("nextClick")) {
                vc.perform(Selector("nextClick"))
            }

            if let card = vc as? CardController {
                if card.subview?.canPerformSegueWithIdentifier("next") == true {
                    self.transitioning = true
                    card.subview?.performSegue(withIdentifier: "next", sender: self)
                }
            }
            else {
                if vc.canPerformSegueWithIdentifier("next") {
                    self.transitioning = true
                    vc.performSegue(withIdentifier: "next", sender: self)
                }
            }
        }
    }
    
    func handleOnstagePan(_ pan: UIPanGestureRecognizer){
        
        // how much distance have we panned in reference to the parent view?
        let translation = pan.translation(in: pan.view!)
        
        // do some math to translate this to a percentage based value
        let d =  translation.x / pan.view!.bounds.width
        
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
        case UIGestureRecognizerState.changed:
            fallthrough
        case UIGestureRecognizerState.began:
            // set our interactive flag to true
            if d != 0 && !self.transitioning {
                self.interactive = true
                
                let vc = AppDelegate.visibleViewController()
                
                if d > 0 && vc.responds(to: Selector("lastClick")) {
                    vc.perform(Selector("lastClick"))
                }
                else if vc.responds(to: Selector("nextClick")) {
                    vc.perform(Selector("nextClick"))
                }

                if let card = vc as? CardController {
                    if card.subview?.canPerformSegueWithIdentifier(d > 0 ? "last" : "next") == true {
                        self.transitioning = true
                        card.subview?.performSegue(withIdentifier: d > 0 ? "last" : "next", sender: self)
                    }
                }
                else {
                    if vc.canPerformSegueWithIdentifier(d > 0 ? "last" : "next") {
                        self.transitioning = true
                        vc.performSegue(withIdentifier: d > 0 ? "last" : "next", sender: self)
                    }
                }
                
            }
            // trigger the start of the transition
            else if d < -0.02 {
                // update progress of the transition
                self.update(-d)
            }
            else if d > 0.02 {
                self.update(d)
            }
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            if self.interactive {
                // return flag to false and finish the transition
                self.interactive = false
                self.transitioning = false
                if d < -0.1 || d > 0.2 {
                    // threshold crossed: finish
                    self.finish()
                }
                else {
                    // threshold not met: cancel
                    self.cancel()
                }
            }
        }
    }
    
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    
    // animate a change from one viewcontroller to another
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitioning = true

        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView
        
        // create a tuple of our screens
        let screens : (from:UIViewController, to:UIViewController) = (
            transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!,
            transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!)
        
        // assign references to our menu view controller and the 'bottom' view controller from the tuple
        // remember that our menuViewController will alternate between the from and to view controller depending if we're presenting or dismissing
        var next = !self.presenting ? screens.from : screens.to 
        var last = !self.presenting ? screens.to : screens.from
        
        if next is DialogController || next is UserAddController || next is UserSwitchController || next is UserSelectController {
            next.modalPresentationStyle = .overCurrentContext
        }
        
        // add the both views to our view controller
        if next.modalPresentationStyle == .overCurrentContext && last.modalPresentationStyle != .overCurrentContext {
            container.addSubview(last.view)
            container.addSubview(next.view)
            if self.presenting {
                if !UIAccessibilityIsReduceTransparencyEnabled() {
                    if let vis = next.view.subviews.filter({$0 is UIVisualEffectView}).first {
                        vis.alpha = 0
                    }
                }
                else {
                    next.view.backgroundColor = UIColor.black.withAlphaComponent(0)
                }
            }
            else {
                if !UIAccessibilityIsReduceTransparencyEnabled() {
                    if let vis = next.view.subviews.filter({$0 is UIVisualEffectView}).first {
                        vis.alpha = 1
                    }
                }
                else {
                    next.view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
                }
            }
        }
        else {
            container.addSubview(next.view)
            container.addSubview(last.view)
        }
        last.view.transform = CGAffineTransform(translationX: 0, y: 0)
        next.view.transform = CGAffineTransform(translationX: 0, y: 0)
        next.view.bounds = UIScreen.main.bounds
        last.view.bounds = UIScreen.main.bounds
        next.view.frame = CGRect(x: 0, y: 0, width: next.view.bounds.width, height: next.view.bounds.height)
        last.view.frame = CGRect(x: 0, y: 0, width: next.view.bounds.width, height: next.view.bounds.height)
        if last.getOrientation() != UIApplication.shared.statusBarOrientation {
            last.orientation = UIApplication.shared.statusBarOrientation
            AppDelegate.rerenderView(last.view)
        }
        if next.getOrientation() != UIApplication.shared.statusBarOrientation {
            next.orientation = UIApplication.shared.statusBarOrientation
            AppDelegate.rerenderView(next.view)
        }

        let origLast = last
        let origColor = origLast.view.backgroundColor
        
        // if both controllers are card controllers translate embeddedView and leave navigation in place
        if last is CardController && next is CardController {
            origLast.view.backgroundColor = UIColor.clear
            last = (last as! CardController).subview!
            next = (next as! CardController).subview!
        }
        
        //self.setupShadow(container)
        var moveNext = UIScreen.main.bounds.width
        var moveLast = -UIScreen.main.bounds.width
        
        if next.modalPresentationStyle == .overCurrentContext && last.modalPresentationStyle != .overCurrentContext {
            moveLast = 0.0
        }
        
        // if both controllers have nueral dark transition content
        let lastBackground = (last.view ~> (UIVisualEffectView.self ~* {$0.tag == 23})).first
        let nextBackground = (next.view ~> (UIVisualEffectView.self ~* {$0.tag == 23})).first
        nextBackground?.transform = CGAffineTransform(translationX: 0, y: 0)
        lastBackground?.transform = CGAffineTransform(translationX: 0, y: 0)
        if lastBackground != nil && nextBackground != nil {
            if self.presenting {
                nextBackground!.isHidden = false
                lastBackground!.isHidden = true
                nextBackground!.transform = CGAffineTransform(translationX: -moveNext, y: 0)
                lastBackground!.transform = CGAffineTransform(translationX: 0, y: 0)
            }
            else {
                nextBackground!.isHidden = false
                lastBackground!.isHidden = true
                nextBackground!.transform = CGAffineTransform(translationX: 0, y: 0)
                lastBackground!.transform = CGAffineTransform(translationX: -moveLast, y: 0)
            }
        }

        // prepare menu items to slide in
        if self.presenting {
            last.view.transform = CGAffineTransform(translationX: 0, y: 0)
            next.view.transform = CGAffineTransform(translationX: moveNext, y: 0)
        }
        else {
            last.view.transform = CGAffineTransform(translationX: moveLast, y: 0)
            next.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        if let vc = origLast as? CardController , vc.intermediateResponse != nil && (vc.subview as? CardResponseController == nil || (vc.subview as? CardSelfController)?.correctButton != nil) {
            next.view.transform = CGAffineTransform(translationX: 0, y: 0)
            last.view.transform = CGAffineTransform(translationX: moveLast, y: 0)
            moveNext = 0.0
            self.setupCorrectFlash(vc.intermediateResponse!, container: container)
        }
        
        // move titles around
        let lastTitle = (last.view ~> (UILabel.self ~* {$0.tag == 25})).first
        let lastButton = (last.view ~> (UIView.self ~* {$0.tag == 26}))
        let nextTitle = (next.view ~> (UILabel.self ~* {$0.tag == 25})).first
        let nextButton = (next.view ~> (UIView.self ~* {$0.tag == 26}))

        var alwaysHidden = false
        if nextTitle?.isHidden == true {
            alwaysHidden = true
        }
        
        lastButton.each {$0.transform = CGAffineTransform(translationX: 0, y: 0)}
        nextButton.each {$0.transform = CGAffineTransform(translationX: 0, y: 0)}

        if self.presenting {
            if lastButton.count > 0 && nextButton.count > 0 {
                lastButton.each {$0.transform = CGAffineTransform(translationX: 0, y: 0)}
                nextButton.each {$0.transform = CGAffineTransform(translationX: -moveNext, y: 0)}
            }
            if lastTitle != nil && nextTitle != nil {
                lastTitle!.transform = CGAffineTransform(translationX: 0, y: 0)
                lastTitle!.alpha = 1
            }
        }
        else {
            if lastButton.count > 0 && nextButton.count > 0 {
                lastButton.each {$0.transform = CGAffineTransform(translationX: -moveLast, y: 0)}
                nextButton.each {$0.transform = CGAffineTransform(translationX: 0, y: 0)}
            }
            if lastTitle != nil && nextTitle != nil {
                lastTitle!.transform = CGAffineTransform(translationX: -moveLast, y: 0)
                lastTitle!.alpha = 0
            }
        }
        
        let duration = self.transitionDuration(using: transitionContext)
        last.view.isHidden = false
        next.view.isHidden = false
        
        // perform the animation!
        UIView.animate(withDuration: duration, delay: 0.0, options: [], animations: {
            if self.flashView != nil {
                self.flashView!.alpha = 0
            }
            else {
                if self.presenting {
                    next.view.transform = CGAffineTransform.identity
                    last.view.transform = CGAffineTransform(translationX: moveLast, y: 0)
                    if next.modalPresentationStyle == .overCurrentContext && last.modalPresentationStyle != .overCurrentContext {
                        if !UIAccessibilityIsReduceTransparencyEnabled() {
                            if let vis = next.view.subviews.filter({$0 is UIVisualEffectView}).first {
                                vis.alpha = 1
                            }
                        }
                        else {
                            next.view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
                        }
                    }
                    if lastBackground != nil && nextBackground != nil {
                        nextBackground!.transform = CGAffineTransform(translationX: 0, y: 0)
                        lastBackground!.transform = CGAffineTransform(translationX: moveLast, y: 0)
                    }
                    if lastButton.count > 0 && nextButton.count > 0 {
                        lastButton.each {$0.transform = CGAffineTransform(translationX: -moveLast, y: 0)}
                        nextButton.each {$0.transform = CGAffineTransform(translationX: 0, y: 0)}
                    }
                    if lastTitle != nil && nextTitle != nil {
                        lastTitle!.transform = CGAffineTransform(translationX: -moveLast, y: 0)
                        lastTitle!.alpha = 0
                    }
                }
                else {
                    last.view.transform = CGAffineTransform(translationX: 0, y: 0)
                    next.view.transform = CGAffineTransform(translationX: moveNext, y: 0)
                    if next.modalPresentationStyle == .overCurrentContext && last.modalPresentationStyle != .overCurrentContext {
                        if !UIAccessibilityIsReduceTransparencyEnabled() {
                            if let vis = next.view.subviews.filter({$0 is UIVisualEffectView}).first {
                                vis.alpha = 0
                            }
                        }
                        else {
                            next.view.backgroundColor = UIColor.black.withAlphaComponent(0)
                        }
                    }
                    if lastBackground != nil && nextBackground != nil {
                        nextBackground!.transform = CGAffineTransform(translationX: moveLast, y: 0)
                        lastBackground!.transform = CGAffineTransform(translationX: 0, y: 0)
                    }
                    if lastButton.count > 0 && nextButton.count > 0 {
                        lastButton.each {$0.transform = CGAffineTransform(translationX: 0, y: 0)}
                        nextButton.each {$0.transform = CGAffineTransform(translationX: -moveNext, y: 0)}
                    }
                    if lastTitle != nil && nextTitle != nil {
                        lastTitle!.transform = CGAffineTransform(translationX: 0, y: 0)
                        lastTitle!.alpha = 1
                    }
                }
            }
            
            }, completion: { finished in
                self.flashView = nil
                next.view.transform = CGAffineTransform.identity
                last.view.transform = CGAffineTransform.identity
                origLast.view.backgroundColor = origColor
                if !alwaysHidden && nextTitle != nil {
                    nextTitle!.isHidden = false
                }
                if lastBackground != nil && nextBackground != nil {
                    if self.presenting {
                        nextBackground!.isHidden = false
                    }
                    else {
                        lastBackground!.isHidden = false
                    }
                }
                AppDelegate.instance().window!.rootViewController!.view.layer.mask = nil
                // tell our transitionContext object that we've finished animating
                if(transitionContext.transitionWasCancelled){
                    
                    transitionContext.completeTransition(false)
                    if self.presenting {
                        if last.modalPresentationStyle != .overCurrentContext {
                            next.view.isHidden = true
                        }
                    }
                    else {
                        if next.modalPresentationStyle != .overCurrentContext {
                            last.view.isHidden = true
                        }
                    }
                    // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                    UIApplication.shared.keyWindow!.addSubview(screens.from.view)
                    
                }
                else {
                    
                    transitionContext.completeTransition(true)
                    if self.presenting {
                        if next.modalPresentationStyle != .overCurrentContext {
                            last.view.isHidden = true
                        }
                    }
                    else {
                        if last.modalPresentationStyle != .overCurrentContext {
                            next.view.isHidden = true
                        }
                    }
                    // bug: we have to manually add our 'to view' back http://openradar.appspot.com/radar?id=5320103646199808
                    UIApplication.shared.keyWindow!.addSubview(screens.to.view)
                    
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
    
    func setupCorrectFlash(_ correct: Bool, container: UIView) {
        self.flashView = UITextView()
        container.addSubview(self.flashView!)
        self.flashView!.alpha = 1.0
        self.flashView!.textColor = UIColor.white
        self.flashView!.textAlignment = NSTextAlignment.center
        self.flashView!.font = UIFont.systemFont(ofSize: 250.0)
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
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // return the animataor when presenting a viewcontroller
    // rememeber that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = !self.reversed
        return self
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = self.reversed
        return self
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return self.interactive ? self : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
}

