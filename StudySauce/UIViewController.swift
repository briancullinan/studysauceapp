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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


private struct AssociatedKeys {
    static var orientation = "UIView_Orientation"
}

extension UIViewController {
    
    func getAnalytics() -> String {
        let name: String
        if self.restorationIdentifier != nil {
            name = self.restorationIdentifier!
        }
        else {
            name = String(describing: self.self)
        }
        return name
    }
    
    func resignAllResponders() {
        (self.view ~> UITextField.self).each { $0.resignFirstResponder() }
        self.view.endEditing(true)
    }
    
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

    func canPerformSegueWithIdentifier(_ identifier: NSString) -> Bool {
        let templates = self.value(forKey: "storyboardSegueTemplates") as? NSArray
        let predicate:NSPredicate = NSPredicate(format: "identifier=%@", identifier)
        
        let filteredtemplates = templates?.filtered(using: predicate)
        return (filteredtemplates?.count>0)
    }
    
    
        
    func showDialog(_ message: String?, _ button: String?, click: (() -> Bool)? = nil, _ done: (() -> Void)? = nil) -> DialogController {
        let dialog = self.storyboard!.instantiateViewController(withIdentifier: "Dialog") as! DialogController
        dialog.message = message
        dialog.button = button
        if click != nil {
            dialog.click = click!
        }
        if done != nil {
            dialog.done = done!
        }
        dialog.modalPresentationStyle = .overCurrentContext
        self.transitioningDelegate = CardSegue.transitionManager
        dialog.transitioningDelegate = CardSegue.transitionManager
        doMain {
            self.present(dialog, animated: true, completion: nil)
        }
        return dialog
    }
    
    func showNoConnectionDialog(_ done: @escaping () -> Void) {
        if AppDelegate.isConnectedToNetwork() {
            done()
        }
        else {
            var timer: Timer? = nil
            let dialog = self.showDialog(NSLocalizedString("No internet connection", comment: "Message when internet connection is needed but not available"), NSLocalizedString("Try again", comment: "Dismiss no internet connection and try again"), click: {
                let result = AppDelegate.isConnectedToNetwork()
                if result {
                    timer?.invalidate()
                }
                return result
            }, done)
            timer = Timer.scheduledTimer(timeInterval: 1, target: dialog, selector: #selector(getter: DialogController.done), userInfo: nil, repeats: true)
        }
    }
}
