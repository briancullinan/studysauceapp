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
    
    @IBAction func addAccount(sender: UIButton) {
        self.performSegueWithIdentifier("login", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getUsersFromLocalStore({
            self.tableView.reloadData()
        })
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
        if self.users != nil && self.users!.count > 0 {
            AppDelegate.instance().user = self.users![indexPath.row]
            if var cookie = AppDelegate.instance().user?.getProperty("session") as? [String : AnyObject] {
                cookie["Expires"] = NSDate.parse(cookie["Expires"] as? String)
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(NSHTTPCookie(properties: cookie)!)
            }
            self.performSegueWithIdentifier("last", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.users == nil || self.users!.count == 0 {
            return 1
        }
        return self.users!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        if self.users == nil {
            cell = tableView.dequeueReusableCellWithIdentifier("loading", forIndexPath: indexPath)
        }
        else if self.users!.count == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("empty", forIndexPath: indexPath)
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            (cell ~> (UILabel.self ~* T.nthOfType(1))).first!.text = self.users![indexPath.row].first
            (cell ~> (UILabel.self ~* T.nthOfType(0))).first!.text = self.users![indexPath.row].last
            (cell ~> (UILabel.self ~* {$0.text == "✔︎"})).first!.hidden = self.users![indexPath.row] != AppDelegate.getUser()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80 * saucyTheme.multiplier()
    }
    
}