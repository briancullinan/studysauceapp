//
//  CardResponseController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 12/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class CardResponseController : UIViewController {
    weak var card: Card!
    
    @IBOutlet weak var response: UITextView!

    override func viewDidLoad() {
        let correct = self.card.getCorrect()
        if correct == nil || correct!.value == nil {
            self.response!.text = "\(self.card.response!)"
        }
        else {
            self.response!.text = "\(correct!.value!)\n\r\(self.card.response!)"
        }
        let lines = try? NSRegularExpression(pattern: "\\\\n(\\\\r)?", options: NSRegularExpressionOptions.CaseInsensitive)
        self.response.text = lines!.stringByReplacingMatchesInString(self.response.text!, options: [], range: NSMakeRange(0, self.response.text!.characters.count), withTemplate: "\n")
    }
    
}