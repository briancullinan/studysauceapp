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
import QuartzCore

class CardPromptController: UIViewController, AVAudioPlayerDelegate, UIScrollViewDelegate {
    weak var card: Card? = nil
    var player: AVAudioPlayer? = nil
    var url: String? = nil
    var playing: Bool = false
    var timer: NSTimer? = nil

    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var left: NSLayoutConstraint!
    @IBOutlet weak var content: UITextView!
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var playButton: DALabeledCircularProgressView!
    @IBOutlet weak var size: NSLayoutConstraint!
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        doMain(self.updateListenPosition)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.updateListenPosition()
    }
    
    func getAttributedText(content: NSString) -> NSAttributedString {
        // align listen button to substring
        let wholeRange = NSMakeRange(0, content.length)
        let range = content.rangeOfString("p14y", options: [], range: wholeRange)
        
        // set the listen text to clear
        let attr = NSMutableAttributedString(string: content as String)
        
        attr.addAttribute(NSFontAttributeName, value: self.content.font!, range: wholeRange)
        attr.addAttribute(NSForegroundColorAttributeName, value: self.content!.textColor!, range: wholeRange)
        
        // center itß
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .Center
        attr.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: wholeRange)
        
        attr.addAttribute(NSFontAttributeName, value: UIFont(name: self.content!.font!.fontName, size: 50.0 * saucyTheme.multiplier())!, range: range)
        attr.addAttribute(NSForegroundColorAttributeName, value: UIColor.clearColor(), range: range)
        
        return attr
    }
    
    func updateListenPosition() {
        if self.listenButton.hidden == false {
            self.content.attributedText = self.getAttributedText(self.content.text)
            let text = self.content.attributedText.string as NSString
            let wholeRange = NSMakeRange(0, self.content.attributedText.length)
            let range = text.rangeOfString("p14y", options: [], range: wholeRange)
            
            self.content.layoutManager.ensureLayoutForTextContainer(self.content.textContainer)
            let start = self.content.positionFromPosition(self.content.beginningOfDocument, offset: range.location)!
            // text position of the end of the range
            let end = self.content.positionFromPosition(start, offset: range.length)!
            
            // text range of the range
            let tRange = self.content.textRangeFromPosition(start, toPosition: end)
            let position = self.content.firstRectForRange(tRange!)
            let globalPoint = self.content.convertPoint(position.origin, toView: self.view)
            self.size.constant = position.height
            self.top.constant = globalPoint.y + ((position.height - self.size.constant) / 2)
            self.left.constant = globalPoint.x + ((position.width - self.size.constant) / 2)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateListenPosition()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var content = self.card!.content
        
        // replace new line characters with real lines
        let lines = try? NSRegularExpression(pattern: "\\\\n(\\\\r)?", options: NSRegularExpressionOptions.CaseInsensitive)
        content = lines?.stringByReplacingMatchesInString(content!, options: [], range: NSMakeRange(0, content!.characters.count), withTemplate: "\n")

        
        // find the hyperlink and replace it with a listen button
        let ex = try? NSRegularExpression(pattern: "https://.*", options: NSRegularExpressionOptions.CaseInsensitive)
        let match = ex?.firstMatchInString(content!, options: [], range:NSMakeRange(0, content!.characters.count))
        let matched = match?.rangeAtIndex(0)
        if matched != nil {
            let range = Range(
                start: self.card!.content!.startIndex.advancedBy(matched!.location),
                end:   self.card!.content!.startIndex.advancedBy(matched!.location + matched!.length))
            self.url = self.card!.content!.substringWithRange(range)
            content!.replaceRange(range, with: "p14y")
            self.listenButton.hidden = false
            self.playButton.hidden = false
            self.content.scrollEnabled = false
            self.content.scrollEnabled = true
        }
        self.content.text = content

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
            
            if self.player == nil {
                self.player = try? AVAudioPlayer(contentsOfURL: url)
                self.player?.delegate = self
                self.player?.prepareToPlay()
            }
            self.player!.play()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
        })
    }
    
    func updateProgress() {
        self.playButton.setProgress(CGFloat(self.player!.currentTime) / CGFloat(self.player!.duration), animated: false)
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.playing = false
        self.listenButton.alpha = 0.5
        self.timer?.invalidate()
        self.timer = nil
        self.playButton.setProgress(0, animated: false)
    }

    @IBAction func listenClick(sender: UIButton) {
        
        if (self.url != nil) {
            self.downloadAudio(self.url!)
        }
    }
}