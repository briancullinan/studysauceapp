//
//  PackSummaryCell.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/22/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class PackSummaryCell: UITableViewCell {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    var updateTableView: (() -> Void)? = nil
    
    weak var pack: Pack? = nil
    
    func downloadLogo(url: String) {
        self.logoImage.hidden = true
        File.save(url, done: {(_:File) in
            dispatch_async(dispatch_get_main_queue(), {
            if self.updateTableView != nil {
                self.updateTableView!()
                self.logoImage.hidden = false
            }
            })
        })
    }
    
    internal func configure(pack: Pack) {
        self.pack = pack
        let title = pack.title
        var creator = pack.creator
        if creator == nil || creator == "" {
            creator = " "
        }
        var modified = pack.modified
        if modified == nil {
            modified = pack.created
        }
        if let url = pack.logo where !url.isEmpty {
            if let f = AppDelegate.list(File.self).filter({$0.url! == url}).first where f.filename != nil {
                let fileName = f.filename!
                let fileManager = NSFileManager.defaultManager()
                if let data = fileManager.contentsAtPath(fileName) {
                    self.logoImage.image = UIImage(data: data)
                    self.logoImage.hidden = false
                }
                else {
                    self.downloadLogo(url)
                }
            }
            else {
                self.downloadLogo(url)
            }
            self.creatorLabel.hidden = true
        }
        else {
            self.logoImage.image = nil
            self.logoImage.hidden = true
            self.creatorLabel.text = creator
            self.creatorLabel.hidden = false
        }
        let count = Int(pack.count ?? 0)
        let s = count > 1 ? "s" : ""
        self.countLabel.text = "\(count) card\(s)";
        self.titleLabel.text = title
    }
}