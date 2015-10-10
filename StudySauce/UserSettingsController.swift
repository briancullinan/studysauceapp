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
        
        
        self.firstName.text = AppDelegate.getUser()?.first
        self.lastName.text = AppDelegate.getUser()?.last
        self.userEmail.text = AppDelegate.getUser()?.email
        //self.childFirstName.text = AppDelegate.getUser().childFirst
        //self.childLastName.text = AppDelegate.getUser().childLast
    
    
    }
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var childFirstName: UITextField!
    @IBOutlet weak var childLastName: UITextField!
    @IBOutlet weak var privacyCell: UITableViewCell!
    @IBOutlet weak var supportCell: UITableViewCell!
    
    internal func edit() -> Void {
        self.firstName.enabled = true
        self.lastName.enabled = true
        self.userEmail.enabled = true
        self.childFirstName.enabled = true
        self.childLastName.enabled = true
        self.privacyCell.hidden = true
        self.supportCell.hidden = true
        self.tableView.allowsSelection = false
        self.tableView.reloadData()
    }
    
    internal func save() -> Void {
        self.firstName.enabled = false
        self.lastName.enabled = false
        self.userEmail.enabled = false
        self.childFirstName.enabled = false
        self.childLastName.enabled = false
        self.privacyCell.hidden = false
        self.supportCell.hidden = false
        self.tableView.allowsSelection = true
        self.tableView.reloadData()
        if AppDelegate.isConnectedToNetwork() {
        }
        else {
            self.performSegueWithIdentifier("error503", sender: self)
        }
    }
    
    var cacheResetTime: NSDate? = nil
    var cacheResetCount: Int = 0
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 && indexPath.section == 0 {
            let twentyMinutesAgo = NSDate().dateByAddingTimeInterval(-20)
            if cacheResetTime == nil || cacheResetTime!.isLessThanDate(twentyMinutesAgo) {
                cacheResetTime = NSDate()
                cacheResetCount = 0
            }
            cacheResetCount++
            if cacheResetCount == 10 {
                let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
                for c in storage.cookies! {
                    storage.deleteCookie(c)
                }
                NSUserDefaults.standardUserDefaults()
                AppDelegate.managedObjectContext = nil
                AppDelegate.resetLocalStore()
                (UIApplication.sharedApplication().delegate as! AppDelegate).user = nil
                self.goHome(true)
            }
        }
        //return super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.privacyCell.hidden {
            if indexPath.section >= 2 {
                return 0
            }
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.privacyCell.hidden {
            if section >= 2 {
                return Optional(nil)!
            }
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        //if indexPath.section < 3 {
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        //}
        if self.privacyCell.hidden {
            if indexPath.section >= 2 {
                cell.hidden = true
            }
        }
        return cell
    }
}