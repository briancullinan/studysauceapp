//
//  DialogController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 10/8/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class DialogController: UIViewController {
    
    var button: String! = ""
    var message: String! = ""
    var click: () -> Bool = {
        return true
    }
    var done: () -> Void = { return }
        
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var backgroundButton: UIButton!
    
    @IBAction func backgroundClick(sender: UIButton) {
        if click() {
            self.dismissViewControllerAnimated(true, completion: {
                
            })
        }
    }
    
    override func viewDidLoad() {
        primaryButton.setTitle(self.button, forState: .Normal)
        messageLabel.text = self.message
    }
    
    @IBAction func buttonClick(sender: UIButton) {
        if click() {
            self.dismissViewControllerAnimated(true, completion: {
                dispatch_async(dispatch_get_main_queue(),{
                    self.done()
                })
            })
        }
    }
}