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
            self.subview!.didMove(toParentViewController: self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppDelegate.performContext {
            if(AppDelegate.getUser() == nil) {
                return
            }
            let userDefaults = UserDefaults.standard
            var seen = userDefaults.value(forKey: "seen_tutorial") as? String ?? ""
            seen = "\(seen)\(seen != "" ? "," : "")\(AppDelegate.getUser()!.id!)"
            userDefaults.setValue(seen, forKey: "seen_tutorial")
            userDefaults.synchronize() // don't forget this!!!!
        }
    }
    
    @IBAction func skipClick(_ sender: UIButton) {
        AppDelegate.goHome(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transitioningDelegate = CardSegue.transitionManager
        self.page.currentPage = index
        self.subview = self.viewControllerAtIndex(self.index)
        self.subview!.view.translatesAutoresizingMaskIntoConstraints = false
        self.embeddedView.addSubview(self.subview!.view)
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0))
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0))
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.embeddedView.addConstraint(NSLayoutConstraint(item: self.subview!.view, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.embeddedView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
    }
    
    internal func lastClick() {
        if self.index > 0 {
            CardSegue.transitionManager.transitioning = true
            self.subview!.dismiss(animated: true, completion: nil)
        }
    }
    
    internal func nextClick() {
        CardSegue.transitionManager.transitioning = true
        if self.index < self.pageTitles.count - 1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Tutorial") as! TutorialPageViewController
            vc.index = self.index + 1
            self.subview!.present(vc, animated: true, completion: nil)
        }
        else {
            AppDelegate.goHome(self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func viewControllerAtIndex(_ index: Int) -> TutorialContentViewController
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TutorialContent") as! TutorialContentViewController
        
        vc.imageFile = self.pageImages[index]
        vc.titleText = self.pageTitles[index]
        vc.explanationText = self.pageExplanations[index]
        vc.pageIndex = index
        
        return vc
    }
}
