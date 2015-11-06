//
//  ContactUsController.swift
//  StudySauce
//
//  Created by Stephen Houghton on 10/7/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//


import Foundation
import CoreData
import UIKit
import MessageUI
import QuartzCore

class ContactUsController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.message.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        self.message.layer.borderWidth = 0.5
        self.message.layer.cornerRadius = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var message: UITextView!
    
    @IBAction func sendEmail(sender: AnyObject) {
        self.name.resignFirstResponder()
        self.email.resignFirstResponder()
        self.message.resignFirstResponder()
        if self.email.text == nil || self.email.text == "" || self.name.text == nil || self.name.text == "" || self.message.text == nil || self.message.text == "" {
            return
        }
        self.showNoConnectionDialog({
            self.postJson("/contact/send", params: [
                "name": self.name.text,
                "email": self.email.text,
                "message": self.message.text
                ], done: {(json) in
                    self.showDialog(NSLocalizedString("Thank you!  Someone will be in touch shortly", comment: "Message after user submits a contact us message"), button: NSLocalizedString("Done", comment: "Button to dismiss the contact us process after submit"), done: {
                        dispatch_async(dispatch_get_main_queue(),{
                            self.performSegueWithIdentifier("dismiss", sender: self)
                            })
                        return true
                    })
            })
        })
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}