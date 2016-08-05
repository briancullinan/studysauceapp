//
//  StoreController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 8/4/16.
//  Copyright © 2016 The Study Institute. All rights reserved.
//

import Foundation
//
//  MasterViewController.swift
//  StudySauce
//
//  Created by admin on 9/12/15.
//  Copyright (c) 2015 The Study Institute. All rights reserved.
//

import UIKit
import CoreData

class StoreController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var coupons: NSArray? = nil
    var pack: Pack? = nil
    @IBOutlet weak var tableView: UITableView!
    var couponsLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCouponsFromLocalStore()
    }
    
    func getCouponsFromLocalStore() {
        let user = AppDelegate.getUser()!
        getJson("/command/results", [
            "count-file" : -1,
            "count-pack" : -1,
            "count-coupon" : 0,
            "count-card" : -1,
            "count-ss_group" : -1,
            "count-ss_user" : 1,
            "count-user_pack" : -1,
            "read-only" : false,
            "tables" : [
                "file" : ["id", "url"],
                "coupon" : ["idTilesSummary" : ["id", "name", "description", "packs", "options", "cardCount"]],
                "ss_group" : ["id", "name", "users", "deleted"],
                "ss_user" : ["id" : ["id", "first", "last", "userPacks"]],
                "user_pack" : ["pack", "removed", "downloaded"],
                "pack" : ["idTilesSummary" : ["created", "id", "title", "logo"], "actions" : ["status"]]
            ],
            "classes" : ["tiles", "summary"],
            "headers" : ["coupon" : "store"],
            "footers" : user.hasRole("ROLE_ADMIN") ? ["coupon" : true] : false
        ]) {json in
            self.coupons = (json["results"] as? NSDictionary)?["coupon"] as? NSArray
            doMain {
                self.couponsLoaded = true
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return saucyTheme.textSize * saucyTheme.lineHeight * 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.coupons == nil || self.coupons!.count == 0 {
            return 1
        }
        return self.coupons!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.couponsLoaded && self.coupons?.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("NoCoupons")!
        }
        else if self.coupons == nil || self.coupons!.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("Loading")!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CouponCell
        
        let object = self.coupons![indexPath.row] as! NSDictionary
        cell.configure(object)
        return cell
    }
}