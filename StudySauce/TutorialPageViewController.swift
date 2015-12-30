//
//  ViewController.swift
//  StudySauce
//
//  Created by Stephen Houghton on 12/17/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

class TutorialPageViewController: UIViewController {
    
    @IBOutlet weak var page: UIPageControl!
    var index = 0
    var pageTitles = ["Take the guesswork out of studying!", "When you study, start here", "Want to study a specific topic?"]
    var pageExplanations = ["Use the leading scientific research to know exactly what and when to study.", "Study Sauce automatically calculates what you need to study and puts it right up front.", "Just select what you want to study in your study pack list."]
    var pageImages = ["light gray head.png", "Walkthrough Big Button.png", "Walkthrough My Packs.png"]
    @IBOutlet weak var embeddedView: UIView!
    internal var subview: UIViewController? = nil {
        didSet {
            self.addChildViewController(self.subview!)
            self.subview!.didMoveToParentViewController(self)
        }
    }
    
    @IBAction func skipClick(sender: UIButton) {
        AppDelegate.goHome(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transitioningDelegate = CardSegue.transitionManager
        self.page.currentPage = index
        self.subview = self.viewControllerAtIndex(self.index)
        self.subview!.view.translatesAutoresizingMaskIntoConstraints = false
        self.embeddedView.addSubview(self.subview!.view)
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0))
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }
    
    internal func lastClick() {
        if self.index > 0 {
            CardSegue.transitionManager.transitioning = true
            self.subview!.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    internal func nextClick() {
        CardSegue.transitionManager.transitioning = true
        if self.index < self.pageTitles.count - 1 {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Tutorial") as! TutorialPageViewController
            vc.index = self.index + 1
            self.subview!.presentViewController(vc, animated: true, completion: nil)
        }
        else {
            AppDelegate.goHome(self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func viewControllerAtIndex(index: Int) -> TutorialContentViewController
    {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialContent") as! TutorialContentViewController
        
        vc.imageFile = self.pageImages[index]
        vc.titleText = self.pageTitles[index]
        vc.explanationText = self.pageExplanations[index]
        vc.pageIndex = index
        
        return vc
    }
}
