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

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView? = nil
    var packs = [Pack]()

    @IBOutlet weak var imageButton: UIImageView!
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
    
    @IBAction func monkeyClick(sender: AnyObject) {
        // TODO: get card from user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.tableView != nil {
        self.tableView!.backgroundColor = UIColor.clearColor()
        self.tableView!.backgroundView = nil
        
        // Load packs from database
        self.packs = getPacksFromLocalStore()
        
        // Make the cell self size
        self.tableView!.estimatedRowHeight = 66.0
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.layoutIfNeeded()
        
        // refresh data from server
        //self.getPacks { () -> Void in
        //    dispatch_async(dispatch_get_main_queue(), {
        //        self.packs = self.getPacksFromLocalStore()
        //        self.tableView.reloadData()
        //    })
        //}
        }
    }
    
    private func getPacksFromLocalStore() -> [Pack]
    {
        var packs = [Pack]()
        if let moc = AppDelegate.getContext() {
            let fetchRequest = NSFetchRequest(entityName: "Pack")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
            do {
                for p in try moc.executeFetchRequest(fetchRequest) as! [Pack] {
                    packs.insert(p, atIndex: 0)
                }
            }
            catch let error as NSError {
                NSLog("Failed to retrieve record: \(error.localizedDescription)")
            }
        }
        return packs
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.packs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PackSummaryCell
        
        let object = self.packs[indexPath.row]
        cell.configure(object)
        return cell
    }
    
}