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

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var message: UITextField!
    
    @IBAction func sendEmail(sender: AnyObject) {
    }
    @IBAction func DismissKeyboard(sender: AnyObject) {
    }
    
}