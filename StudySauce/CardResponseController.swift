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
            response!.text = "\(self.card.response!)"
        }
        else {
            let ex = try? NSRegularExpression(pattern: correct!.value!, options: NSRegularExpressionOptions.CaseInsensitive)
            let match = ex?.firstMatchInString(correct!.value!, options: [], range:NSMakeRange(0, correct!.value!.utf16.count))
            let matched = match?.rangeAtIndex(0)
            response!.text = "\(correct!.value!)\n\r\(self.card.response!)"
        }
    }
    
}