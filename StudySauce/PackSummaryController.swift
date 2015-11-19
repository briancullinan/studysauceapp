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
    
    var packs = [Pack]()
    var pack: Pack!
    @IBOutlet weak var tableView: UITableView!
    
    // load the card content, display and available answers
    // TODO: Constrains are intentionally not used in the SQLite database ID columns to allow soft relations to other tables
    //   if the database is ever changed this feature of SQLite has to be transfered or these download functions will have to be refactored.
    func getCards(forPack: Pack, completionHandler: ([Card], NSError!) -> Void) -> Void {
        var cards = forPack.cards?.allObjects as! [Card]
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
                            newCard = moc.insert(Card.self)
                            cards.insert(newCard!, atIndex: 0)
                        }
                        
                        ids.insert(card["id"] as! NSNumber, atIndex: 0)
                        newCard!.id = card["id"] as? NSNumber
                        newCard!.content = card["content"] as? String
                        newCard!.response = card["response"] as? String
                        newCard!.response_type = card["response_type"] as? String
                        newCard!.pack = forPack
                        newCard!.created = NSDate.parse(card["created"] as? String)
                        newCard!.modified = NSDate.parse(card["modified"] as? String)
                        
                        // create anwers
                        var answers = newCard!.answers?.allObjects as! [Answer]
                        var answerIds = [NSNumber]()
                        for answer in card["answers"] as! NSArray {
                            var newAnswer: Answer?
                            for a in answers {
                                if a.id == answer["id"] as? NSNumber {
                                    newAnswer = a
                                }
                            }
                            if newAnswer == nil {
                                newAnswer = moc.insert(Answer.self)
                                answers.insert(newAnswer!, atIndex: 0)
                            }
                            
                            answerIds.insert(answer["id"] as! NSNumber, atIndex: 0)
                            newAnswer!.id = answer["id"] as? NSNumber
                            //newAnswer!.content = answer["content"] as? String
                            //newAnswer!.response = answer["response"] as? String
                            newAnswer!.value = answer["value"] as? String
                            newAnswer!.card = newCard!
                            newAnswer!.correct = answer["correct"] as? NSNumber
                            newAnswer!.created = NSDate.parse(answer["created"] as? String)
                            newAnswer!.modified = NSDate.parse(answer["modified"] as? String)
                        }
                        
                        // remove answers that no longer exist
                        for a in answers {
                            if answerIds.indexOf(a.id!) == nil {
                                moc.deleteObject(a)
                                answers.removeAtIndex(answers.indexOf(a)!)
                            }
                        }
                        
                        
                        // TODO: sync responses
                        var responses = newCard!.responses?.allObjects as! [Response]
                        for response in card["responses"] as! NSArray {
                            var newResponse: Response?
                            for r in responses {
                                if r.id == response["id"] as? NSNumber {
                                    newResponse = r
                                }
                            }
                            if newResponse == nil {
                                newResponse = moc.insert(Response.self)
                                responses.insert(newResponse!, atIndex: 0)
                            }
                            
                            newResponse!.id = response["id"] as? NSNumber
                            newResponse!.correct = response["correct"] as? NSNumber == 1
                            newResponse!.answer = answers.filter({$0.id == response["answer"] as? NSNumber}).first
                            newResponse!.value = response["value"] as? String
                            newResponse!.card = newCard
                            newResponse!.created = NSDate.parse(response["created"] as? String)
                            newResponse!.user = AppDelegate.getUser()
                        }
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
    
    func getPacks(completionHandler: () -> Void) -> Void {
        let url = AppDelegate.studySauceCom("/packs/list")
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if error != nil {
                return completionHandler()
            }
                
            do {
                var ids = [NSNumber]()
                    
                // load packs from server
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                if let moc = AppDelegate.getContext() {
                    for pack in json as! NSArray {
                        var newPack: Pack?
                        for p in self.packs {
                            if p.id == pack["id"] as? NSNumber {
                                newPack = p
                            }
                        }
                        if newPack == nil {
                            newPack = moc.insert(Pack.self)
                        }
                        
                        ids.insert(pack["id"] as! NSNumber, atIndex: 0)
                        newPack!.id = pack["id"] as? NSNumber
                        newPack!.title = pack["title"] as? String
                        newPack!.creator = pack["creator"] as? String
                        newPack!.logo = pack["logo"] as? String
                        newPack!.created = NSDate.parse(pack["created"] as? String)
                        newPack!.modified = NSDate.parse(pack["modified"] as? String)
                        newPack!.count = pack["count"] as? NSNumber
                        if pack["downloaded"] as? NSNumber == 1 {
                            self.downloadIfNeeded(newPack!, done: {})
                        }
                    }
                    
                    // remove packs that no longer exist
                    for p in self.packs {
                        if ids.indexOf(p.id!) == nil {
                            moc.deleteObject(p)
                            self.packs.removeAtIndex(self.packs.indexOf(p)!)
                        }
                    }
                    
                    AppDelegate.saveContext()
                    completionHandler()
                }
            }
            catch _ as NSError {
                completionHandler()
            }
        })
        task.resume()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.backgroundView = nil
        
        // Load packs from database
        self.packs = getPacksFromLocalStore()
        
        // Make the cell self size
        self.tableView.estimatedRowHeight = 66.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.layoutIfNeeded()
        
        // refresh data from server
        self.getPacks { () -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                self.packs = self.getPacksFromLocalStore()
                self.tableView.reloadData()
            })
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? CardController {
            vc.pack = self.pack
        }
        if let vc = segue.destinationViewController as? PackResultsController {
            vc.pack = self.pack
        }
    }
    
    func downloadIfNeeded(p: Pack, done: () -> Void) {
        // only downloaded the pack if updates are needed
        if p.isDownloading {
            return
        }
        let up = p.getUserPack(AppDelegate.getUser())
        if p.cards!.count == 0 || up.downloaded == nil
            || (p.modified != nil && p.modified! > up.downloaded!) {
                p.isDownloading = true
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {
                    self.getCards(p, completionHandler: {_,_ in
                        // TODO: update downloading status in table row!
                        up.downloaded = NSDate()
                        AppDelegate.saveContext()
                        p.isDownloading = false
                        done()
                    })
                })
        }
        else {
            done()
        }
    }
    
    // MARK: - Table View
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.pack = self.packs[indexPath.row]
        self.downloadIfNeeded(self.pack) { () -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if self.pack.cards!.count  == 0 {
                    // something went wrong
                    return
                }
                if self.pack.getUserPack(AppDelegate.getUser()).getRetryCard() == nil {
                    self.performSegueWithIdentifier("results", sender: self)
                }
                else {
                    self.performSegueWithIdentifier("card", sender: self)
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.packs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PackSummaryCell
        
        let object = self.packs[indexPath.row]
        cell.updateTableView = {
            // list all packs with the same icon
            let indexes = self.packs.filter({$0.logo != nil}).map({NSIndexPath(forRow: self.packs.indexOf($0)!, inSection: 0)})
            tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.Fade)
        }
        cell.configure(object)
        return cell
    }
    
}

