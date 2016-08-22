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

public class CouponCell: UITableViewCell {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UIButton? = nil
    @IBOutlet weak var studentSelect: TextField? = nil
    @IBOutlet weak var cartPrice: UILabel? = nil
    @IBOutlet weak var cancelButton: UIButton? = nil

    weak var json: NSDictionary? = nil
    
    @IBAction func addCart(sender: UIButton) {
        let name = self.json!["name"] as? String ?? ""
        if AppDelegate.cart.contains(name) {
            AppDelegate.cart.removeAtIndex(AppDelegate.cart.indexOf(name)!)
            (self.viewController() as? StoreController)?.updateCart()
            (self.viewController() as? StoreController)?.tableView.reloadData()
        }
        else {
            AppDelegate.cart.append(name)
            (self.viewController() as? StoreController)?.updateCart()
            self.configure(self.json!)
        }
    }
    
    func downloadLogo(url: String) {
        self.logoImage.hidden = true
        File.save(url) {(f :File) in
            let fileName = f.filename!
            let fileManager = NSFileManager.defaultManager()
            if let data = fileManager.contentsAtPath(fileName) {
                doMain {
                    self.logoImage.image = UIImage(data: data)
                    self.logoImage.hidden = false
                    
                    if let vc = AppDelegate.visibleViewController() as? StoreController {
                        (vc.view ~> CouponCell.self).each {
                            if $0.json!["logo"] as? String ?? "" == self.json!["logo"] as? String ?? "" && $0.logoImage.hidden {
                                $0.logoImage.image = self.logoImage.image
                                $0.logoImage.hidden = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func selectStudent(sender: AnyObject) {
        if let picker = (self.studentSelect!.inputView!.viewController() as! BasicKeyboardController).picker {
            picker.dataSource = self.viewController() as! StoreController
            picker.delegate = self.viewController() as! StoreController
            picker.reloadAllComponents()
        }
    }
    
    static func assignSelectKeyboard(input: TextField) {
        input.tintColor = UIColor.clearColor()
        input.inputView = BasicKeyboardController.pickerKeyboard
        BasicKeyboardController.keyboardHeight = 20 * saucyTheme.multiplier() + saucyTheme.padding * 2
        BasicKeyboardController.keyboardSwitch = {
            input.inputView = $0
            input.reloadInputViews()
        }
        input.reloadInputViews()
    }
    
    internal func configure(json: NSDictionary) {
        if self.studentSelect != nil {
            self.studentSelect!.addDoneOnKeyboardWithTarget(self.viewController(), action: #selector(StoreController.textFieldShouldReturn(_:)))
            self.studentSelect!.delegate = self.viewController() as! StoreController
            CouponCell.assignSelectKeyboard(self.studentSelect!)
        }
        self.json = json
        let title = json["description"] as? String ?? ""
        var url = json["logo"] as? String ?? ""
        if url.isEmpty {
            url = AppDelegate.studySauceCom("/bundles/studysauce/images/upload_image.png").absoluteString
        }
        AppDelegate.performContext {
            if let f = AppDelegate.list(File.self).filter({$0.url! == url}).first where f.filename != nil {
                let fileName = f.filename!
                let fileManager = NSFileManager.defaultManager()
                if let data = fileManager.contentsAtPath(fileName) {
                    doMain {
                        self.logoImage.image = UIImage(data: data)
                        self.logoImage.hidden = false
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
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        let buttonTitle:String
        self.contentView.userInteractionEnabled = true
        if self.cancelButton != nil {
            self.cancelButton!.hidden = false
            self.bringSubviewToFront(self.cancelButton!)
        }
        self.studentSelect?.enabled = true
        if AppDelegate.cart.contains(json["name"] as! String) {
            if !(self.viewController() as! StoreController).isCart {
                buttonTitle = "In cart"
                self.countLabel!.enabled = false
                self.countLabel!.setBackground(saucyTheme.middle)
            }
            else {
                buttonTitle = ""
                if self.cartPrice != nil {
                    self.cartPrice!.text = price.isZero ? "Free" : formatter.stringFromNumber(price) ?? ""
                }
            }
        } else {
            self.countLabel!.enabled = true
            self.countLabel!.setBackground(saucyTheme.secondary)
            buttonTitle = price.isZero ? "Free" : formatter.stringFromNumber(price) ?? ""
        }
        self.countLabel?.setTitle(buttonTitle, forState: UIControlState.Normal)
        self.titleLabel.text = title
    }
}


