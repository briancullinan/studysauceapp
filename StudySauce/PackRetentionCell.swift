
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
    
    @IBOutlet weak var titleLabel: UILabel!
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
        let count = pack.getRetentionCardCount(AppDelegate.getUser())
        self.countLabel.text = "\(count)";
        self.titleLabel.text = title
    }
}