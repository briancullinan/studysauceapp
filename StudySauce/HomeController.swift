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

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {
    @IBOutlet weak var embeddedView: UIView!
    @IBOutlet weak var tableView: UITableView? = nil
    var packs = [Pack]()
    var normalImage:UIImage!
    var selectedImage:UIImage!
    var taskManager:NSTimer? = nil
    var firstTime = true

    @IBOutlet weak var cardCount: UILabel? = nil
    @IBOutlet weak var bigbutton: UIButton? = nil
    @IBOutlet weak var userButton: UIButton? = nil
        
    @IBAction func monkeyClick(sender: UIButton) {
        AppDelegate.performContext {
            if AppDelegate.getUser()?.getRetentionRemaining() > 0 {
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier("card", sender: self)
                })
            }
        }
    }
    
    @IBAction func returnToHome(segue: UIStoryboardSegue) {
        self.viewDidAppear(true)
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
    }
    
    override func shouldAutorotate() -> Bool {
        return self.view.subviews.count > 1
    }
    
    func setTotal() {
        
        if self.cardCount != nil {
            AppDelegate.performContext {
                if AppDelegate.getUser() != nil {
                    let count = AppDelegate.getUser()!.getRetentionRemaining()
                    let s = count == 1 ? "" : "s"
                    dispatch_async(dispatch_get_main_queue(), {
                        self.cardCount!.text = "\(count) card\(s)"
                    })
                }
            }
        }

    }
    
    @IBAction func userClick(sender: UIButton) {
        /*
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Switch User", style: UIAlertActionStyle.Default, handler: { (a: UIAlertAction) -> Void in
            self.stopTasks()
            self.performSegueWithIdentifier("switch", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Log Out", style: UIAlertActionStyle.Default, handler: { (a: UIAlertAction) -> Void in
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = self.userButton
        alert.popoverPresentationController?.sourceRect = self.userButton!.bounds
        self.presentViewController(alert, animated: true) { () -> Void in }
        */
        self.stopTasks()
        self.performSegueWithIdentifier("switch", sender: self)
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
        if AppDelegate.getUser() == nil {
            return
        }
        
        if self.userButton != nil {
            self.userButton?.setTitle(AppDelegate.getUser()?.first, forState: .Normal)
            
            if self.firstTime {
                AppDelegate.performContext({
                    if AppDelegate.getUser()?.getProperty("seen_tutorial") as? Bool != true
                    {
                        AppDelegate.getUser()?.setProperty("seen_tutorial", true)
                        AppDelegate.saveContext()
                        dispatch_async(dispatch_get_main_queue(), {
                            self.performSegueWithIdentifier("tutorial", sender: self)
                        })
                    }
                })
                self.firstTime = false
            }
        }
        
        if self.tableView != nil {
            
            self.setTotal()
            
            if self.taskManager == nil {
                self.taskManager = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "viewDidLoad", userInfo: nil, repeats: true)
                NSRunLoop.mainRunLoop().addTimer(self.taskManager!, forMode: NSRunLoopCommonModes)
            }
            
            // Load packs from database
            AppDelegate.performContext {
                self.packs = self.getPacksFromLocalStore()
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView!.reloadData()
                })
            }
            PackSummaryController.getPacks({
                AppDelegate.performContext {
                    self.packs = self.getPacksFromLocalStore()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView!.reloadData()
                        self.setTotal()
                    })
                }
                }, downloadedHandler: {p in
                    AppDelegate.performContext {
                        self.packs = self.getPacksFromLocalStore()
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView!.reloadData()
                            self.setTotal()
                        })
                    }
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.stopTasks()
    }
    
    private func stopTasks() {
        self.taskManager?.invalidate()
        self.taskManager = nil
        for vc in self.childViewControllers {
            (vc as? HomeController)?.taskManager?.invalidate()
            (vc as? HomeController)?.taskManager = nil
        }
    }
    
    private func getPacksFromLocalStore() -> [Pack]
    {
        return AppDelegate.getUser()?.getPacks()
            .filter({
                $0.getUserPack(AppDelegate.getUser()).getRetentionCount() > 0
            }) ?? []
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return saucyTheme.textSize * 2 * saucyTheme.multiplier()
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

