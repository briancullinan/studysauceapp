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

open class PackSummaryCell: UITableViewCell {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    weak var pack: Pack? = nil
    
    func downloadLogo(_ url: String) {
        self.logoImage.isHidden = true
        File.save(url) {(f :File) in
            let fileName = f.filename!
            let fileManager = FileManager.default
            if let data = fileManager.contents(atPath: fileName) {
                doMain {
                    self.logoImage.image = UIImage(data: data)
                    self.logoImage.isHidden = false
                    
                    if let vc = AppDelegate.visibleViewController() as? PackSummaryController {
                        (vc.view ~> PackSummaryCell.self).each {
                            if $0.pack!.logo == self.pack!.logo && $0.logoImage.isHidden {
                                $0.logoImage.image = self.logoImage.image
                                $0.logoImage.isHidden = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    internal func configure(_ pack: Pack) {
        self.pack = pack
        let title = pack.title
        var url = pack.logo ?? ""
        if url.isEmpty {
            url = AppDelegate.studySauceCom("/bundles/studysauce/images/upload_image.png").absoluteString
        }
        AppDelegate.performContext {
            if let f = AppDelegate.list(File.self).filter({$0.url! == url}).first , f.filename != nil {
                let fileName = f.filename!
                let fileManager = FileManager.default
                if let data = fileManager.contents(atPath: fileName) {
                    doMain {
                        self.logoImage.image = UIImage(data: data)
                        self.logoImage.isHidden = false
                    }
                }
                else {
                    self.downloadLogo(url)
                }
            }
            else {
                self.downloadLogo(url)
            }
        }
        let count = Int(pack.count ?? 0)
        let s = count > 1 ? "s" : ""
        self.countLabel.text = "\(count) card\(s)";
        self.titleLabel.text = title
    }
}
