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

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var primaryButton: UIButton!
    var button: String! = ""
    var message: String! = ""
    var click: () -> Bool = {
        return true
    }
    
    override func viewDidLoad() {
        primaryButton.setTitle(self.button, forState: .Normal)
        messageLabel.text = self.message
    }
    
    internal func done() {
        if click() {
            self.dismissViewControllerAnimated(true, completion: {
                
            })
        }
    }
    
    @IBAction func buttonClick(sender: UIButton) {
        if click() {
            self.dismissViewControllerAnimated(true, completion: {
                
            })
        }
    }
}