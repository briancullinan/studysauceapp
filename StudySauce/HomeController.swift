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

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet internal weak var embeddedView: UIView!
    @IBOutlet weak var tableView: UITableView? = nil
    var packs: [Pack]? = nil
    var normalImage:UIImage!
    var selectedImage:UIImage!
    var taskManager:NSTimer? = nil
    
    @IBOutlet weak var cardCount: UILabel? = nil
    @IBOutlet weak var bigbutton: UIButton? = nil
    @IBOutlet weak var userButton: UIButton? = nil
        
    @IBAction func monkeyClick(sender: UIButton) {
        AppDelegate.performContext {
            if AppDelegate.getUser()?.getRetentionRemaining() > 0 {
                doMain {
                    self.performSegueWithIdentifier("card", sender: self)
                }
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "switch" {
            segue.destinationViewController.popoverPresentationController?.delegate = self
            segue.destinationViewController.popoverPresentationController?.sourceView = self.userButton!.titleLabel!
            segue.destinationViewController.popoverPresentationController?.sourceRect = self.userButton!.titleLabel!.bounds
            let blur = AppDelegate.createBlurView(self.userButton!)
            blur.alpha = 1
            blur.superview!.bringSubviewToFront(blur)
            self.view.bringSubviewToFront(self.userButton!)
        }
        
        if let vc = segue.destinationViewController as? CardController {
            vc.isRetention = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.viewDidLoad()
        self.childViewControllers.each{$0.viewDidAppear(animated)}
        
        if let blur = (self.view ~> UIVisualEffectView.self).first {
            UIView.animateWithDuration(0.15, animations: {
                blur.alpha = 0
                }, completion: {_ in
                    blur.removeFromSuperview()
            })
        }
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
                    doMain {
                        self.cardCount!.text = "\(count) card\(s)"
                    }
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
        }
        
        if self.tableView != nil {
            
            self.setTotal()
            
            if self.taskManager == nil {
                self.taskManager = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "viewDidLoad", userInfo: nil, repeats: true)
                NSRunLoop.mainRunLoop().addTimer(self.taskManager!, forMode: NSRunLoopCommonModes)
            }
            
            // Load packs from database
            self.getPacksFromLocalStore {
                self.tableView!.reloadData()
            }
            PackSummaryController.getPacks({
                self.getPacksFromLocalStore {
                    self.tableView!.reloadData()
                    self.setTotal()
                }
                }, downloadedHandler: {p in
                    
                    self.getPacksFromLocalStore {
                        self.tableView!.reloadData()
                        self.setTotal()
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
    
    private func getPacksFromLocalStore(done: () -> Void)
    {
        AppDelegate.performContext {
            self.packs = AppDelegate.getUser()!.getPacks()
                .filter({
                    $0.getUserPack(AppDelegate.getUser()).getRetentionCount() > 0
                })
            doMain(done)
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.packs == nil || self.packs!.count == 0 {
            return saucyTheme.textSize * saucyTheme.lineHeight * 2
        }
        return saucyTheme.textSize * saucyTheme.lineHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.packs == nil || self.packs!.count == 0 {
            return 1
        }
        return self.packs!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if AppDelegate.getUser()!.user_packs!.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("NoPacks", forIndexPath: indexPath)
            return cell
        }
        else if self.packs == nil {
            return tableView.dequeueReusableCellWithIdentifier("Loading", forIndexPath: indexPath)
        }
        else if self.packs!.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("EmptyCell", forIndexPath: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PackRetentionCell
            let object = self.packs![indexPath.row]
            cell.configure(object)
            return cell
        }
    }
    
}

