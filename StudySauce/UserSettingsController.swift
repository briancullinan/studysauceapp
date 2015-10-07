//
//  UserSettingsController.swift
//  StudySauce
//
//  Created by Stephen Houghton on 10/5/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class UserSettingsController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.backgroundView = nil
        
        
        self.firstName.text = AppDelegate.getUser()!.first
        self.lastName.text = AppDelegate.getUser()!.last
        self.userEmail.text = AppDelegate.getUser()!.email
        //self.childFirstName.text = AppDelegate.getUser().childFirst
        //self.childLastName.text = AppDelegate.getUser().childLast
    
    
    }
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var childFirstName: UITextField!
    @IBOutlet weak var childLastName: UITextField!
}