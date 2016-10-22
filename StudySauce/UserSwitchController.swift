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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getUsersFromLocalStore({
            self.tableView.reloadData()
            let rows = self.tableView.numberOfRows(inSection: 0)
            self.preferredContentSize = CGSize(width: 200 * saucyTheme.multiplier(), height: CGFloat(rows) * (saucyTheme.textSize * saucyTheme.lineHeight + saucyTheme.padding))
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // call this extra because over current context doesn't fire it when it switches back
        if self.selected != true {
            self.home?.viewDidAppear(animated)
            self.home?.childViewControllers.filter({$0 is HomeController}).each{$0.viewDidAppear(animated)}
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.home = self.presentingViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.popoverPresentationController?.backgroundColor = saucyTheme.lightColor
        self.preferredContentSize = CGSize(width: 200 * saucyTheme.multiplier(), height: 3.0 * (saucyTheme.textSize * saucyTheme.lineHeight + saucyTheme.padding))
    }
    
    func getUsersFromLocalStore(_ done: @escaping () -> Void = {}) {
        AppDelegate.performContext({
            self.users = UserLoginController.filterDomain(AppDelegate.list(User.self))
            doMain { done() }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selected = true
        let i = (indexPath as NSIndexPath).row
        
        if (indexPath as NSIndexPath).row == self.users!.count {
            return
        }
        if self.users != nil && self.users!.count > 0 && i < self.users!.count {
            AppDelegate.instance().user = self.users![i]
            AppDelegate.goHome(nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.users == nil || self.users!.count == 0 {
            return 1
        }
        return self.users!.count + 1
    }
    
    @IBAction func logout(_ sender: UIButton) {
        UserLoginController.logout({
            AppDelegate.goHome(nil, true)
        })
    }
    
    @IBAction func addChild(_ sender: UIButton) {
        let home = self.presentingViewController!
        self.dismiss(animated: true, completion: {
            home.performSegue(withIdentifier: "addChild", sender: self)
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        if self.users == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
        }
        else if self.users!.count == 0 || (indexPath as NSIndexPath).row == self.users!.count {
            cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
        }
        else {
            let i = (indexPath as NSIndexPath).row
            if self.users![i].hasRole("ROLE_PARENT") {
                cell = tableView.dequeueReusableCell(withIdentifier: "Parent", for: indexPath)
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            }
            (cell ~> (UILabel.self ~* {$0.text != "✔︎"})).first!.text = "\(self.users![i].first!) \(self.users![i].last!)"
            (cell ~> (UILabel.self ~* {$0.text == "✔︎"})).first!.isHidden = self.users![i] != AppDelegate.getUser()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return saucyTheme.textSize * saucyTheme.lineHeight + saucyTheme.padding
    }
    
}
