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
    private var users: [User]? = nil
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        self.firstName.text = AppDelegate.getUser()?.first
        self.lastName.text = AppDelegate.getUser()?.last
        self.userEmail.text = AppDelegate.getUser()?.email
        //self.childFirstName.text = AppDelegate.getUser().childFirst
        //self.childLastName.text = AppDelegate.getUser().childLast
        self.getUsersFromLocalStore {
            self.tableView.reloadData()
            self.childTable.reloadData()
        }
    }
    
    private func getUsersFromLocalStore(done: () -> Void) {
        AppDelegate.performContext {
            let currentCookie = (AppDelegate.getUser()?.getProperty("session") as? [Dictionary<String,AnyObject>])?.filter({$0["Name"] as? String == "PHPSESSID"}).first?["Value"] as? String
            let users = AppDelegate.list(User.self).filter {$0 != AppDelegate.getUser() && (
                $0.getProperty("session") as? [Dictionary<String,AnyObject>])?.filter({$0["Name"] as? String == "PHPSESSID"}).first?["Value"] as? String == currentCookie}
            dispatch_async(dispatch_get_main_queue(), {
                self.users = users
                done()
            })
        }
    }
    
    @IBOutlet weak var childTable: UITableView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var childFirstName: UITextField!
    @IBOutlet weak var childLastName: UITextField!
    @IBOutlet weak var privacyCell: UITableViewCell!
    @IBOutlet weak var supportCell: UITableViewCell!
    private var embeddedViewController: UserSettingsController!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? UserSettingsController {
            self.embeddedViewController = vc
        }
    }
    
    @IBAction func returnToSettings(segue: UIStoryboardSegue) {
        self.viewDidAppear(true)
    }
    
    @IBAction func saveClick(sender: UIButton) {
        self.editButton.hidden = false
        self.saveButton.hidden = true
        self.embeddedViewController.save()
    }
    
    @IBAction func editClick(sender: UIButton) {
        self.editButton.hidden = true
        self.saveButton.hidden = false
        self.embeddedViewController.edit()
    }

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
        if tableView == self.childTable {
            return
        }
        if indexPath.row == 0 && indexPath.section == 0 {
            let twoMinutesAgo = NSDate().dateByAddingTimeInterval(-2)
            if cacheResetTime == nil || cacheResetTime! < twoMinutesAgo {
                cacheResetTime = NSDate()
                cacheResetCount = 0
            }
            cacheResetCount++
            if cacheResetCount > 10 {
                cacheResetCount = 0
                AppDelegate.performContext {
                    UserLoginController.logout({
                        AppDelegate.resetLocalStore(true)
                        AppDelegate.instance().user = nil
                        AppDelegate.goHome(self, true)
                    })
                }
            }
        }
        //return super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if tableView == self.childTable {
            return 0
        }
        return super.tableView(tableView, sectionForSectionIndexTitle: title, atIndex: index)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.childTable {
            if section == 0 {
            if self.users == nil || self.users!.count == 0 {
                return 1
            }
            return self.users!.count * 2 + 1
            }
            return 0
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && self.users != nil && self.users!.count > 0 {
            return (saucyTheme.textSize + saucyTheme.padding * 2) * CGFloat(self.users!.count * 2 + 1)
        }
        if self.privacyCell.hidden {
            if indexPath.section >= 2 {
                return 0
            }
        }
        return (saucyTheme.textSize + saucyTheme.padding * 2)
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
        
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.childTable {
            return 0
        }
        return saucyTheme.subheadingSize * saucyTheme.lineHeight
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.childTable {
            return nil
        }
        if self.privacyCell.hidden {
            if section >= 2 {
                return nil
            }
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 0
    }
    
    func addClick(sender: UIButton) {
        self.performSegueWithIdentifier("switch", sender: self)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if tableView == self.childTable {
            let userIndex = (indexPath.row - indexPath.row % 2) / 2
            if self.users == nil {
                cell = tableView.dequeueReusableCellWithIdentifier("loading", forIndexPath: indexPath)
            }
            else if self.users!.count == 0 || indexPath.row == self.users!.count * 2 {
                cell = tableView.dequeueReusableCellWithIdentifier("empty", forIndexPath: indexPath)
                if let add = (cell ~> (UIButton.self ~* {$0.tag == 1})).first {
                    add.addTarget(self, action: "addClick:", forControlEvents: UIControlEvents.TouchUpInside)
                }
            }
            else if indexPath.row % 2 == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("childFirst", forIndexPath: indexPath)
                if let name = (cell ~> (UITextField.self ~* {$0.tag == 1})).first {
                    name.text = self.users![userIndex].first
                }
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier("childLast", forIndexPath: indexPath)
                if let name = (cell ~> (UITextField.self ~* {$0.tag == 1})).first {
                    name.text = self.users![userIndex].last
                }
            }
        }
        else {
            cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        if self.privacyCell.hidden {
            if indexPath.section >= 2 {
                cell.hidden = true
            }
        }
        return cell
    }
}