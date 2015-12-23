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
        
        self.viewDidLoad()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getUsersFromLocalStore({
            self.tableView.reloadData()
        })
    }
    
    @IBAction func returnToSwitch(segue: UIStoryboardSegue) {
        self.viewDidAppear(true)
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
        if self.users != nil && self.users!.count > 0 && i >= 0 && i < self.users!.count {
            AppDelegate.instance().user = self.users![i]
            self.dismissViewControllerAnimated(true, completion: {
                //self.presentingViewController?.viewDidAppear(true)
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
        self.dismissViewControllerAnimated(true, completion: {
            dispatch_async(dispatch_get_main_queue(), {
                UserLoginController.logout({
                    AppDelegate.instance().user = nil
                    self.performSegueWithIdentifier("home", sender: self)
                })
            })
        })
    }
    
    func addChild() {
        self.performSegueWithIdentifier("addChild", sender: self)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        if self.users == nil {
            cell = tableView.dequeueReusableCellWithIdentifier("loading", forIndexPath: indexPath)
        }
        else if self.users!.count == 0 || indexPath.row == self.users!.count + 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("empty", forIndexPath: indexPath)
            (cell ~> UIButton.self).first?.addTarget(self, action: "addChild", forControlEvents: UIControlEvents.TouchUpInside)
        }
        else if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("logout", forIndexPath: indexPath)
            (cell ~> UIButton.self).first?.addTarget(self, action: "logout", forControlEvents: UIControlEvents.TouchUpInside)
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            let i = indexPath.row - 1
            (cell ~> (UILabel.self ~* T.nthOfType(1))).first!.text = self.users![i].first
            (cell ~> (UILabel.self ~* T.nthOfType(0))).first!.text = self.users![i].last
            (cell ~> (UILabel.self ~* {$0.text == "✔︎"})).first!.hidden = self.users![i] != AppDelegate.getUser()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80 * saucyTheme.multiplier()
    }
    
}