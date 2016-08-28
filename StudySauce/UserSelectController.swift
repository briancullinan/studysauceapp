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
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex, PKPaymentNetworkDiscover, ""]
    weak var json: NSDictionary? = nil
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        self.studentSelect!.addDoneOnKeyboardWithTarget(self, action: #selector(UserSelectController.textFieldShouldReturn(_:)))
        self.studentSelect!.delegate = self
        self.studentSelect.tintColor = UIColor.clearColor()
        self.studentSelect.inputView = BasicKeyboardController.pickerKeyboard
        BasicKeyboardController.keyboardHeight = 20 * saucyTheme.multiplier() + saucyTheme.padding * 2
        BasicKeyboardController.keyboardSwitch = {
            self.studentSelect.inputView = $0
            self.studentSelect.reloadInputViews()
        }
        let inputAssistantItem = self.studentSelect!.inputAssistantItem
        inputAssistantItem.leadingBarButtonGroups = []
        inputAssistantItem.trailingBarButtonGroups = []
        self.studentSelect.reloadInputViews()
        let price = StoreController.getPrice(self.json!)
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        self.priceLabel!.text = price.isZero ? "Free" : formatter.stringFromNumber(price) ?? ""
        self.titleLabel!.text = self.json!["description"] as? String ?? ""
        self.getUsersFromLocalStore()
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doMain {
            self.placeOrderClick(self.placeOrder!)
        }
        return true
    }
    
    @IBAction func selectStudent(sender: AnyObject) {
        if let picker = (self.studentSelect!.inputView!.viewController() as! BasicKeyboardController).picker {
            picker.dataSource = self
            picker.delegate = self
            picker.reloadAllComponents()
            picker.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    internal func request(request: SKRequest, didFailWithError error: NSError) {
        NSLog(error.description)
    }
    
    internal func productsRequest (request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let count : Int = response.products.count
        if (count>0) {
            var validProducts = response.products
            let validProduct: SKProduct = validProducts[0] as SKProduct
            if validProduct.productIdentifier == (self.json!["options"] as! NSDictionary).allKeys[0] as! String {
                let payment = SKPayment(product: validProduct)
                AppDelegate.storeChild = self.users.filter({$0.first! + " " + $0.last! == self.studentSelect!.text!}).first
                AppDelegate.storeCoupon = self.json!["name"] as? String ?? ""
                SKPaymentQueue.defaultQueue().addPayment(payment)
            }
        }
    }

    @IBAction func placeOrderClick(sender: UIButton) {
        if !self.placeOrder.enabled {
            return
        }
        let child = self.users.filter({$0.first! + " " + $0.last! == self.studentSelect!.text!}).first
        if child == nil {
            self.studentSelect?.becomeFirstResponder()
            return
        }
        else {
            self.studentSelect!.resignFirstResponder()
        }
        self.placeOrder.enabled = false
        let props = self.json!["options"] as! NSDictionary
        let option = props.allKeys[0] as? String ?? ""
        let price = (props[option] as! NSDictionary)["price"] ?? ""
        
        // assign pack instantly because order is free
        if (Double("\(price!)") ?? 0.0).isZero {
            postJson("/checkout/pay", [
                "coupon" : self.json!["name"] as? String ?? "",
                "child" : [self.json!["name"] as? String ?? "" : child!.id!]])
            {_ in
                let store = self.presentingViewController as! StoreController
                self.dismissViewControllerAnimated(true, completion: {
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

    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if row == 0 {
            return
        }
        if self.studentSelect!.isFirstResponder() {
            self.studentSelect!.text = self.users[row-1].first! + " " + self.users[row-1].last!
            AppDelegate.cartChildren[self.json!["name"] as! String] = self.users[row-1].id!
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
 
}