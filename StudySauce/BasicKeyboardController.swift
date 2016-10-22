//
//  KeyboardViewController.swift
//  CustomKeyboard
//
//  Created by Tope Abayomi on 19/09/2014.
//  Copyright (c) 2014 App Design Vault. All rights reserved.
//

import UIKit

class BasicKeyboardController: UIInputViewController, UIGestureRecognizerDelegate {

    var lowercase = false {
        didSet {
            if let shift = (self.view ~> (UIButton.self ~* 2)).first {
                AppDelegate.rerenderView(shift)
            }
        }
    }
    
    static var keyboardHeight = CGFloat(0.0)
    @IBOutlet weak var picker: UIPickerView? = nil
 
    static var _basic: BasicKeyboardController? = nil
    static var _basicNumbers: BasicKeyboardController? = nil
    static var _symbols1: BasicKeyboardController? = nil
    static var _symbols2: BasicKeyboardController? = nil
    static var _picker: BasicKeyboardController? = nil
    static var keyboards: UIStoryboard? = nil
    
    static var basicKeyboard : UIView {
        if keyboards == nil {
            keyboards = UIStoryboard(name: "Keyboards", bundle: nil)
        }
        if _basic == nil {
            _basic = keyboards!.instantiateViewController(withIdentifier: "BasicKeyboard") as? BasicKeyboardController
            let height = 4 * saucyTheme.textSize + 8 * saucyTheme.padding
            let size = CGRect(x: 0, y: 0, width: AppDelegate.instance().window!.screen.bounds.width, height: height)
            _basic!.view!.frame = size
            _basic!.view!.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return _basic!.view!
    }
    
    static var symbols1Keyboard : UIView {
        if keyboards == nil {
            keyboards = UIStoryboard(name: "Keyboards", bundle: nil)
        }
        if _symbols1 == nil {
            _symbols1 = keyboards!.instantiateViewController(withIdentifier: "Symbols1Keyboard") as? BasicKeyboardController
            let height = 4 * saucyTheme.textSize + 8 * saucyTheme.padding
            let size = CGRect(x: 0, y: 0, width: AppDelegate.instance().window!.screen.bounds.width, height: height)
            _symbols1!.view!.frame = size
            _symbols1!.view!.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return _symbols1!.view!
    }
    
    static var symbols2Keyboard : UIView {
        if keyboards == nil {
            keyboards = UIStoryboard(name: "Keyboards", bundle: nil)
        }
        if _symbols2 == nil {
            _symbols2 = keyboards!.instantiateViewController(withIdentifier: "Symbols2Keyboard") as? BasicKeyboardController
            let height = 4 * saucyTheme.textSize + 8 * saucyTheme.padding
            let size = CGRect(x: 0, y: 0, width: AppDelegate.instance().window!.screen.bounds.width, height: height)
            _symbols2!.view!.frame = size
            _symbols2!.view!.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return _symbols2!.view!
    }
    
    static var basicNumbersKeyboard : UIView {
        if keyboards == nil {
            keyboards = UIStoryboard(name: "Keyboards", bundle: nil)
        }
        if _basicNumbers == nil {
            _basicNumbers = keyboards!.instantiateViewController(withIdentifier: "NumbersKeyboard") as? BasicKeyboardController
            let height = 4 * saucyTheme.textSize + 8 * saucyTheme.padding
            let size = CGRect(x: 0, y: 0, width: AppDelegate.instance().window!.screen.bounds.width, height: height)
            _basicNumbers!.view!.frame = size
            _basicNumbers!.view!.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return _basicNumbers!.view!
    }
    
    static var pickerKeyboard : UIView {
        if keyboards == nil {
            keyboards = UIStoryboard(name: "Keyboards", bundle: nil)
        }
        if _picker == nil {
            _picker = keyboards!.instantiateViewController(withIdentifier: "EntityPickerKeyboard") as? BasicKeyboardController
            let height = 4 * saucyTheme.textSize + 8 * saucyTheme.padding
            let size = CGRect(x: 0, y: 0, width: AppDelegate.instance().window!.screen.bounds.width, height: height)
            _picker!.view!.frame = size
            _picker!.view!.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return _picker!.view!
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.repeatTimer?.invalidate()
        super.viewWillTransition(to: size, with: coordinator)
        (self.view ~> UIButton.self).each {
            $0.isHighlighted = false
            $0.backgroundColor = saucyTheme.lightColor
            $0.setFontColor(saucyTheme.fontColor)
        }
    }
    
    var pickerData: NSArray? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (self.view ~> UIButton.self).each {
            $0.removeTarget(nil, action: nil, for: .allTouchEvents)
            $0.addTarget(self, action: #selector(BasicKeyboardController.cancelTimer(_:)), for: .touchUpInside)
            $0.addTarget(self, action: #selector(BasicKeyboardController.cancelTimer(_:)), for: .touchUpOutside)
            $0.addTarget(self, action: #selector(BasicKeyboardController.didTapButton(_:)), for: .touchDown)
            $0.isExclusiveTouch = true
        }
        NotificationCenter.default.addObserver(self, selector: #selector(BasicKeyboardController.keyboardWillChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func keyboardWillChange(_ notification: Notification) {
        
        let keyboardFrame: CGRect = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        BasicKeyboardController.keyboardHeight = keyboardFrame.size.height
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let keyboardContainer = self.parent {
            (keyboardContainer.view ~> UIView.self).each{$0.isHidden = true}
        }
        self.goLowercase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(_ textInput: UITextInput?) {
        super.textWillChange(textInput)
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        // The app has just changed the document's contents, the document context has been updated.
    
    }
    
    static var keyboardSwitch: ((UIView) -> Void)? = nil
    var repeatTimer: Timer? = nil
    
    @IBAction func cancelTimer(_ sender: UIButton) {
        self.repeatTimer?.invalidate()
        /*
        if sender.tag != 2 {
            let proxy = self.textDocumentProxy as UITextDocumentProxy
            if proxy.hasText() {
                self.repeatTitle = self.repeatTitle.lowercaseString
                self.goLowercase()
            }
            else {
                self.repeatTitle = self.repeatTitle.uppercaseString
                self.goUppercase()
            }
        }
        */
    }
    
    func repeatText() {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        proxy.insertText(repeatTitle)
        self.repeatTimer?.invalidate()
        self.repeatTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BasicKeyboardController.repeatText), userInfo: nil, repeats: false)
    }
    
    func repeatDelete() {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        proxy.deleteBackward()
        self.repeatTimer?.invalidate()
        self.repeatTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BasicKeyboardController.repeatDelete), userInfo: nil, repeats: false)
    }

    var repeatTitle = ""
    
    func goUppercase() {
        (self.view ~> UIButton.self).each {
            if $0.tag == 0 {
                let title = $0.title(for: UIControlState())
                $0.setTitle(title?.uppercased(), for: UIControlState())
            }
        }
        self.lowercase = false
    }
    
    func goLowercase() {
        (self.view ~> UIButton.self).each {
            if $0.tag == 0 {
                let title = $0.title(for: UIControlState())
                $0.setTitle(title?.lowercased(), for: UIControlState())
            }
        }
        self.lowercase = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let keyboardContainer = self.parent {
            (keyboardContainer.view ~> UIView.self).each{$0.isHidden = true}
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let keyboardContainer = self.parent {
            (keyboardContainer.view ~> UIView.self).each{$0.isHidden = false}
        }
        
        self.picker?.reloadAllComponents()
        self.picker?.selectRow(0, inComponent: 0, animated: false)
    }

    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        
        if parent != nil {
            (parent!.view ~> UIView.self).each {$0.isHidden = true}
        }
    }
        
    @IBAction func didTapButton(_ sender: UIButton) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        self.repeatTimer?.invalidate()
        
        if let title = sender.title(for: UIControlState()) {
            switch sender.tag {
            case 6 :
                proxy.deleteBackward()
                self.repeatTitle = ""
                self.repeatTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(BasicKeyboardController.repeatDelete), userInfo: nil, repeats: false)
            case 7 :
                BasicKeyboardController.keyboardSwitch?(BasicKeyboardController.symbols1Keyboard)
            case 8 :
                BasicKeyboardController.keyboardSwitch?(BasicKeyboardController.basicKeyboard)
            case 9 :
                BasicKeyboardController.keyboardSwitch?(BasicKeyboardController.symbols2Keyboard)
            case 5 :
                proxy.insertText("\n")
            case 2 :
                // toggle case for all keys
                if self.lowercase {
                    self.goUppercase()
                }
                else {
                    self.goLowercase()
                }
            case 3 :
                proxy.insertText(" ")
                self.repeatTitle = " "
                self.repeatTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(BasicKeyboardController.repeatText), userInfo: nil, repeats: false)
            //case "CHG" :
            //    self.advanceToNextInputMode()
            default :
                proxy.insertText(title)
                self.repeatTitle = title
                self.repeatTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(BasicKeyboardController.repeatText), userInfo: nil, repeats: false)

            }
        }
        
        // TODO: capitalize based on proxy.autocapitalizationType
        if sender.tag != 2 {
            self.goLowercase()
            self.repeatTitle = self.repeatTitle.lowercased()
        }
        /*
            if proxy.hasText() {
                self.repeatTitle = self.repeatTitle.lowercaseString
                self.goLowercase()
            }
            else {
                self.repeatTitle = self.repeatTitle.uppercaseString
                self.goUppercase()
            }
        }
        */
    }
}
