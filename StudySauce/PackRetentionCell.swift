
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

public class PackRetentionCell: UITableViewCell {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    weak var pack: Pack? = nil
    
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
            let logo = UIImage(data: NSData(contentsOfURL: NSURL(string:url)!)!)!
            self.logoImage.image = logo
            self.logoImage.hidden = false
            self.creatorLabel.hidden = true
        }
        else {
            self.logoImage.image = nil
            self.logoImage.hidden = true
            self.creatorLabel.text = creator
            self.creatorLabel.hidden = false
        }
        let count = Int(pack.count ?? 0) // getCardCount(AppDelegate.getUser())
        let s = count > 1 ? "s" : ""
        self.countLabel.text = "\(count) card\(s)";
        self.titleLabel.text = title
    }
}