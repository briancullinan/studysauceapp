//
//  CardPromptController.swift
//  StudySauce
//
//  Created by Brian Cullinan on 12/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import AVFoundation

class CardPromptController: UIViewController {
    weak var card: Card? = nil
    var player: AVAudioPlayer? = nil

    @IBOutlet weak var content: AutoSizingTextView!
    
    override func viewDidLoad() {
        content!.text = self.card!.content
    }
    
    func downloadAudio(url: String) {
        File.save(url, done: {(f:File) in
            let fileName = f.filename!
            let url = NSURL(fileURLWithPath: fileName)
            
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try! AVAudioSession.sharedInstance().setActive(true)
            
            self.player = try! AVAudioPlayer(contentsOfURL: url)
            self.player?.prepareToPlay()
            self.player?.play()
        })
    }

    @IBAction func listenClick(sender: UIButton) {
        
        if (self.card!.content != nil) {
            let ex = try? NSRegularExpression(pattern: "https://.*", options: NSRegularExpressionOptions.CaseInsensitive)
            let match = ex?.firstMatchInString(self.card!.content!, options: [], range:NSMakeRange(0, self.card!.content!.utf8.count))
            let matched = match?.rangeAtIndex(0)
            if matched != nil {
                let url = self.card!.content!.substringWithRange(Range(start: self.card!.content!.startIndex.advancedBy(matched!.location), end: self.card!.content!.startIndex.advancedBy(matched!.location + matched!.length)))
                self.downloadAudio(url)
            }
        }
    }
}