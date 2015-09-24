//
//  MasterViewController.swift
//  StudySauce
//
//  Created by admin on 9/12/15.
//  Copyright (c) 2015 The Study Institute. All rights reserved.
//

import UIKit
import CoreData

class PackSummaryController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Pack]()

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
    
    func getData(completionHandler: ([Pack], NSError!) -> Void) -> Void {
        var packs = [Pack]()
        if let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
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
        let url: NSURL = NSURL(string: "https://cerebro.studysauce.com/packs")!
        let ses = NSURLSession.sharedSession()
        let task = ses.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            if (error != nil) {
                return completionHandler([], error)
            }
            
            do {
                // TODO: remove packs that no longer exist
                for p in packs {
                    moc.deleteObject(p)
                    packs.removeAtIndex(packs.indexOf(p)!)
                }
                
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
                    }
                    
                    newPack!.title = pack["title"] as? String
                    newPack!.id = pack["id"] as? NSNumber
                    newPack!.creator = pack["creator"] as? String
                    newPack!.logo = pack["logo"] as? String
                    packs.insert(newPack!, atIndex: 0)
                    try moc.save()
                }
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
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        // Load menu items from database
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "Pack")
            do {
                try objects = managedObjectContext.executeFetchRequest(fetchRequest) as! [Pack]
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
        self.getData { (data, error) -> Void in
            self.objects = data;
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
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PackSummaryCell

        let object = objects[indexPath.row]
        
        let title = object.title
        let creator = object.creator
        if let url = object.logo where !url.isEmpty {
            let logo = UIImage(data: NSData(contentsOfURL: NSURL(string:url)!)!)!
            cell.configure(logo, title: title, creator: creator)
        }
        else {
            cell.configure(nil, title: title, creator: creator)
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

