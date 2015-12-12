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

class CardPromptController: UIViewController, AVAudioPlayerDelegate {
    weak var card: Card? = nil
    var player: AVAudioPlayer? = nil
    var url: String? = nil
    var playing: Bool = false

    @IBOutlet weak var content: AutoSizingTextView!
    @IBOutlet weak var listenButton: UIButton!
    
    override func viewDidLoad() {
        self.content.text = self.card!.content
        let ex = try? NSRegularExpression(pattern: "https://.*", options: NSRegularExpressionOptions.CaseInsensitive)
        let match = ex?.firstMatchInString(self.card!.content!, options: [], range:NSMakeRange(0, self.card!.content!.utf8.count))
        let matched = match?.rangeAtIndex(0)
        if matched != nil {
            let range = Range(
                start: self.card!.content!.startIndex.advancedBy(matched!.location),
                end:   self.card!.content!.startIndex.advancedBy(matched!.location + matched!.length))
            self.url = self.card!.content!.substringWithRange(range)
            self.content.text.replaceRange(range, with: "")
            listenButton.hidden = false
        }
    }
    
    func downloadAudio(url: String) {
        if self.playing {
            return
        }
        self.playing = true
        self.listenButton.alpha = 1
        File.save(url, done: {(f:File) in
            let fileName = f.filename!
            let url = NSURL(fileURLWithPath: fileName)
            
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try! AVAudioSession.sharedInstance().setActive(true)
            
            self.player = try? AVAudioPlayer(contentsOfURL: url)
            self.player?.delegate = self
            self.player?.prepareToPlay()
            self.player?.play()
        })
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.playing = false
        self.listenButton.alpha = 0.5
    }

    @IBAction func listenClick(sender: UIButton) {
        
        if (self.url != nil) {
            self.downloadAudio(self.url!)
        }
    }
}