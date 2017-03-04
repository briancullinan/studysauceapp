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

open class CouponCell: UITableViewCell {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UIButton? = nil
    @IBOutlet weak var studentSelect: TextField? = nil
    @IBOutlet weak var cartPrice: UILabel? = nil
    @IBOutlet weak var cancelButton: UIButton? = nil

    weak var json: NSDictionary? = nil
    
    @IBAction func addCart(_ sender: UIButton) {
        let name = self.json!["name"] as? String ?? ""
        if AppDelegate.cart.contains(name) {
            AppDelegate.cart.remove(at: AppDelegate.cart.index(of: name)!)
            (self.viewController() as? StoreController)?.updateCart()
            (self.viewController() as? StoreController)?.tableView.reloadData()
        }
        else {
            AppDelegate.cart.append(name)
            (self.viewController() as? StoreController)?.updateCart()
            self.configure(self.json!)
        }
    }
    
    func downloadLogo(_ url: String) {
        self.logoImage.isHidden = true
        File.save(url) {(f :File) in
            let fileName = f.filename!
            let fileManager = FileManager.default
            if let data = fileManager.contents(atPath: fileName) {
                doMain {
                    self.logoImage.image = UIImage(data: data)
                    self.logoImage.isHidden = false
                    
                    if let vc = AppDelegate.visibleViewController() as? StoreController {
                        (vc.view ~> CouponCell.self).each {
                            if $0.json!["logo"] as? String ?? "" == self.json!["logo"] as? String ?? "" && $0.logoImage.isHidden {
                                $0.logoImage.image = self.logoImage.image
                                $0.logoImage.isHidden = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func placeOrderClick(_ sender: UIButton) {
        (self.viewController() as! StoreController).lastJson = self.json
        (self.viewController() as! StoreController).performSegue(withIdentifier: "selectUser", sender: sender)
    }
    
    internal func configure(_ json: NSDictionary) {
        self.json = json
        let title = json["description"] as? String ?? ""
        var url = json["logo"] as? String ?? ""
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
        let price = StoreController.getPrice(self.json!)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let buttonTitle:String
        self.contentView.isUserInteractionEnabled = true
        if self.cancelButton != nil {
            self.cancelButton!.isHidden = false
            self.bringSubview(toFront: self.cancelButton!)
        }
        self.studentSelect?.isEnabled = true
        if AppDelegate.cart.contains(json["name"] as! String) {
            if !(self.viewController() as! StoreController).isCart {
                buttonTitle = "In cart"
                self.countLabel!.isEnabled = false
                self.countLabel!.setBackground(saucyTheme.middle)
            }
            else {
                buttonTitle = ""
                if self.cartPrice != nil {
                    self.cartPrice!.text = price.isZero ? "Free" : formatter.string(from: price as NSNumber) ?? ""
                }
            }
        } else {
            self.countLabel!.isEnabled = true
            self.countLabel!.setBackground(saucyTheme.secondary)
            buttonTitle = price.isZero ? "Free" : formatter.string(from: price as NSNumber) ?? ""
        }
        self.countLabel?.setTitle(buttonTitle, for: UIControlState())
        self.titleLabel.text = title
    }
}


