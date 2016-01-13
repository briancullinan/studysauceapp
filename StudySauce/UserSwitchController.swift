//
//  UserSwitchController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 12/18/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

class UserSwitchController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var users: [User]? = nil
    var selected = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getUsersFromLocalStore({
            self.tableView.reloadData()
            let rows = self.tableView.numberOfRowsInSection(0)
            self.preferredContentSize = CGSizeMake(200 * saucyTheme.multiplier(), CGFloat(rows) * (saucyTheme.textSize * saucyTheme.lineHeight + saucyTheme.padding))
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        // call this extra because over current context doesn't fire it when it switches back
        if self.selected != true {
            self.presentingViewController?.viewDidAppear(animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.popoverPresentationController?.backgroundColor = saucyTheme.lightColor
        self.preferredContentSize = CGSizeMake(200 * saucyTheme.multiplier(), 3.0 * (saucyTheme.textSize * saucyTheme.lineHeight + saucyTheme.padding))
    }
    
    func getUsersFromLocalStore(done: () -> Void = {}) {
        AppDelegate.performContext({
            self.users = AppDelegate.list(User.self)
            doMain(done)
        })
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selected = true
        let i = indexPath.row - 1
        
        if indexPath.row == 0 {
            self.logout()
            return
        }
        if indexPath.row == self.users!.count + 1 {
            self.addChild()
            return
        }
        if self.users != nil && self.users!.count > 0 && i >= 0 && i < self.users!.count {
            AppDelegate.instance().user = self.users![i]
            let home = self.presentingViewController! as? HomeController
            self.dismissViewControllerAnimated(true, completion: {
                if self.users![i].getProperty("seen_tutorial") as? Bool != true {
                    AppDelegate.goHome(home)
                }
                else {
                    home?.viewDidAppear(true)
                    if let subHome = home?.childViewControllers.filter({$0 is HomeController}).first as? HomeController {
                        subHome.packs = nil
                        subHome.tableView?.reloadData()
                    }
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.users == nil {
            return 1
        }
        else if self.users!.count == 0 {
            return 2
        }
        return self.users!.count + 2
    }
    
    func logout() {
        let home = self.presentingViewController!
        UserLoginController.logout({
            AppDelegate.instance().user = nil
            self.dismissViewControllerAnimated(true, completion: {
                AppDelegate.goHome(home)
            })
        })
    }
    
    func addChild() {
        let home = self.presentingViewController!
        self.dismissViewControllerAnimated(true, completion: {
            home.performSegueWithIdentifier("addChild", sender: self)
        })        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        if self.users == nil {
            cell = tableView.dequeueReusableCellWithIdentifier("loading", forIndexPath: indexPath)
        }
        else if self.users!.count == 0 || indexPath.row == self.users!.count + 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("empty", forIndexPath: indexPath)
        }
        else if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("logout", forIndexPath: indexPath)
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            let i = indexPath.row - 1
            (cell ~> (UILabel.self ~* {$0.text != "✔︎"})).first!.text = "\(self.users![i].first!) \(self.users![i].last!)"
            (cell ~> (UILabel.self ~* {$0.text == "✔︎"})).first!.hidden = self.users![i] != AppDelegate.getUser()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return saucyTheme.textSize * saucyTheme.lineHeight + saucyTheme.padding
    }
    
}