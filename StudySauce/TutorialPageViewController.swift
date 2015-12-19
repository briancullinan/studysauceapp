//
//  ViewController.swift
//  StudySauce
//
//  Created by Stephen Houghton on 12/17/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

class TutorialPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var index = 0
    var pageTitles = ["Take the guesswork out of studying!", "When you study, start here", "Want to study a specific topic?"]
    var pageExplanations = ["Use the leading scientific research to know exactly what and when to study.", "Study Sauce automatically calculates what you need to study and puts it right up front.", "Just select what you want to study in your study pack list."]
    var pageImages = ["light gray head.png", "Walkthrough Big Button.png", "Walkthrough My Packs.png"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        self.dataSource = self
        self.delegate = self
       
        let startVC = self.viewcontrollerAtIndex(0) as TutorialContentViewController
        let viewControllers = [startVC]
        
        self.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {(_: Bool) in })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func viewcontrollerAtIndex(index: Int) -> TutorialContentViewController
    {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Tutorial") as! TutorialContentViewController
        
        vc.imageFile = self.pageImages[index]
        vc.titleText = self.pageTitles[index]
        vc.explanationText = self.pageExplanations[index]
        vc.pageIndex = index
        
        return vc
    }
    
    // Mark: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! TutorialContentViewController
        self.index = vc.pageIndex as Int
        
        if (index == 0 || index == NSNotFound)
        {
            return nil
        }
        
        self.index--
        return self.viewcontrollerAtIndex(self.index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! TutorialContentViewController
        self.index = vc.pageIndex as Int
        
        if (self.index == NSNotFound)
        {
            return nil
        }
        
        self.index++
        
        if (self.index == self.pageTitles.count)
        {
            return nil
        }
        
        return self.viewcontrollerAtIndex(self.index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.index
    }
}
