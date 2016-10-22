//
//  UserAddController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 12/21/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

class UserAddController : UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    internal var childFirstName: String?
    internal var childLastName: String?
    internal var child: Bool?
    internal var code: String?
    internal var token: String?
    var returnKeyHandler: IQKeyboardReturnKeyHandler? = nil
    @IBOutlet weak var childFirst: UITextField!
    @IBOutlet weak var childLast: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var schoolSystem: TextField!
    @IBOutlet weak var schoolYear: TextField!
    @IBOutlet weak var schoolName: TextField!
    @IBOutlet weak var childSwitch: UISwitch!
    
    
    @IBAction func lastClick(_ sender: UIButton) {
        CardSegue.transitionManager.transitioning = true
        if self.presentingViewController is UserRegisterController {
            self.presentingViewController?.dismiss(animated: true, completion: {
                AppDelegate.goHome(self.presentingViewController, true) {_ in

                }
            })
        }
        else {
            UserLoginController.home {
                self.performSegue(withIdentifier: "home", sender: sender)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getInvitesFromRemoteStore()
    }
    
    @IBAction func switchClick(_ sender: UIButton) {
        self.childSwitch.setOn(!self.childSwitch.isOn, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.childFirst!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.childFirst!.delegate = self
        self.childLast!.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.childLast!.delegate = self
        self.schoolSystem.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.schoolSystem.delegate = self
        self.schoolYear.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.schoolYear.delegate = self
        self.schoolName.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        self.schoolName.delegate = self
        
        //IQKeyboardManager.sharedManager().enable = false
        //IQKeyboardManager.sharedManager().preventShowingBottomBlankSpace = true
        //IQKeyboardManager.sharedManager().enableAutoToolbar = false
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        
        self.assignSelectKeyboard(self.schoolSystem)
        self.assignSelectKeyboard(self.schoolYear)
        self.assignSelectKeyboard(self.schoolName)
        NotificationCenter.default.addObserver(self, selector: #selector(UserAddController.reshowKeyboard), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        //NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.getInvitesFromRemoteStore), userInfo: nil, repeats: false)
    }
    
    var invites: [NSDictionary] = []
    var level1: [NSDictionary] = []
    var level2: [NSDictionary] = []
    var level3: [NSDictionary] = []
    
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if row == 0 {
            return
        }
        (self.view ~> TextField.self).each {
            if $0.isFirstResponder {
                let option = self.getOptions($0)[row-1]["name"] as? String
                if option != $0.text {
                    $0.text = option
                    if $0 == self.schoolSystem {
                        self.schoolYear.text = ""
                        self.schoolName.text = ""
                    }
                    if $0 == self.schoolYear {
                        self.schoolName.text = ""
                    }
                }
            }
        }
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count = 1
        (self.view ~> TextField.self).each {
            if $0.isFirstResponder {
                count = self.getOptions($0).count + 1
            }
        }
        return count
    }
    
    @IBAction func selectStudent(_ sender: TextField) {
        doMain {
            if let picker = (sender.inputView!.viewController() as! BasicKeyboardController).picker {
                picker.dataSource = self
                picker.delegate = self
                picker.reloadAllComponents()
                picker.selectRow(0, inComponent: 0, animated: false)
            }
        }
    }

    func getOptions(_ field: TextField) -> [NSDictionary] {
        if field == self.schoolSystem {
            var top = self.level3
            if !top.contains(where: {$0["name"] as! String == "Other"}) {
                top.append(["name" : "Other"])
            }
            return top
        }
        else if field == self.schoolYear {
            let system = (self.level3.filter({$0["name"] as? String == self.schoolSystem.text}).first)?["name"] as? String
            return self.level2.filter({
                let parent = ($0["parent"] as? NSDictionary)?["name"] as? String
                return parent == system || (parent == nil && system == "Other")
            })
        }
        else if field == self.schoolName {
            let year = (self.level2.filter({$0["name"] as? String == self.schoolYear.text}).first)?["name"] as? String
            return self.level1.filter({($0["parent"] as? NSDictionary)?["name"] as? String == year})
        }
        return []
    }
    
    // The data to return for the row and component (column) that"s being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var text = ""
        (self.view ~> TextField.self).each {
            if $0.isFirstResponder {
                if row == 0 {
                    if $0 == self.schoolSystem {
                        text = "Select a school system"
                    }
                    else if $0 == self.schoolYear {
                        text = "Select a school year"
                    }
                    else if $0 == self.schoolName {
                        text = "Select a school"
                    }
                }
                else {
                    text = self.getOptions($0)[row-1]["name"] as! String
                }
            }
        }
        return text
    }
    
    var isHiding = false
    func reshowKeyboard() {
        doMain {
            if self.switched != nil {
                let switchTo = self.switched!
                self.switched = nil
                switchTo.becomeFirstResponder()
            }
            UIView.setAnimationsEnabled(true)
            self.isHiding = false
        }
    }
    
    open func getInvitesFromRemoteStore() {
        let user = AppDelegate.getUser()!
        getJson("/command/results", [
        "count-invite" : 1 as Optional<AnyObject>,
        "count-ss_user" : -1 as Optional<AnyObject>,
        "invite-1count-invite" : 0 as Optional<AnyObject>,
        "invite-1new" : false as Optional<AnyObject>,
        "invite-1invite-properties" : "s:13:\"public_school\";b:1;" as Optional<AnyObject>,
        "invite-1ss_group-id" : "!NULL" as Optional<AnyObject>,
        "invite-1ss_group-deleted" : "!1" as Optional<AnyObject>,
        "invite-1parent-ss_group-deleted" : "!1" as Optional<AnyObject>,
        "count-ss_group" : -1 as Optional<AnyObject>,
        "new" : ["invite"] as Optional<AnyObject>,
        "edit" : false as Optional<AnyObject>,
        "read-only" : false as Optional<AnyObject>,
        "tables" : [
            "invite" : ["idSingleCoupon" : ["id", "first", "last", "user", "invitee", "email", "group", "code"]],
            "ss_user" : ["id" : ["id", "first", "last", "groups"]],
            "invite-1" : ["id" : ["id", "code", "group", "properties"]],
            "ss_group" : ["id" : ["name", "id", "parent", "deleted"]],
        ] as Optional<AnyObject>,
        "classes" : [] as Optional<AnyObject>,
        "headers" : false as Optional<AnyObject>,
        "footers" : false as Optional<AnyObject>,
        ]) {json in
            self.invites = ((json["results"] as? NSDictionary)?["invite-1"] as! NSArray).map({$0 as! NSDictionary})
            self.level1 = self.invites.map({$0["group"] as! NSDictionary})
            self.level1 = sinq(self.level1).distinct({$0["name"] as! String == $1["name"] as! String}).toArray()
            self.level2 = self.level1.map({$0["parent"] as! NSDictionary})
            self.level2 = sinq(self.level2).distinct({$0["name"] as! String == $1["name"] as! String}).toArray()
            self.level3 = self.level2.map({$0["parent"] as? NSDictionary}).filter({$0 != nil}).map{$0!}
            self.level3 = sinq(self.level3).distinct({$0["name"] as! String == $1["name"] as! String}).toArray()
            doMain {
                (BasicKeyboardController.pickerKeyboard.viewController() as! BasicKeyboardController).picker!.reloadAllComponents()
                (BasicKeyboardController.pickerKeyboard.viewController() as! BasicKeyboardController).picker!.selectRow(0, inComponent: 0, animated: false)
            }
        }
    }

    var switched: UITextField? = nil
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return !isHiding
    }
    
    @IBAction func textFieldDidBeginEditing(_ textField: UITextField) {
        doMain {
            if self.isHiding {
                self.resignAllResponders()
            }
            self.switched = textField
        }
    }
    
    @IBAction func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.schoolSystem || textField == self.schoolYear || textField == self.schoolName {
            UIView.setAnimationsEnabled(false)
            isHiding = true
            doMain {
                self.resignAllResponders()
            }
        }
        else {
            self.switched = nil
        }
    }
    
    func assignSelectKeyboard(_ input: TextField) {
        input.tintColor = UIColor.clear
        input.inputView = BasicKeyboardController.pickerKeyboard
        BasicKeyboardController.keyboardHeight = 20 * saucyTheme.multiplier() + saucyTheme.padding * 2
        BasicKeyboardController.keyboardSwitch = {
            input.inputView = $0
            input.reloadInputViews()
        }
        input.reloadInputViews()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doMain {
            self.addClick(self.addButton)
        }
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.resignAllResponders()
    }
    
    func done() {
        doMain {
            self.addButton.isEnabled = true
            self.addButton.alpha = 1
            self.addButton.setFontColor(saucyTheme.lightColor)
            self.addButton.setBackground(saucyTheme.secondary)
        }
    }

    @IBAction func addClick(_ sender: UIButton) {
        self.resignAllResponders()
        self.childFirstName = self.childFirst.text
        self.childLastName = self.childLast.text
        self.child = self.childSwitch.isOn
        self.code = self.invites.filter({($0["group"] as? NSDictionary)?["name"] as? String == self.schoolName.text}).first?["code"] as? String ?? ""
        if self.childFirstName != "" && self.childLastName != "" && self.code != "" {
            let registrationInfo: Dictionary<String,AnyObject?> = [
                "csrf_token" : self.token as Optional<AnyObject>,
                "hasChild" : self.child == true ? "true" as Optional<AnyObject> : "false" as Optional<AnyObject>,
                "childFirst" : self.childFirstName as Optional<AnyObject>,
                "childLast" : self.childLastName as Optional<AnyObject>,
                "_code" : self.code as Optional<AnyObject>
            ]
            doMain {
                self.addButton.isEnabled = false
                self.addButton.alpha = 0.85
                self.addButton.setFontColor(saucyTheme.fontColor)
                self.addButton.setBackground(saucyTheme.lightColor)
            }
            self.showNoConnectionDialog {
                postJson("/account/create", registrationInfo,
                    error: {code in
                    self.done()
                    if code == 404 {
                        self.showDialog(NSLocalizedString("Invite code not found", comment: "Message for invite code not found when adding a child user"), NSLocalizedString("Try again", comment: "Try again button for adding a child when invite code is not found"))
                    }
                    }, redirect: {(path: String) in
                        self.done()
                        // TODO: add a message here
                        if path == "/register/child" {
                            doMain {
                                self.childFirst.text = ""
                                self.childLast.text = ""
                                self.schoolSystem.text = ""
                                self.schoolName.text = ""
                                self.schoolYear.text = ""
                            }
                        }
                    if path == "/home" {
                        UserLoginController.home { () -> Void in
                            AppDelegate.performContext {
                                let newUser = AppDelegate.list(User.self).filter({$0.created != nil }).max {(x, y) in
                                    return x.created! <= y.created!
                                }
                                AppDelegate.instance().user = newUser
                                doMain {
                                    let last = self.presentingViewController
                                    last?.dismiss(animated: true, completion: {
                                        AppDelegate.goHome(last)
                                    })
                                }
                            }
                        }
                    }
                    }) {_ in
                        self.done()
                }
            }
        }
    }
}
