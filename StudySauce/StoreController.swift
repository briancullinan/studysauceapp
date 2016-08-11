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
import PassKit

class StoreController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, PKPaymentAuthorizationViewControllerDelegate {
    
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
    var users: [User] = []
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
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
    @IBOutlet weak var placeOrder: UIButton? = nil
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

    @IBAction func placeOrderClick(sender: UIButton) {
        if let blank = sinq(AppDelegate.cart).except(AppDelegate.cartChildren.keys, key: {$0}).toArray().first {
            self.tableView.scrollToRowAtIndexPath(
                NSIndexPath(forRow: AppDelegate.cart.indexOf(blank)!, inSection: 0),
                atScrollPosition: UITableViewScrollPosition.Top,
                animated: false)
                (self.view ~> (CouponCell.self ~* {$0.json!["name"] as! String == blank})).first!.studentSelect!.becomeFirstResponder()
            return
        }
        if !self.placeOrder!.enabled {
            return
        }
        (self.view ~> TextField.self).each {
            $0.resignFirstResponder()
        }
        
        var summary: [PKPaymentSummaryItem] = []
        var total = 0.0
        for c in self.coupons! {
            if AppDelegate.cart.contains(c["name"] as! String) {
                let price = StoreController.getPrice(c as! NSDictionary)
                summary.append(PKPaymentSummaryItem(label: c["description"] as! String, amount: NSDecimalNumber(double: price)))
                total += price
            }
        }
        
        if total.isZero {
            postJson("/checkout/pay", [
                "coupon" : AppDelegate.cart.joinWithSeparator("n"),
                "child" : AppDelegate.cartChildren])
            {_ in
                self.completed = true
                self.updateCart()
                self.tableView.reloadData()
            }
        }
        else {
            let request = PKPaymentRequest()
            request.merchantIdentifier = "merchant.\(NSBundle.mainBundle().bundleIdentifier)"
            request.supportedNetworks = SupportedPaymentNetworks
            request.merchantCapabilities = PKMerchantCapability.Capability3DS
            request.countryCode = "US"
            request.currencyCode = "USD"
            request.paymentSummaryItems = summary
            request.paymentSummaryItems.append(PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(double: total * 0.0795)))
            request.paymentSummaryItems.append(PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(double: total + total * 0.0795)))
            let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
            self.presentViewController(applePayController, animated: true, completion: nil)
            applePayController.delegate = self
        }
    }
    
    static func getPrice(coupon: NSDictionary) -> Double {
        let options = coupon["options"] as! NSDictionary
        let option = coupon["options"]?.allKeys[0] as? String ?? ""
        let price = (options[option] as! NSDictionary)["price"] ?? ""
        return Double("\(price!)") ?? 0.0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cart = segue.destinationViewController as? StoreController where
            cart.presentingViewController == nil {
            cart.isCart = true
            cart.coupons = self.coupons
        }
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        
        Stripe.setDefaultPublishableKey(StoreController.StripeKeys[AppDelegate.studySauceCom("/").host!]!)
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
            self.getUsersFromLocalStore()
            if !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks) {
                self.placeOrder!.enabled = false
            }
            else {
                self.placeOrder!.enabled = true
            }
        }
        else {
            self.getCouponsFromRemoteStore()
        }
        doMain {
            self.updateCart()
        }
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
    }
    
    func getUsersFromLocalStore() {
        AppDelegate.performContext {
            let users = AppDelegate.list(User.self)
                .filter{
                    return ($0.getProperty("session") as? [[String : AnyObject]] ?? [[String : AnyObject]]()).filter{
                        return "\($0["Domain"]!)" == AppDelegate.domain}.count > 0}
            self.users = users
        }
    }
    
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if row == 0 {
            return
        }
        (self.view ~> CouponCell.self).each {
            if $0.studentSelect!.isFirstResponder() {
                $0.studentSelect!.text = self.users[row-1].first! + " " + self.users[row-1].last!
                AppDelegate.cartChildren[$0.json!["name"] as! String] = self.users[row-1].id!
            }
        }
    }
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.users.count + 1
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Select a student"
        }
        return self.users[row-1].first! + " " + self.users[row-1].last!
    }
    
    var completed = false
    
    internal func updateCart() {
        if self.isCart {
            storeTop.active = true
            storeHeaderTop.active = false
            storeHeader.hidden = true
            cartBottom.active = false
            cartFooterBottom.active = true
            cartFooter.hidden = false
            cartButton.hidden = true
            storeTitle.text = NSLocalizedString("My cart", comment: "Title for shopping cart")
            if self.completed {
                thankYou.hidden = false
                tableView.hidden = true
            }
            else {
                tableView.hidden = false
                thankYou.hidden = true
            }
        }
        else {
            cartBottom.active = true
            cartFooterBottom.active = false
            cartFooter.hidden = true
            cartButton.hidden = false
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
        self.cartCount.text = "\(AppDelegate.cart.count)"
        var total = 0.0
        for c in self.coupons ?? [] {
            if AppDelegate.cart.contains((c as! NSDictionary)["name"] as! String) {
                total += StoreController.getPrice(c as! NSDictionary)
            }
        }
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
            "read-only" : false,
            "tables" : [
                "file" : ["id", "url"],
                "coupon" : ["idTilesSummary" : ["id", "name", "description", "packs", "options", "cardCount"]],
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

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doMain {
            self.placeOrderClick(self.placeOrder!)
        }
        return true
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


