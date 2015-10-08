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
        self.message.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        self.message.layer.borderWidth = 1.0
        self.message.layer.cornerRadius = 5
    }
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var message: UITextView!
    
    @IBAction func sendEmail(sender: AnyObject) {
    }
    @IBAction func DismissKeyboard(sender: AnyObject) {
    }
    
   
}