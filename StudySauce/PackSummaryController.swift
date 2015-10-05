//
//  MasterViewController.swift
//  StudySauce
//
//  Created by admin on 9/12/15.
//  Copyright (c) 2015 The Study Institute. All rights reserved.
//

import UIKit
import CoreData

class PackSummaryController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var objects = [Pack]()
    var pack: Pack!
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    // load the card content, display and available answers
    func getCards(forPack: Pack, completionHandler: ([Card], NSError!) -> Void) -> Void {
        var cards = forPack.cards?.allObjects as! [Card]
        completionHandler(cards, nil)
        if let moc = AppDelegate.getContext() {
            let url = AppDelegate.studySauceCom("/packs/download?pack=\(forPack.id!)")
            let ses = NSURLSession.sharedSession()
            let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
                if (error != nil) {
                    return completionHandler([], error)
                }
                
                do {
                    var ids = [NSNumber]()
                    
                    // load packs from server
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    for card in json as! NSArray {
                        var newCard: Card?
                        for p in cards {
                            if p.id == card["id"] as? NSNumber {
                                newCard = p
                            }
                        }
                        if newCard == nil {
                            newCard = NSEntityDescription.insertNewObjectForEntityForName("Card", inManagedObjectContext: moc) as? Card
                            cards.insert(newCard!, atIndex: 0)
                        }
                        
                        ids.insert(card["id"] as! NSNumber, atIndex: 0)
                        newCard!.content = card["content"] as? String
                        newCard!.response = card["response"] as? String
                        newCard!.id = card["id"] as? NSNumber
                        newCard!.pack = forPack
                        newCard!.created = card["created"] as? NSDate
                    }
                    
                    // remove cards that no longer exist
                    for p in cards {
                        if ids.indexOf(p.id!) == nil {
                            moc.deleteObject(p)
                            cards.removeAtIndex(cards.indexOf(p)!)
                        }
                    }
                    try moc.save()
                    completionHandler(cards, nil)
                }
                catch let error as NSError {
                    completionHandler([], error)
                }
            })
            task.resume()
        }
    }
    
    func getPacks(completionHandler: ([Pack], NSError!) -> Void) -> Void {
        var packs = [Pack]()
        if let moc = AppDelegate.getContext() {
            let fetchRequest = NSFetchRequest(entityName: "Pack")
            do {
                for p in try moc.executeFetchRequest(fetchRequest) as! [Pack] {
                    packs.insert(p, atIndex: 0)
                }
                completionHandler(packs, nil)
            }
            catch let error as NSError {
                NSLog("Failed to retrieve record: \(error.localizedDescription)")
            }
            let url = AppDelegate.studySauceCom("/packs")
            let ses = NSURLSession.sharedSession()
            let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
                if (error != nil) {
                    return completionHandler([], error)
                }
                
                do {
                    var ids = [NSNumber]()
                    
                    // load packs from server
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    for pack in json as! NSArray {
                        var newPack: Pack?
                        for p in packs {
                            if p.id == pack["id"] as? NSNumber {
                                newPack = p
                            }
                        }
                        if newPack == nil {
                            newPack = NSEntityDescription.insertNewObjectForEntityForName("Pack", inManagedObjectContext: moc) as? Pack
                            packs.insert(newPack!, atIndex: 0)
                        }
                        
                        ids.insert(pack["id"] as! NSNumber, atIndex: 0)
                        newPack!.title = pack["title"] as? String
                        newPack!.id = pack["id"] as? NSNumber
                        newPack!.creator = pack["creator"] as? String
                        newPack!.logo = pack["logo"] as? String
                        newPack!.created = pack["created"] as? NSDate
                        newPack!.modified = pack["modified"] as? NSDate
                    }
                    
                    // remove packs that no longer exist
                    for p in packs {
                        if ids.indexOf(p.id!) == nil {
                            moc.deleteObject(p)
                            packs.removeAtIndex(packs.indexOf(p)!)
                        }
                    }
                    try moc.save()
                    completionHandler(packs, nil)
                }
                catch let error as NSError {
                    completionHandler([], error)
                }
            })
            task.resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load packs from database
        if let moc = AppDelegate.getContext() {
            let fetchRequest = NSFetchRequest(entityName: "Pack")
            do {
                try self.objects = moc.executeFetchRequest(fetchRequest) as! [Pack]
            }
            catch let error as NSError {
                NSLog("Failed to retrieve record: \(error.localizedDescription)")
            }
        }
        
        // Make the cell self size
        self.tableView.estimatedRowHeight = 66.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.layoutIfNeeded()
        
        // refresh data from server
        self.getPacks { (data, error) -> Void in
            if data.count > 0 {
                self.objects = data;
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject(sender: AnyObject) {
        //objects.insert(NSDate(), atIndex: 0)
        //let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        //self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardPromptController {
            vc.pack = self.pack
        }
        if let vc = segue.destinationViewController as? PackResultsController {
            vc.pack = self.pack
        }
    }
    
    // MARK: - Table View
        
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.pack = objects[indexPath.row]
        var up = pack.getUserPackForUser(AppDelegate.getUser())
        if let moc = AppDelegate.getContext() {
            if up == nil {
                up = NSEntityDescription.insertNewObjectForEntityForName("UserPack", inManagedObjectContext: moc) as? UserPack
                up!.pack = self.pack
                up!.user = AppDelegate.getUser()
                do {
                    try moc.save()
                }
                catch let error as NSError {
                    NSLog("\(error.localizedDescription)")
                }
            }
            if pack.cards!.count == 0 || up!.downloaded == nil || (pack.modified != nil
                && pack.modified!.isGreaterThanDate(up!.downloaded!)) {
                    self.getCards(pack, completionHandler: {(data, error) -> Void in
                        up!.downloaded = NSDate()
                        do {
                            try moc.save()
                        }
                        catch let error as NSError {
                            NSLog("\(error.localizedDescription)")
                        }
                        if data.count == 0 || error != nil {
                            return
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            if self.objects[indexPath.row].getCardForUser(AppDelegate.getUser()) == nil {
                                self.performSegueWithIdentifier("results", sender: self)
                            }
                            else {
                                self.performSegueWithIdentifier("prompt", sender: self)
                            }
                        })
                    })
            }
            else {
                if self.objects[indexPath.row].getCardForUser(AppDelegate.getUser()) == nil {
                    self.performSegueWithIdentifier("results", sender: self)
                }
                else {
                    self.performSegueWithIdentifier("prompt", sender: self)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PackSummaryCell
        
        let object = objects[indexPath.row]
        cell.configure(object)
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}

