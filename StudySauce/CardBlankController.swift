//
//  CardPromptController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/23/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import IQKeyboardManagerSwift

class CardBlankController: UIViewController, UITextFieldDelegate {
    
    weak var card: Card? = nil
    var returnKeyHandler: IQKeyboardReturnKeyHandler? = nil
    var answered = false
    
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var verticalSpace: NSLayoutConstraint!
    @IBOutlet weak var rightMargin: NSLayoutConstraint!
    
    @IBOutlet weak var horizontalSpace: NSLayoutConstraint!
    @IBOutlet weak var alignCenter: NSLayoutConstraint!
    @IBOutlet weak var equalWidths: NSLayoutConstraint!
    
    @IBOutlet weak var bottomHalf: NSLayoutConstraint!
    
    @IBOutlet weak var inputText: UITextField!
    
    @IBAction func returnToBlank(_ segue: UIStoryboardSegue) {
        
    }
    
    override var canBecomeFirstResponder : Bool {
        return !answered && !CardSegue.transitionManager.transitioning
    }
    
    func updateConstraints() {
        if let vc = self.childViewControllers.filter({$0 is CardPromptController}).first as? CardPromptController , !vc.isImage
            && UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft || UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeRight {
                self.rightMargin.isActive = false
                self.verticalSpace.isActive = false
                self.leftMargin.isActive = false
                
                self.horizontalSpace.isActive = true
                self.alignCenter.isActive = true
                self.equalWidths.isActive = true
                self.bottomHalf.constant = BasicKeyboardController.keyboardHeight - saucyTheme.padding * 3
        }
        else {
            self.horizontalSpace.isActive = false
            self.alignCenter.isActive = false
            self.equalWidths.isActive = false
            
            self.rightMargin.isActive = true
            self.verticalSpace.isActive = true
            self.leftMargin.isActive = true
            
            self.bottomHalf.constant = BasicKeyboardController.keyboardHeight + 20 * saucyTheme.multiplier() + saucyTheme.padding * 2
        }
        self.view.setNeedsLayout()
    }
    
    override func viewDidLayoutSubviews() {
        self.updateConstraints()

        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.inputText.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let vc = self.childViewControllers.filter({$0 is CardPromptController}).first as? CardPromptController , !vc.isImage && !CardSegue.reassignment {
            self.inputText!.becomeFirstResponder()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let pvc = self.parent as? CardController {
            self.card = pvc.card
            if let vc = segue.destination as? CardPromptController {
                vc.card = self.card
                vc.parentVC = self
            }
            if let vc = segue.destination as? CardResponseController {
                vc.card = self.card
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc = self.parent as? CardController {
            self.card = vc.card
            IQKeyboardManager.sharedManager().enable = false
            IQKeyboardManager.sharedManager().enableAutoToolbar = false
            
            //Adding done button for textField
            returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
            self.inputText.addDoneOnKeyboardWithTarget(self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
            self.inputText.delegate = self
            
            let keyboard = self.card?.pack?.getProperty("keyboard") as? String
            if keyboard == "default" {
                self.inputText.keyboardType = UIKeyboardType.default
            }
            else if keyboard == "decimal" {
                self.inputText.keyboardType = UIKeyboardType.decimalPad
            }
            else if keyboard == "ascii" {
                self.inputText.keyboardType = UIKeyboardType.asciiCapable
            }
            else if keyboard == "alphabet" {
                self.inputText.keyboardType = UIKeyboardType.alphabet
            }
            else {
                // use basic keyboard
                let inputAssistantItem = self.inputText!.inputAssistantItem
                inputAssistantItem.leadingBarButtonGroups = []
                inputAssistantItem.trailingBarButtonGroups = []
                if keyboard == "number" || keyboard == "phone" {
                    self.inputText.inputView = BasicKeyboardController.basicNumbersKeyboard
                }
                else {
                    self.inputText.inputView = BasicKeyboardController.basicKeyboard
                }
                BasicKeyboardController._basic?.goLowercase()
                BasicKeyboardController.keyboardHeight = 20 * saucyTheme.multiplier() + saucyTheme.padding * 2
                BasicKeyboardController.keyboardSwitch = {
                    self.inputText.inputView = $0
                    self.inputText.reloadInputViews()
                }
                self.inputText.inputAccessoryView = UIView()
                self.inputText.reloadInputViews()
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(CardBlankController.updateConstraints), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.answered = true
        // TODO: check for correctness and continue
        self.saveResponse(self.inputText.text!)
        return true
    }
    
    func saveResponse(_ value: String) {
        if let vc = self.parent as? CardController {
            AppDelegate.performContext {
                let newResponse = AppDelegate.insert(Response.self)
                let answer = self.card!.getCorrect()
                newResponse.answer = answer
                let pattern = answer!.value!
                let ex = try? NSRegularExpression(pattern: pattern, options: [NSRegularExpression.Options.caseInsensitive])
                let match = ex?.firstMatch(in: value, options: [], range:NSMakeRange(0, value.characters.count))
                newResponse.correct = match != nil ? 1 : 0
                newResponse.value = value
                newResponse.card = self.card
                newResponse.created = Date()
                newResponse.user = AppDelegate.getUser()
                AppDelegate.saveContext()
                // store intermediate and don't call this until after the correct answer is shown
                vc.intermediateResponse = newResponse.correct == 1
                doMain {
                    self.performSegue(withIdentifier: "correct", sender: self)
                }
                HomeController.syncResponses(self.card!.pack!)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.inputText?.becomeFirstResponder()
    }
}
