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
    fileprivate var users: [User]? = nil
    fileprivate var isChild = false
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    fileprivate func getUsersFromLocalStore(_ done: @escaping () -> Void) {
        AppDelegate.performContext {
            let currentCookie = (AppDelegate.getUser()?.getProperty("session") as? [Dictionary<String,AnyObject>])?.filter({$0["Name"] as? String == "PHPSESSID"}).first?["Value"] as? String
            let users = AppDelegate.list(User.self).filter {$0 != AppDelegate.getUser() && (
                $0.getProperty("session") as? [Dictionary<String,AnyObject>])?.filter({$0["Name"] as? String == "PHPSESSID"}).first?["Value"] as? String == currentCookie}
            if let _ = users.filter({$0.hasRole("ROLE_PARENT")}).first , !AppDelegate.getUser()!.hasRole("ROLE_PARENT") {
                self.isChild = true
            }
            doMain {
                self.users = users
                done()
            }
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
    fileprivate var embeddedViewController: UserSettingsController!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? UserSettingsController {
            self.embeddedViewController = vc
        }
    }
    
    @IBAction func returnToSettings(_ segue: UIStoryboardSegue) {
        self.viewDidAppear(true)
    }
    
    @IBAction func saveClick(_ sender: UIButton) {
        self.editButton.isHidden = false
        self.saveButton.isHidden = true
        self.embeddedViewController.save()
    }
    
    @IBAction func editClick(_ sender: UIButton) {
        self.editButton.isHidden = true
        self.saveButton.isHidden = false
        self.embeddedViewController.edit()
    }

    internal func edit() -> Void {
        self.firstName.isEnabled = true
        self.lastName.isEnabled = true
        self.userEmail.isEnabled = true
        self.childFirstName.isEnabled = true
        self.childLastName.isEnabled = true
        self.privacyCell.isHidden = true
        self.supportCell.isHidden = true
        self.tableView.allowsSelection = false
        self.tableView.reloadData()
    }
    
    internal func save() -> Void {
        self.firstName.isEnabled = false
        self.lastName.isEnabled = false
        self.userEmail.isEnabled = false
        self.childFirstName.isEnabled = false
        self.childLastName.isEnabled = false
        self.privacyCell.isHidden = false
        self.supportCell.isHidden = false
        self.tableView.allowsSelection = true
        self.tableView.reloadData()
        if AppDelegate.isConnectedToNetwork() {
        }
        else {
            self.performSegue(withIdentifier: "error503", sender: self)
        }
    }
    
    var cacheResetTime: Date? = nil
    var cacheResetCount: Int = 0
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.childTable {
            return
        }
        if (indexPath as NSIndexPath).row == 0 && (indexPath as NSIndexPath).section == 0 {
            let twoMinutesAgo = Date().addingTimeInterval(-2)
            if cacheResetTime == nil || cacheResetTime! < twoMinutesAgo {
                cacheResetTime = Date()
                cacheResetCount = 0
            }
            cacheResetCount += 1
            if cacheResetCount > 10 {
                cacheResetCount = 0
                AppDelegate.performContext {
                    AppDelegate.resetLocalStore()
                    AppDelegate.instance().user = nil
                    UserLoginController.logout({
                        //NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "seen_tutorial")
                        //NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "user")
                        //NSUserDefaults.standardUserDefaults().synchronize()
                        AppDelegate.goHome(self, true)
                    })
                }
            }
        }
        //return super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if tableView == self.childTable {
            return 0
        }
        return super.tableView(tableView, sectionForSectionIndexTitle: title, at: index)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.childTable {
            if section == 0 {
            if self.users == nil || self.users!.count == 0 {
                return 1
            }
            return self.users!.count * 2 + 1
            }
            return 0
        }
        else if self.isChild {
            if section == 1 {
                return 0
            }
            if section == 0 {
                return 2
            }
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 1 && self.users != nil && self.users!.count > 0 {
            return (saucyTheme.textSize + saucyTheme.padding * 2) * CGFloat(self.users!.count * 2 + 1)
        }
        if self.privacyCell.isHidden {
            if (indexPath as NSIndexPath).section >= 2 {
                return 0
            }
        }
        return (saucyTheme.textSize + saucyTheme.padding * 2)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
        
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.childTable {
            return 0.01
        }
        else if self.isChild && section == 1 {
            return 0.01
        }
        return saucyTheme.subheadingSize * saucyTheme.lineHeight
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == self.childTable {
            return nil
        }
        else if self.isChild && section == 1 {
            return nil
        }
        if self.privacyCell.isHidden {
            if section >= 2 {
                return nil
            }
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return 0
    }
    
    func addClick(_ sender: UIButton) {
        self.performSegue(withIdentifier: "switch", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if tableView == self.childTable {
            let userIndex = ((indexPath as NSIndexPath).row - (indexPath as NSIndexPath).row % 2) / 2
            if self.users == nil {
                cell = tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
            }
            else if self.users!.count == 0 || (indexPath as NSIndexPath).row == self.users!.count * 2 {
                cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
                if let add = (cell ~> (UIButton.self ~* {$0.tag == 1})).first {
                    add.addTarget(self, action: #selector(UserSettingsController.addClick(_:)), for: UIControlEvents.touchUpInside)
                }
            }
            else if (indexPath as NSIndexPath).row % 2 == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "childFirst", for: indexPath)
                if let name = (cell ~> (UITextField.self ~* {$0.tag == 1})).first {
                    name.text = self.users![userIndex].first
                }
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "childLast", for: indexPath)
                if let name = (cell ~> (UITextField.self ~* {$0.tag == 1})).first {
                    name.text = self.users![userIndex].last
                }
            }
        }
        else {
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        if self.privacyCell.isHidden {
            if (indexPath as NSIndexPath).section >= 2 {
                cell.isHidden = true
            }
        }
        return cell
    }
}
