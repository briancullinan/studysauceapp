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

extension UIViewController {
        
    func showDialog(message: String?, button: String?) {
        self.showDialog(message, button: button, done: {
            return true
        })
    }
    
    func goHome(refetch: Bool = false) {
        if !refetch && AppDelegate.getUser() != nil {
            let home = self.storyboard!.instantiateViewControllerWithIdentifier("Home")
            self.transitioningDelegate = CardSegue.transitionManager
            home.transitioningDelegate = CardSegue.transitionManager
            dispatch_async(dispatch_get_main_queue(),{
                self.presentViewController(home, animated: true, completion: {})
            })
        }
        else {
            UserLoginController.login({
                let home = self.storyboard!.instantiateViewControllerWithIdentifier(AppDelegate.getUser() == nil ? "Landing" : "Home")
                self.transitioningDelegate = CardSegue.transitionManager
                home.transitioningDelegate = CardSegue.transitionManager
                dispatch_async(dispatch_get_main_queue(),{
                    self.presentViewController(home, animated: true, completion: {})
                })
            })
        }
    }
        
    func showDialog(message: String?, button: String?, done: () -> Bool) -> DialogController {
        let dialog = self.storyboard!.instantiateViewControllerWithIdentifier("Dialog") as! DialogController
        dialog.message = message
        dialog.button = button
        dialog.click = done
        dialog.modalPresentationStyle = .OverCurrentContext
        self.transitioningDelegate = CardSegue.transitionManager
        dialog.transitioningDelegate = CardSegue.transitionManager
        dispatch_async(dispatch_get_main_queue(),{
            self.presentViewController(dialog, animated: true, completion: {})
        })
        return dialog
    }
    
    func showNoConnectionDialog(done: () -> Void) {
        if AppDelegate.isConnectedToNetwork() {
            done()
        }
        else {
            var timer: NSTimer? = nil
            let dialog = self.showDialog(NSLocalizedString("No internet connection", comment: "Message when internet connection is needed but not available"), button: NSLocalizedString("Try again", comment: "Dismiss no internet connection and try again"), done: {
                let result = AppDelegate.isConnectedToNetwork()
                if result {
                    timer?.invalidate()
                    done()
                }
                return result
            })
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: dialog, selector: Selector("done"), userInfo: nil, repeats: true)
        }
    }
}