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
    fileprivate var embeddedViewController: UserSettingsController!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UserSettingsController {
            self.embeddedViewController = vc
        }
    }
    
    //  Now in other methods you can reference `embeddedViewController`.
    //  For example:
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func saveClick(_ sender: UIButton) {
        self.editButton.isHidden = false
        self.saveButton.isHidden = true
        self.embeddedViewController.save()
    }
    
    @IBAction func editClick(_ sender: UIButton) {
        self.editButton.isHidden = true
        self.saveButton.isHidden = false
        self.embeddedViewController.edit()
    }
}
