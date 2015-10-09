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
        
        let radius = self.email.layer.cornerRadius
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
        self.showNoConnectionDialog({
            self.postJson("/contact/send", params: [
                "name": self.name.text,
                "email": self.email.text,
                "message": self.message.text
                ], done: {(json) in
                    self.showDialog("Thank you!  Someone will be in touch shortly", button: "Done", done: {
                        dispatch_async(dispatch_get_main_queue(),{
                            self.performSegueWithIdentifier("dismiss", sender: self)
                            })
                        return true
                    })
            })
        })
    }
   
}