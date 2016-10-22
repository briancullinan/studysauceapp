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
    
    @IBAction func doneClick(_ sender: UIButton) {
        AppDelegate.cart = []
    }
    
    @IBAction func returnToStore(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func lastClick() {
        CardSegue.transitionManager.transitioning = true
        if self.presentingViewController is StoreController {
            self.performSegue(withIdentifier: "store", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "home", sender: self)
        }
    }
    
    static func getPrice(_ coupon: NSDictionary) -> Double {
        let options = coupon["options"] as! NSDictionary
        let option = (coupon["options"] as AnyObject).allKeys[0] as? String ?? ""
        let price = (options[option] as! NSDictionary)["price"] ?? ""
        return Double("\(price)") ?? 0.0
    }
    
    weak var lastJson: NSDictionary? = nil
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cart = segue.destination as? StoreController ,
            cart.presentingViewController == nil {
            cart.isCart = true
            cart.coupons = self.coupons
        }
        
        if let select = segue.destination as? UserSelectController {
            select.json = lastJson as! Dictionary<String, Any>?
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        
        Stripe.setDefaultPublishableKey(StoreController.StripeKeys[AppDelegate.domain]!)
        STPAPIClient.shared().createToken(with: payment) {
            (token, error) in
            if error != nil {
                completion(PKPaymentAuthorizationStatus.failure)
                return
            }
            postJson("/checkout/pay", [
                "purchase_token" : token!.tokenId as Optional<AnyObject>,
                "coupon" : AppDelegate.cart.joined(separator: "n") as Optional<AnyObject>,
                "child" : AppDelegate.cartChildren as Optional<AnyObject>
                ], error: {_ in
                    completion(PKPaymentAuthorizationStatus.failure)
                })
            {_ in
                self.completed = true
                self.updateCart()
                self.tableView.reloadData()
                completion(PKPaymentAuthorizationStatus.success)
            }
            
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        var total = Double(0.0)
        for c in self.coupons ?? [] {
            if AppDelegate.cart.contains((c as! NSDictionary)["name"] as! String) {
                total += StoreController.getPrice(c as! NSDictionary)
            }
        }
        if self.completed {
            self.view.bringSubview(toFront: thankYou)
            thankYou.isHidden = false
            tableView.isHidden = true
            cartBottom.isActive = true
            cartFooterBottom.isActive = false
            cartFooter.isHidden = true
        }
        else if self.isCart {
            self.view.bringSubview(toFront: cartFooter)
            storeTop.isActive = true
            storeHeaderTop.isActive = false
            storeHeader.isHidden = true
            //cartButton.hidden = true
            storeTitle.text = NSLocalizedString("My cart", comment: "Title for shopping cart")
            self.view.sendSubview(toBack: thankYou)
            tableView.isHidden = false
            thankYou.isHidden = true
            cartBottom.isActive = false
            cartFooterBottom.isActive = true
            cartFooter.isHidden = false
        }
        else {
            self.view.sendSubview(toBack: cartFooter)
            cartBottom.isActive = true
            cartFooterBottom.isActive = false
            cartFooter.isHidden = true
            storeTitle.text = NSLocalizedString("Store", comment: "Title for store")
            if AppDelegate.cart.count > 0 {
                storeTop.isActive = false
                storeHeaderTop.isActive = true
                storeHeader.isHidden = false
            }
            else {
                storeTop.isActive = true
                storeHeaderTop.isActive = false
                storeHeader.isHidden = true
            }
        }
        cartButton.isHidden = true
        self.cartCount.text = "\(AppDelegate.cart.count)"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        self.subTotal.text = formatter.string(from: total as NSNumber)
        self.subTotalCount.text = "Subtotal (\(AppDelegate.cart.count) items):"
        self.tax.text = formatter.string(from: total * Double(0.0795) as NSNumber)
        self.total.text = formatter.string(from: total as NSNumber)
        self.updateViewConstraints()
    }
    
    func getCouponsFromRemoteStore() {
        let user = AppDelegate.getUser()!
        getJson("/command/results", [
            "count-file" : -1 as Optional<AnyObject>,
            "count-pack" : -1 as Optional<AnyObject>,
            "count-coupon" : 0 as Optional<AnyObject>,
            "count-card" : -1 as Optional<AnyObject>,
            "count-ss_group" : -1 as Optional<AnyObject>,
            "count-ss_user" : 1 as Optional<AnyObject>,
            "count-user_pack" : -1 as Optional<AnyObject>,
            "coupon-deleted" : "!1" as Optional<AnyObject>,
            "read-only" : false as Optional<AnyObject>,
            "tables" : [
                "file" : ["id", "url"],
                "coupon" : ["idTilesSummary" : ["id", "name", "description", "packs", "options", "cardCount", "deleted"]],
                "ss_group" : ["id", "name", "users", "deleted"],
                "ss_user" : ["id" : ["id", "first", "last", "userPacks"]],
                "user_pack" : ["pack", "removed", "downloaded"],
                "pack" : ["idTilesSummary" : ["created", "id", "title", "logo"], "actions" : ["status"]]
            ] as Optional<AnyObject>,
            "classes" : ["tiles", "summary"] as Optional<AnyObject>,
            "headers" : ["coupon" : "store"] as Optional<AnyObject>,
            "footers" : user.hasRole("ROLE_ADMIN") ? ["coupon" : true] as Optional<AnyObject> : false as Optional<AnyObject>
        ]) {json in
            self.coupons = (json["results"] as? NSDictionary)?["coupon"] as? NSArray
            
            doMain {
                self.couponsLoaded = true
                self.tableView.reloadData()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return saucyTheme.textSize * saucyTheme.lineHeight * (self.isCart ? 3 : 2)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.coupons == nil || self.coupons!.count == 0 {
            return 1
        }
        return self.isCart ? (AppDelegate.cart.count) : self.coupons!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.couponsLoaded && self.coupons?.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "NoCoupons")!
        }
        else if self.coupons == nil || self.coupons!.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "Loading")!
        }
        
        let cell: CouponCell
        if self.isCart {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cart", for: indexPath) as! CouponCell
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "Store", for: indexPath) as! CouponCell
        }
        
        let object: NSDictionary
        if self.isCart {
            object = self.coupons!.filter({
                let name = ($0 as! NSDictionary)["name"] as! String
                return name == AppDelegate.cart[(indexPath as NSIndexPath).row]
            }).first as! NSDictionary
        }
        else {
            object = self.coupons![(indexPath as NSIndexPath).row] as! NSDictionary
        }
        cell.configure(object)
        return cell
    }
}


