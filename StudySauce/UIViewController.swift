 //
//  UIViewController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit
import CoreData

private struct AssociatedKeys {
    static var orientation = "UIView_Orientation"
}

extension UIViewController {
    
    var orientation: UIInterfaceOrientation? {
        get {
            let result = objc_getAssociatedObject(self, &AssociatedKeys.orientation) as? Int
            if result == nil {
                return nil
            }
            return UIInterfaceOrientation.init(rawValue: result!)
        }
        set(value) {
            let intval = value!.rawValue
            objc_setAssociatedObject(self,&AssociatedKeys.orientation,intval,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func getOrientation() -> UIInterfaceOrientation? {
        return self.orientation
    }

    func canPerformSegueWithIdentifier(identifier: NSString) -> Bool {
        let templates = self.valueForKey("storyboardSegueTemplates") as? NSArray
        let predicate:NSPredicate = NSPredicate(format: "identifier=%@", identifier)
        
        let filteredtemplates = templates?.filteredArrayUsingPredicate(predicate)
        return (filteredtemplates?.count>0)
    }
    
    
        
    func showDialog(message: String?, button: String?, click: (() -> Bool)? = nil, done: (() -> Void)? = nil) -> DialogController {
        let dialog = self.storyboard!.instantiateViewControllerWithIdentifier("Dialog") as! DialogController
        dialog.message = message
        dialog.button = button
        if click != nil {
            dialog.click = click!
        }
        if done != nil {
            dialog.done = done!
        }
        dialog.modalPresentationStyle = .OverCurrentContext
        self.transitioningDelegate = CardSegue.transitionManager
        dialog.transitioningDelegate = CardSegue.transitionManager
        dispatch_async(dispatch_get_main_queue(),{
            self.presentViewController(dialog, animated: true, completion: nil)
        })
        return dialog
    }
    
    func showNoConnectionDialog(done: () -> Void) {
        if AppDelegate.isConnectedToNetwork() {
            done()
        }
        else {
            var timer: NSTimer? = nil
            let dialog = self.showDialog(NSLocalizedString("No internet connection", comment: "Message when internet connection is needed but not available"), button: NSLocalizedString("Try again", comment: "Dismiss no internet connection and try again"), click: {
                let result = AppDelegate.isConnectedToNetwork()
                if result {
                    timer?.invalidate()
                }
                return result
            }, done: done)
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: dialog, selector: Selector("done"), userInfo: nil, repeats: true)
        }
    }
}