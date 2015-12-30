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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getUsersFromLocalStore({
            self.tableView.reloadData()
            let size = CGSizeMake(250 * saucyTheme.multiplier(), CGFloat(self.tableView.numberOfRowsInSection(0) * 50) * saucyTheme.multiplier())
            let preferred = self.preferredContentSize.height
            if preferred != size.height {
                self.preferredContentSize = size
            }
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.presentingViewController?.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.popoverPresentationController?.backgroundColor = saucyTheme.lightColor
        self.preferredContentSize = CGSizeMake(250 * saucyTheme.multiplier(), CGFloat(3 * 50) * saucyTheme.multiplier())
    }
    
    func getUsersFromLocalStore(done: () -> Void = {}) {
        AppDelegate.performContext({
            self.users = AppDelegate.list(User.self)
            dispatch_async(dispatch_get_main_queue(), {
                done()
            })
        })
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
            let home = self.presentingViewController!
            self.dismissViewControllerAnimated(true, completion: {
                home.viewDidAppear(true)
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.users == nil || self.users!.count == 0 {
            return 2
        }
        return self.users!.count + 2
    }
    
    func logout() {
        let home = self.presentingViewController!
        UserLoginController.logout({
            AppDelegate.instance().user = nil
            self.dismissViewControllerAnimated(true, completion: {
                home.goHome()
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
        return 50 * saucyTheme.multiplier()
    }
    
}