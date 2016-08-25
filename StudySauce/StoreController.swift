//
//  StoreController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 8/4/16.
//  Copyright © 2016 The Study Institute. All rights reserved.
//

import Foundation
//
//  MasterViewController.swift
//  StudySauce
//
//  Created by admin on 9/12/15.
//  Copyright (c) 2015 The Study Institute. All rights reserved.
//

import UIKit
import CoreData

class StoreController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    static let StripeKeys = [
        "test.studysauce.com" : "pk_test_th5VY2bxRUDSJZ1xCcpJ7CNB",
        "cerebro.studysauce.com" : "pk_live_3R7ICVYGa9lUxr8tkOILInnI",
        "staging.studysauce.com" : "pk_test_th5VY2bxRUDSJZ1xCcpJ7CNB"
    ]
    
    var coupons: NSArray? = nil
    var pack: Pack? = nil
    var couponsLoaded = false
    var isCart = false
    var returnKeyHandler: IQKeyboardReturnKeyHandler? = nil
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var storeTop: NSLayoutConstraint!
    @IBOutlet weak var storeHeader: UIView!
    @IBOutlet weak var storeHeaderTop: NSLayoutConstraint!
    @IBOutlet weak var cartBottom: NSLayoutConstraint!
    @IBOutlet weak var cartFooter: UIView!
    @IBOutlet weak var cartFooterBottom: NSLayoutConstraint!
    @IBOutlet weak var cartCount: UILabel!
    @IBOutlet weak var cartButton: UIView!
    @IBOutlet weak var storeTitle: UILabel!
    @IBOutlet weak var subTotal: UILabel!
    @IBOutlet weak var tax: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var subTotalCount: UILabel!
    @IBOutlet weak var thankYou: UIView!
    
    @IBAction func doneClick(sender: UIButton) {
        AppDelegate.cart = []
    }
    
    @IBAction func returnToStore(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func lastClick() {
        CardSegue.transitionManager.transitioning = true
        if self.presentingViewController is StoreController {
            self.performSegueWithIdentifier("store", sender: self)
        }
        else {
            self.performSegueWithIdentifier("home", sender: self)
        }
    }
    
    static func getPrice(coupon: NSDictionary) -> Double {
        let options = coupon["options"] as! NSDictionary
        let option = coupon["options"]?.allKeys[0] as? String ?? ""
        let price = (options[option] as! NSDictionary)["price"] ?? ""
        return Double("\(price!)") ?? 0.0
    }
    
    weak var lastJson: NSDictionary? = nil
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cart = segue.destinationViewController as? StoreController where
            cart.presentingViewController == nil {
            cart.isCart = true
            cart.coupons = self.coupons
        }
        
        if let select = segue.destinationViewController as? UserSelectController {
            select.json = lastJson
        }
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        
        Stripe.setDefaultPublishableKey(StoreController.StripeKeys[AppDelegate.domain]!)
        STPAPIClient.sharedClient().createTokenWithPayment(payment) {
            (token, error) in
            if error != nil {
                completion(PKPaymentAuthorizationStatus.Failure)
                return
            }
            postJson("/checkout/pay", [
                "purchase_token" : token!.tokenId,
                "coupon" : AppDelegate.cart.joinWithSeparator("n"),
                "child" : AppDelegate.cartChildren], error: {_ in 
                    completion(PKPaymentAuthorizationStatus.Failure)
                })
            {_ in
                self.completed = true
                self.updateCart()
                self.tableView.reloadData()
                completion(PKPaymentAuthorizationStatus.Success)
            }
            
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        doMain {
            self.updateCart()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isCart {
        }
        else {
            self.getCouponsFromRemoteStore()
        }
        doMain {
            self.updateCart()
        }
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
    }
        
    var completed = false
    
    internal func updateCart() {
        var total = 0.0
        for c in self.coupons ?? [] {
            if AppDelegate.cart.contains((c as! NSDictionary)["name"] as! String) {
                total += StoreController.getPrice(c as! NSDictionary)
            }
        }
        if self.completed {
            self.view.bringSubviewToFront(thankYou)
            thankYou.hidden = false
            tableView.hidden = true
            cartBottom.active = true
            cartFooterBottom.active = false
            cartFooter.hidden = true
        }
        else if self.isCart {
            self.view.bringSubviewToFront(cartFooter)
            storeTop.active = true
            storeHeaderTop.active = false
            storeHeader.hidden = true
            //cartButton.hidden = true
            storeTitle.text = NSLocalizedString("My cart", comment: "Title for shopping cart")
            self.view.sendSubviewToBack(thankYou)
            tableView.hidden = false
            thankYou.hidden = true
            cartBottom.active = false
            cartFooterBottom.active = true
            cartFooter.hidden = false
        }
        else {
            self.view.sendSubviewToBack(cartFooter)
            cartBottom.active = true
            cartFooterBottom.active = false
            cartFooter.hidden = true
            storeTitle.text = NSLocalizedString("Store", comment: "Title for store")
            if AppDelegate.cart.count > 0 {
                storeTop.active = false
                storeHeaderTop.active = true
                storeHeader.hidden = false
            }
            else {
                storeTop.active = true
                storeHeaderTop.active = false
                storeHeader.hidden = true
            }
        }
        cartButton.hidden = true
        self.cartCount.text = "\(AppDelegate.cart.count)"
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        self.subTotal.text = formatter.stringFromNumber(total)
        self.subTotalCount.text = "Subtotal (\(AppDelegate.cart.count) items):"
        self.tax.text = formatter.stringFromNumber(total * 0.0795)
        self.total.text = formatter.stringFromNumber(total)
        self.updateViewConstraints()
    }
    
    func getCouponsFromRemoteStore() {
        let user = AppDelegate.getUser()!
        getJson("/command/results", [
            "count-file" : -1,
            "count-pack" : -1,
            "count-coupon" : 0,
            "count-card" : -1,
            "count-ss_group" : -1,
            "count-ss_user" : 1,
            "count-user_pack" : -1,
            "coupon-deleted" : "!1",
            "read-only" : false,
            "tables" : [
                "file" : ["id", "url"],
                "coupon" : ["idTilesSummary" : ["id", "name", "description", "packs", "options", "cardCount", "deleted"]],
                "ss_group" : ["id", "name", "users", "deleted"],
                "ss_user" : ["id" : ["id", "first", "last", "userPacks"]],
                "user_pack" : ["pack", "removed", "downloaded"],
                "pack" : ["idTilesSummary" : ["created", "id", "title", "logo"], "actions" : ["status"]]
            ],
            "classes" : ["tiles", "summary"],
            "headers" : ["coupon" : "store"],
            "footers" : user.hasRole("ROLE_ADMIN") ? ["coupon" : true] : false
        ]) {json in
            self.coupons = (json["results"] as? NSDictionary)?["coupon"] as? NSArray
            
            doMain {
                self.couponsLoaded = true
                self.tableView.reloadData()
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return saucyTheme.textSize * saucyTheme.lineHeight * (self.isCart ? 3 : 2)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.coupons == nil || self.coupons!.count == 0 {
            return 1
        }
        return self.isCart ? (AppDelegate.cart.count) : self.coupons!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.couponsLoaded && self.coupons?.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("NoCoupons")!
        }
        else if self.coupons == nil || self.coupons!.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier("Loading")!
        }
        
        let cell: CouponCell
        if self.isCart {
            cell = tableView.dequeueReusableCellWithIdentifier("Cart", forIndexPath: indexPath) as! CouponCell
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("Store", forIndexPath: indexPath) as! CouponCell
        }
        
        let object: NSDictionary
        if self.isCart {
            object = self.coupons!.filter({
                let name = ($0 as! NSDictionary)["name"] as! String
                return name == AppDelegate.cart[indexPath.row]
            }).first as! NSDictionary
        }
        else {
            object = self.coupons![indexPath.row] as! NSDictionary
        }
        cell.configure(object)
        return cell
    }
}


