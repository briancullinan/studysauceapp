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
    
    @IBOutlet weak var response: AutoSizingTextView!

    override func viewDidLoad() {
        let correct = self.card.getCorrect()
        if correct == nil || correct!.value == nil {
            self.response!.text = "\(self.card.response!)"
        }
        else {
            let ex = try? NSRegularExpression(pattern: correct!.value!, options: NSRegularExpressionOptions.CaseInsensitive)
            let match = ex?.firstMatchInString(correct!.value!, options: [], range:NSMakeRange(0, correct!.value!.utf8.count - 1))
            let matched = match?.rangeAtIndex(0)
            self.response!.text = "\(correct!.value!)\n\r\(self.card.response!)"
        }
        let lines = try? NSRegularExpression(pattern: "\\\\n(\\\\r)?", options: NSRegularExpressionOptions.CaseInsensitive)
        self.response.text = lines!.stringByReplacingMatchesInString(self.response.text!, options: [], range: NSMakeRange(0, self.response.text!.utf8.count - 1), withTemplate: "\n")
    }
    
}