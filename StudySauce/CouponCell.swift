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
import StoreKit

public class CouponCell: UITableViewCell, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UIButton!
    @IBOutlet weak var studentSelect: TextField? = nil
    @IBOutlet weak var cartPrice: UILabel? = nil

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
                    
                    if let vc = AppDelegate.visibleViewController() as? PackSummaryController {
                        (vc.view ~> PackSummaryCell.self).each {
                            if $0.pack!.logo == self.json!["logo"] as? String ?? "" && $0.logoImage.hidden {
                                $0.logoImage.image = self.logoImage.image
                                $0.logoImage.hidden = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func placeOrderClick(sender: UIButton) {
        self.studentSelect?.resignFirstResponder()
        let props = self.json!["options"] as! NSDictionary
        let option = props.allKeys[0] as? String ?? ""
        let price = (props[option] as! NSDictionary)["price"] ?? ""
        if (Double("\(price!)") ?? 0.0).isZero {
            postJson("/checkout/pay", [:]) {_ in
                
            }
        }
        else {
            let productID:NSSet = NSSet(object: option);
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
    
    public func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])    {
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchased:
                postJson("/checkout/pay", [:]) {_ in 
                    
                }
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                break;
            case .Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                break;
                // case .Restored:
            //[self restoreTransaction:transaction];
            default:
                break;
            }
        }
    }
    
    public func request(request: SKRequest, didFailWithError error: NSError) {
        NSLog(error.description)
    }
    
    public func productsRequest (request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let count : Int = response.products.count
        if (count>0) {
            var validProducts = response.products
            let validProduct: SKProduct = validProducts[0] as SKProduct
            if validProduct.productIdentifier == (self.json!["options"] as! NSDictionary).allKeys[0] as! String {
                let payment = SKPayment(product: validProduct)
                SKPaymentQueue.defaultQueue().addPayment(payment);
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
            self.studentSelect!.addDoneOnKeyboardWithTarget(self.viewController(), action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
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
        let count = json["cardCount"] as? Int ?? 0
        let s = count == 1 ? " card" : " cards"
        let option = json["options"]?.allKeys[0] as? String ?? ""
        let props = json["options"] as! NSDictionary
        let price = (props[option] as! NSDictionary)["price"] ?? ""
        let dbl = Double("\(price!)")
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        let buttonTitle:String
        if AppDelegate.cart.contains(json["name"] as! String) {
            if !(self.viewController() as! StoreController).isCart {
                buttonTitle = "In cart"
                self.countLabel.enabled = false
                self.countLabel.setBackground(saucyTheme.middle)
            }
            else {
                if self.cartPrice != nil {
                    self.cartPrice!.text = (dbl ?? 0.0).isZero ? "Free" : formatter.stringFromNumber(dbl!) ?? ""
                }
                if (dbl ?? 0.0).isZero || SKPaymentQueue.canMakePayments() {
                    if (dbl ?? 0.0).isZero {
                        buttonTitle = "Add"
                    }
                    else {
                        buttonTitle = "Buy"
                    }
                    self.countLabel.enabled = true
                    self.countLabel.setBackground(saucyTheme.primary)
                }
                else {
                    buttonTitle = "Unavailable"
                    self.countLabel.enabled = false
                    self.countLabel.setBackground(saucyTheme.middle)
                }
            }
        } else {
            self.countLabel.enabled = true
            self.countLabel.setBackground(saucyTheme.secondary)
            buttonTitle = (dbl ?? 0.0).isZero ? "Free" : formatter.stringFromNumber(dbl!) ?? ""
        }
        self.countLabel.setTitle(buttonTitle, forState: UIControlState.Normal)
        self.titleLabel.text = title
    }
}