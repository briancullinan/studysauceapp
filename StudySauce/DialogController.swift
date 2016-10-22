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
    
    @IBAction func backgroundClick(_ sender: UIButton) {
        if click() {
            self.dismiss(animated: true, completion: {
                
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        primaryButton.setTitle(self.button, for: UIControlState())
        messageLabel.text = self.message
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        if click() {
            self.dismiss(animated: true, completion: {
                doMain {
                    self.done()
                }
            })
        }
    }
}
