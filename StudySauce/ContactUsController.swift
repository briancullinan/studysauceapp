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

class ContactUsController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.message.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.5).CGColor
        self.message.layer.borderWidth = 0.5
        self.message.layer.cornerRadius = 5
        self.message.clipsToBounds = true
    }
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var message: UITextView!
    
    @IBAction func sendEmail(sender: AnyObject) {
    }
    @IBAction func DismissKeyboard(sender: AnyObject) {
    }
    
   
}