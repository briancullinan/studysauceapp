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
    @IBOutlet weak var embeddedView: UIView!
    @IBOutlet weak var tableView: UITableView? = nil
    var packs = [Pack]()
    var normalImage:UIImage!
    var selectedImage:UIImage!

    @IBOutlet weak var cardCount: UILabel? = nil
    @IBOutlet weak var bigbutton: UIButton? = nil
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    /*
    @IBAction func buttondown(sender: UIButton) {
        if (sender.selected)  {
            UIView.animateWithDuration(1.5, animations: {
                //self.normalImage.alpha = 1.0
                //self.selectedImage.alpha = 0.0
                sender.selected = !sender.selected;
                })
        }
        else{
            UIView.animateWithDuration(1.5, animations: {
                //self.normalImage.alpha = 0.0
                //self.selectedImage.alpha = 1.0
                }
                )
        }
    }
    
                
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let vc = segue.destinationViewController as? CardController {
            vc.isRetention = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.viewDidLoad()
        self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      /*
        if self.bigbutton!=nil{
            self.normalImage = UIImage(named: "bigbutton.png") as UIImage!
            self.selectedImage = UIImage(named: "bigbuttonpressed.png") as UIImage!
            
            //set normal image
            self.bigbutton!.setImage(normalImage, forState: UIControlState.Normal)
            //set highlighted image
            self.bigbutton!.setImage(selectedImage, forState: UIControlState.Selected)
        }
        */
        
        if self.cardCount != nil {
            let count = self.getPacksFromLocalStore().map { p -> Int in
                return p.getRetentionCardCount(AppDelegate.getUser())
                }.reduce(0, combine: +)
            let s = count == 1 ? "" : "s"
            self.cardCount!.text = "\(count) card\(s)"
        }
        
        if self.tableView != nil {
            self.tableView!.backgroundColor = UIColor.clearColor()
            self.tableView!.backgroundView = nil
        
            // Load packs from database
            self.packs = getPacksFromLocalStore()
        
            // Make the cell self size
            self.tableView!.estimatedRowHeight = 44.0
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
                    if p.getRetentionCardCount(AppDelegate.getUser()) > 0 {
                        packs.insert(p, atIndex: 0)
                    }
                }
            }
            catch let error as NSError {
                NSLog("Failed to retrieve record: \(error.localizedDescription)")
            }
        }
        return packs
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.packs.count == 0 {
            return 1
        }
        return self.packs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.packs.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("EmptyCell", forIndexPath: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PackRetentionCell
            let object = self.packs[indexPath.row]
            cell.configure(object)
            return cell
        }
    }
    
}

