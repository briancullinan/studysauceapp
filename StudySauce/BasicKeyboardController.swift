//
//  KeyboardViewController.swift
//  CustomKeyboard
//
//  Created by Tope Abayomi on 19/09/2014.
//  Copyright (c) 2014 App Design Vault. All rights reserved.
//

import UIKit

class BasicKeyboardController: UIInputViewController {

    var lowercase = false
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        doMain {
            (self.view ~> UIButton.self).each {
                if $0.tag == 0 {
                    let title = $0.titleForState(.Normal)
                    $0.setTitle(title?.lowercaseString, forState: .Normal)
                }
            }
            self.lowercase = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    override func textWillChange(textInput: UITextInput?) {
        super.textWillChange(textInput)
        // The app is about to change the document's contents. Perform any preparation here.
    }

    override func textDidChange(textInput: UITextInput?) {
        super.textDidChange(textInput)
        // The app has just changed the document's contents, the document context has been updated.
    
    }
    
    @IBAction func didTapButton(sender: UIButton, forEvent event: UIEvent) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        
        if let title = sender.titleForState(.Normal) {
            switch sender.tag {
            case 6 :
                proxy.deleteBackward()
            case 5 :
                proxy.insertText("\n")
            case 2 :
                // toggle case for all keys
                if self.lowercase {
                    (self.view ~> UIButton.self).each {
                        if $0.tag == 0 {
                            let title = $0.titleForState(.Normal)
                            $0.setTitle(title?.uppercaseString, forState: .Normal)
                        }
                    }
                    self.lowercase = false
                }
                else {
                    (self.view ~> UIButton.self).each {
                        if $0.tag == 0 {
                            let title = $0.titleForState(.Normal)
                            $0.setTitle(title?.lowercaseString, forState: .Normal)
                        }
                    }
                    self.lowercase = true
                }
            case 3 :
                proxy.insertText(" ")
            //case "CHG" :
            //    self.advanceToNextInputMode()
            default :
                proxy.insertText(title)
            }
        }
    }
    
}
