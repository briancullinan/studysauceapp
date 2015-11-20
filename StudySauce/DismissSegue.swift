//
//  DismissSegue.swift
//  StudySauce
//
//  Created by Brian Cullinan on 10/1/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class DismissSegue : UIStoryboardSegue {
    
    override func perform() {
        self.sourceViewController.transitioningDelegate = CardSegue.transitionManager
        self.destinationViewController.transitioningDelegate = CardSegue.transitionManager
        
        // the first function is to dismiss the source view and ignore the destination if they are the same type
        if self.sourceViewController.presentingViewController!.isTypeOf(self.destinationViewController) || (
            (self.sourceViewController.presentingViewController as? CardController) != nil && (self.sourceViewController.presentingViewController as! CardController).subview!.isTypeOf(self.destinationViewController)) {
            self.sourceViewController.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            // if we are dismissing to a higher view controller, dismiss everything in between and present the last one
            //var views = [UIViewController]()
            var last = self.sourceViewController
            while last.presentingViewController != nil && last.presentingViewController!.isTypeOf(self.destinationViewController) == false {
                //views.append(last.presentingViewController!)
                last = last.presentingViewController!
            }
            // TODO: something when destination view controller isn't found
            if last.presentingViewController != nil && last.presentingViewController!.isTypeOf(self.destinationViewController) {
                last = last.presentingViewController!
                CardSegue.transitionManager.fromView = self.sourceViewController
                last.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                last = self.destinationViewController
                CardSegue.transitionManager.reversed = true
                self.sourceViewController.presentViewController(self.destinationViewController, animated: true, completion: nil)
            }
        }
    }
}