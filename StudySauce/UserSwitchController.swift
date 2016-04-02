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
    weak var home: UIViewController? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getUsersFromLocalStore({
            self.tableView.reloadData()
            let rows = self.tableView.numberOfRowsInSection(0)
            self.preferredContentSize = CGSizeMake(200 * saucyTheme.multiplier(), CGFloat(rows) * (saucyTheme.textSize * saucyTheme.lineHeight + saucyTheme.padding))
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // call this extra because over current context doesn't fire it when it switches back
        if self.selected != true {
            self.home?.viewDidAppear(animated)
            self.home?.childViewControllers.filter({$0 is HomeController}).each{$0.viewDidAppear(animated)}
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.home = self.presentingViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.popoverPresentationController?.backgroundColor = saucyTheme.lightColor
        self.preferredContentSize = CGSizeMake(200 * saucyTheme.multiplier(), 3.0 * (saucyTheme.textSize * saucyTheme.lineHeight + saucyTheme.padding))
    }
    
    func getUsersFromLocalStore(done: () -> Void = {}) {
        AppDelegate.performContext({
            self.users = AppDelegate.list(User.self)
                .filter{
                    return ($0.getProperty("session") as? [[String : AnyObject]] ?? [[String : AnyObject]]()).filter{
                        return "\($0["Domain"]!)" == AppDelegate.domain}.count > 0}
            doMain(done)
        })
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selected = true
        let i = indexPath.row
        
        if indexPath.row == self.users!.count {
            return
        }
        if self.users != nil && self.users!.count > 0 && i < self.users!.count {
            AppDelegate.instance().user = self.users![i]
            AppDelegate.goHome(nil)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.users == nil || self.users!.count == 0 {
            return 1
        }
        return self.users!.count + 1
    }
    
    @IBAction func logout(sender: UIButton) {
        UserLoginController.logout({
            AppDelegate.goHome(nil, true)
        })
    }
    
    @IBAction func addChild(sender: UIButton) {
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
        else if self.users!.count == 0 || indexPath.row == self.users!.count {
            cell = tableView.dequeueReusableCellWithIdentifier("empty", forIndexPath: indexPath)
        }
        else {
            let i = indexPath.row
            if self.users![i].hasRole("ROLE_PARENT") {
                cell = tableView.dequeueReusableCellWithIdentifier("Parent", forIndexPath: indexPath)
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            }
            (cell ~> (UILabel.self ~* {$0.text != "✔︎"})).first!.text = "\(self.users![i].first!) \(self.users![i].last!)"
            (cell ~> (UILabel.self ~* {$0.text == "✔︎"})).first!.hidden = self.users![i] != AppDelegate.getUser()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return saucyTheme.textSize * saucyTheme.lineHeight + saucyTheme.padding
    }
    
}