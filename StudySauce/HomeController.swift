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
        
    @IBAction func monkeyClick(sender: UIButton) {
        if AppDelegate.getUser()?.getRetentionCount() > 0 {
            self.performSegueWithIdentifier("card", sender: self)
        }
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
    
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let vc = segue.destinationViewController as? CardController {
            vc.isRetention = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.viewDidLoad()
        self.tableView?.reloadData()
    }
    
    override func shouldAutorotate() -> Bool {
        return self.view.subviews.count > 1
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
            let count = AppDelegate.getUser()!.getRetentionRemaining()
            let s = count == 1 ? "" : "s"
            self.cardCount!.text = "\(count) card\(s)"
        }
        
        if self.tableView != nil {
            // Load packs from database
            self.packs = getPacksFromLocalStore()
            PackSummaryController.getPacks({
                dispatch_async(dispatch_get_main_queue(), {
                    self.packs = self.getPacksFromLocalStore()
                    self.tableView?.reloadData()
                })
            })
        }
    }
    
    private func getPacksFromLocalStore() -> [Pack]
    {
        return AppDelegate.getContext()!.list(Pack.self)
            .filter({$0.getUserPack(AppDelegate.getUser()).getRetentionCount() > 0})
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

