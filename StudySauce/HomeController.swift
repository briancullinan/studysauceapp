//
//  HomeController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/4/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

import UIKit
import CoreData

class HomeController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.backgroundView = nil
        
        // Load packs from database
        //self.packs = getPacksFromLocalStore()
        
        // Make the cell self size
        self.tableView.estimatedRowHeight = 66.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.layoutIfNeeded()
        
        // refresh data from server
        //self.getPacks { () -> Void in
        //    dispatch_async(dispatch_get_main_queue(), {
        //        self.packs = self.getPacksFromLocalStore()
        //        self.tableView.reloadData()
        //    })
        //}
    }

}