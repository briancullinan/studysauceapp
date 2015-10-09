//
//  UserSettingsContainerController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 10/7/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class UserSettingsContainerController: UIViewController {
    //  We'll keep a reference to the embedded view controller
    //  so we can call `myMethod` later.
    //
    //  It's declared to be an implicitly unwrapped optional
    //  because it doesn't make sense to give it a non-nil initial value.
    private var embeddedViewController: UserSettingsController!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? UserSettingsController {
            self.embeddedViewController = vc
        }
    }
    
    //  Now in other methods you can reference `embeddedViewController`.
    //  For example:
    override func viewDidAppear(animated: Bool) {
        
    }
    
    @IBAction func saveClick(sender: UIButton) {
        self.editButton.hidden = false
        self.saveButton.hidden = true
        self.embeddedViewController.save()
    }
    
    @IBAction func editClick(sender: UIButton) {
        self.editButton.hidden = true
        self.saveButton.hidden = false
        self.embeddedViewController.edit()
    }
}