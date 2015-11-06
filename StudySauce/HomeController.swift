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

    // Animate big button to depress for a period of time before releasing and loading the card packs
    var iv:UIImageView!
    @IBOutlet weak var button:UIButton!
    func startAnimatingButton(){
        iv = UIImageView(image: UIImage(named:"bigbutton.png"))
        iv.animationImages = [UIImage(named:"bigbuttonpressed.png")]
        iv.animationDuration = 0.5;
        iv.startAnimating()
        button.addSubview(iv)
    }
    func stopAnimatingButton(){
        iv.stopAnimating()
        iv.removeFromSuperview()
        iv=nil;
        button.setImage(UIImage(named: "bigbutton.png"), forState:UIControlState.Normal)
    }
    @IBAction func onTouchDownOfButton(sender:AnyObject){
        startAnimatingButton()
    }
    @IBAction func onTouchUpInsideOfButton(sender:AnyObject){
        stopAnimatingButton()
    }
    // End the animation code
    
    
    
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