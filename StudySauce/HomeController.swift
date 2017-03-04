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
    @IBOutlet weak var monkeyButton: UIButton? = nil
    var packs: [Pack]? = nil {
        didSet {
            self.hasRetention = packs != nil && packs!.count > 0
        }
    }
    var normalImage:UIImage!
    var selectedImage:UIImage!
    fileprivate var taskManager:Timer? = nil
    var checking = false
    var selectedPack: Pack? = nil
    
    @IBOutlet weak var cardCount: UILabel? = nil
    @IBOutlet weak var bigButton: UIButton? = nil
    @IBOutlet weak var userButton: UIButton? = nil
    @IBOutlet weak var cartCount: UILabel? = nil
        
    @IBAction func monkeyClick(_ sender: UIButton) {
        if self.hasRetention {
            self.monkeyButton?.isHighlighted = true
            self.hasRetention = false
            self.selectedPack = nil
            self.performSegue(withIdentifier: "card", sender: self)
        }
    }
    
    @IBAction func returnToHome(_ segue: UIStoryboardSegue) {
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
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "switch" {
            //if segue.destinationViewController.popoverPresentationController == nil {
            //    segue.destinationViewController.popoverPresentationController = UIPopoverPresentationController(segue.destinationViewController, self)
            //}
            segue.destination.transitioningDelegate = CardSegue.transitionManager
            segue.source.transitioningDelegate = CardSegue.transitionManager
            segue.destination.popoverPresentationController!.delegate = self
            segue.destination.popoverPresentationController!.sourceView = self.userButton!.titleLabel!
            segue.destination.popoverPresentationController!.sourceRect = self.userButton!.titleLabel!.bounds
            if (self.view! ~> UIVisualEffectView.self).count == 0 {
                let blur = AppDelegate.createBlurView(self.userButton!)
                blur.alpha = 1
                blur.superview!.bringSubview(toFront: blur)
                self.view.bringSubview(toFront: self.userButton!)
            }
        }
        
        if let vc = segue.destination as? CardController {
            vc.isRetention = true
            vc.selectedPack = self.selectedPack
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let blur = (self.view ~> UIVisualEffectView.self).first {
            UIView.animate(withDuration: 0.15, animations: {
                blur.alpha = 0
                }, completion: {_ in
                    blur.removeFromSuperview()
            })
        }
        
        doMain {
            self.viewDidLoad()
            
            if self.tableView != nil {
                self.packRefresher?.invalidate()
                self.packRefresher = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(HomeController.homeSync), userInfo: nil, repeats: false)
            }
        }
    }
    
    override var shouldAutorotate : Bool {
        return self.view.subviews.count > 1
    }
    
    @IBAction func userClick(_ sender: UIButton) {
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
        self.performSegue(withIdentifier: "switch", sender: self)
    }
    
    var packsLoaded = false
    
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
        if cartCount != nil {
            if AppDelegate.cart.count == 0 {
                cartCount!.isHidden = true
            }
            else {
                cartCount!.text = "\(AppDelegate.cart.count)"
                cartCount?.isHidden = false
            }
        }
        
        self.monkeyButton?.setImage(UIImage(named: "shuffle_gray"), for: .disabled)
        self.monkeyButton?.setImage(UIImage(named: "shuffle_depressed"), for: .highlighted)
        if AppDelegate.getUser() == nil {
            return
        }
        
        if self.userButton != nil {
            self.userButton?.setTitle(AppDelegate.getUser()?.first, for: UIControlState())
        }
        
        if self.tableView != nil {
            
            if self.taskManager == nil {
                self.taskManager = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(HomeController.homeSync), userInfo: nil, repeats: true)
            }
        }
    }
    
    var packRefresher: Timer? = nil
    
    func homeSync() {
        if AppDelegate.visibleViewController() != self && AppDelegate.visibleViewController() != self.parent {
            return
        }
        
        let user = AppDelegate.getUser()
        print("Syncing...")
        // Load packs from database
        PackSummaryController.getPacks({
            if AppDelegate.getUser() != user {
                return
            }
            HomeController.syncResponses {
                self.packsLoaded = true
                doMain {
                    self.packRefresher?.invalidate()
                    self.packRefresher = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(HomeController.getPacks), userInfo: nil, repeats: false)
                }
            }
            }, downloadedHandler: {p in
                doMain {
                    self.packRefresher?.invalidate()
                    self.packRefresher = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(HomeController.getPacks), userInfo: nil, repeats: false)
                }
        })
    }
    
    internal static func syncResponses(_ pack: Pack? = nil, _ done: @escaping () -> Void = {}) {
        let responses = AppDelegate.getPredicate(Response.self, NSPredicate(format: "id==0 AND user==%@", AppDelegate.getUser()!))
        var index = 0
        var data = Dictionary<String, AnyObject>()
        data["version"] = 2 as AnyObject
        for response in responses {
            let correct = response.correct != nil && response.correct == 1
            let answer = response.answer != nil ? response.answer!.id! : 0
            let created = response.created!.toRFC()
            let cardId = response.card!.id!
            data["responses[\(index)][value]"] = response.value as AnyObject
            data["responses[\(index)][card]"] = cardId as AnyObject
            data["responses[\(index)][correct]"] = correct as AnyObject
            data["responses[\(index)][answer]"] = answer as AnyObject
            data["responses[\(index)][created]"] = created as AnyObject
            index += 1
        }
        if pack != nil {
            data["pack"] = pack!.id!
        }
        let user = AppDelegate.getUser()!
        postJson("/packs/responses/\(user.id!)", data) {json -> Void in
            if let ids = json as? NSDictionary {
                AppDelegate.performContext {
                    print("Sync downloaded")
                    for r in responses {
                        AppDelegate.deleteObject(r)
                    }
                    AppDelegate.saveContext()
                    
                    if AppDelegate.getUser() != user {
                        return
                    }
                    
                    if pack != nil {
                        if let retention = ids["retention"] as? NSDictionary {
                            let up = pack!.getUserPack(user)
                            up.retention = retention
                        }
                    }
                    else {
                        if let retentionPacks = ids["retention"] as? NSArray {
                            for retentionPack in retentionPacks {
                                if let r = retentionPack as? NSDictionary {
                                    let pack = AppDelegate.get(Pack.self, r["id"] as! NSNumber)!
                                    if let retention = r["retention"] as? NSDictionary {
                                        let up = pack.getUserPack(user)
                                        up.retention = retention
                                    }
                                }
                            }
                        }
                    }
                    AppDelegate.saveContext()
                    done()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopTasks()
    }
    
    func stopTasks() {
        self.taskManager?.invalidate()
        self.taskManager = nil
        self.packRefresher?.invalidate()
        self.packRefresher = nil
        for vc in self.childViewControllers {
            (vc as? HomeController)?.taskManager?.invalidate()
            (vc as? HomeController)?.taskManager = nil
            (vc as? HomeController)?.packRefresher?.invalidate()
            (vc as? HomeController)?.packRefresher = nil
        }
        (self.parent as? HomeController)?.taskManager?.invalidate()
        (self.parent as? HomeController)?.taskManager = nil
        (self.parent as? HomeController)?.packRefresher?.invalidate()
        (self.parent as? HomeController)?.packRefresher = nil
    }
    
    func getPacks() {
        AppDelegate.performContext {
            self.getPacksFromLocalStore();
        }
    }
    
    fileprivate func getPacksFromLocalStore()
    {
        if AppDelegate.getUser() == nil  || !(AppDelegate.visibleViewController() is HomeController) {
            return
        }
        
        print("Loading packs")
        
        self.packRefresher = nil
        
        var total = "0 cards"
        if self.cardCount != nil {
            let count = AppDelegate.getUser()!.getRetentionRemaining()
            let s = count == 1 ? "" : "s"
            total = "\(count) card\(s)"
        }
        
        let allPacks = AppDelegate.getUser()!.getPacks()
        let packs = allPacks.filter({!$0.isDownloading}).filter({$0.getUserPack(AppDelegate.getUser()).getRetentionCount() > 0})
        
        doMain {
            self.hasPacks = allPacks.count > 0
            self.hasDownloading = allPacks.filter({$0.isDownloading}).count > 0
            self.packs = packs
            print("Updating home screen")
            (self.parent as? HomeController)?.monkeyButton?.isEnabled = self.hasRetention
            self.cardCount!.text = total
            self.tableView!.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.packs == nil || self.packs!.count == 0  {
            return saucyTheme.textSize * saucyTheme.lineHeight * 2
        }
        return saucyTheme.textSize * saucyTheme.lineHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.packs == nil || self.packs!.count == 0  {
            return 1
        }
        return self.packs!.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.packs == nil || self.packs!.count == 0  {
            return
        }
        if let home = self.parent as? HomeController {
            home.selectedPack = self.packs![(indexPath as NSIndexPath).row]
            home.performSegue(withIdentifier: "card", sender: self)
            home.checking = false
        }
    }
    
    var hasPacks = false
    var hasRetention = false {
        didSet {
            (self.parent as? HomeController)?.hasRetention = self.hasRetention
        }
    }
    var hasDownloading = false
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.packs != nil && self.packsLoaded && !self.hasPacks {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoPacks", for: indexPath)
            return cell
        }
        else if self.packs == nil || (self.hasDownloading && self.packs!.count == 0) {
            return tableView.dequeueReusableCell(withIdentifier: "Loading", for: indexPath)
        }
        else if !self.hasRetention && !self.hasDownloading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PackRetentionCell
            let object = self.packs![(indexPath as NSIndexPath).row]
            cell.configure(object)
            return cell
        }
    }
    
}

