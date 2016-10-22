//
//  UserSelectController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 8/24/16.
//  Copyright © 2016 The Study Institute. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import StoreKit

class UserSelectController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SKProductsRequestDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var studentSelect: TextField!
    @IBOutlet weak var placeOrder: UIButton!
    var returnKeyHandler: IQKeyboardReturnKeyHandler? = nil
    let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex, PKPaymentNetwork.discover, ""] as [Any]
    var json: Dictionary<String,Any>? = nil
    var users: [User] = []
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getUsersFromLocalStore()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        self.studentSelect!.addDoneOnKeyboardWithTarget(self, action: #selector(UserSelectController.textFieldShouldReturn(_:)))
        self.studentSelect!.delegate = self
        self.studentSelect.tintColor = UIColor.clear
        self.studentSelect.inputView = BasicKeyboardController.pickerKeyboard
        BasicKeyboardController.keyboardHeight = 20 * saucyTheme.multiplier() + saucyTheme.padding * 2
        BasicKeyboardController.keyboardSwitch = {
            self.studentSelect.inputView = $0
            self.studentSelect.reloadInputViews()
        }
        self.studentSelect.reloadInputViews()
        let price = StoreController.getPrice(self.json! as NSDictionary)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        self.priceLabel!.text = price.isZero ? "Free" : formatter.string(from: price as NSNumber) ?? ""
        self.titleLabel!.text = self.json!["description"] as? String ?? ""
    }
    
    func getUsersFromLocalStore() {
        AppDelegate.performContext {
            self.users = UserLoginController.filterDomain(AppDelegate.list(User.self))
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doMain {
            self.placeOrderClick(self.placeOrder!)
        }
        return true
    }
    
    @IBAction func selectStudent(_ sender: AnyObject) {
        doMain {
            if let picker = (self.studentSelect!.inputView!.viewController() as! BasicKeyboardController).picker {
                picker.dataSource = self
                picker.delegate = self
                picker.reloadAllComponents()
                self.lastRow = 0
                picker.selectRow(0, inComponent: 0, animated: false)
            }
        }
    }
    
    internal func request(_ request: SKRequest, didFailWithError error: Error) {
        NSLog(error as! String)
    }
    
    internal func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let count : Int = response.products.count
        if (count>0) {
            var validProducts = response.products
            let validProduct: SKProduct = validProducts[0] as SKProduct
            if validProduct.productIdentifier == (self.json!["options"] as! NSDictionary).allKeys[0] as! String {
                let payment = SKPayment(product: validProduct)
                AppDelegate.storeChild = self.users.filter({$0.first! + " " + $0.last! == self.studentSelect!.text!}).first
                AppDelegate.storeCoupon = self.json!["name"] as? String ?? ""
                SKPaymentQueue.default().add(payment)
            }
        }
    }
    
    func done() {
        doMain {
            self.placeOrder.isEnabled = true
            self.placeOrder.alpha = 1
            self.placeOrder.setFontColor(saucyTheme.lightColor)
            self.placeOrder.setBackground(saucyTheme.secondary)
        }
    }

    @IBAction func placeOrderClick(_ sender: UIButton) {
        if !self.placeOrder.isEnabled {
            return
        }
        let child = self.users.filter({$0.first! + " " + $0.last! == self.studentSelect!.text!}).first
        if child == nil {
            self.studentSelect?.becomeFirstResponder()
            return
        }
        else {
            self.studentSelect!.resignFirstResponder()
            self.placeOrder.isEnabled = false
            self.placeOrder.alpha = 0.85
            self.placeOrder.setFontColor(saucyTheme.fontColor)
            self.placeOrder.setBackground(saucyTheme.lightColor)
        }
        self.placeOrder.isEnabled = false
        let props = self.json!["options"] as! NSDictionary
        let option = props.allKeys[0] as? String ?? ""
        let price = (props[option] as! NSDictionary)["price"] ?? ""
        
        // assign pack instantly because order is free
        if (Double("\(price)") ?? 0.0).isZero {
            let coupon = self.json!["name"] as! String
            postJson("/checkout/pay", [
                "coupon" : coupon as Optional<AnyObject>,
                "child" : [coupon : child!.id!] as Optional<AnyObject>
                ],
                error: {code in
                        self.done()
                }, redirect: {(code:String) in
                    self.done()
                })
            {_ in
                self.done()
                let store = self.presentingViewController as! StoreController
                self.dismiss(animated: true, completion: {
                    store.completed = true
                    store.updateCart()
                    store.tableView.reloadData()
                })
            }
        }
        else {
            let productID:NSSet = NSSet(object: option);
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
            productsRequest.delegate = self
            productsRequest.start()
        }

    }

    var lastRow = 0
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if row == 0 {
            lastRow = row
            return
        }
        let user = self.users[row-1]
        let jsonPacks: [[String:Any]] = (self.json!["packs"] as! [[String:Any]])
        var packIds: [NSNumber] = []
        for p in jsonPacks {
            packIds.append(p["id"] as! NSNumber)
        }
        let matching = NSPredicate(format: "id IN %@ AND ANY user_packs.user==%@", packIds, user)
        let packs = AppDelegate.getPredicate(Pack.self, matching)
        let assigned = packs.count > 0
        if assigned {
            doMain {
                pickerView.selectRow(self.lastRow, inComponent: 0, animated: true)
            }
            return
        }
        else {
            lastRow = row
        }
        
        if self.studentSelect!.isFirstResponder {
            self.studentSelect!.text = self.users[row-1].first! + " " + self.users[row-1].last!
            AppDelegate.cartChildren[self.json!["name"] as! String] = self.users[row-1].id!
        }
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.users.count + 1
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Select a student"
        }
        let user = self.users[row-1]
        let jsonPacks: [[String:Any]] = (self.json!["packs"] as! [[String:Any]])
        var packIds: [NSNumber] = []
        for p in jsonPacks {
            packIds.append(p["id"] as! NSNumber)
        }
        let matching = NSPredicate(format: "id IN %@ AND ANY user_packs.user==%@", packIds, user)
        let packs = AppDelegate.getPredicate(Pack.self, matching)
        let assigned = packs.count > 0 ? " (Already assigned)" : ""
        return user.first! + " " + user.last! + assigned
    }
 
}
