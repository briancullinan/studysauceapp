//
//  TQuery.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

private var queryList: [UIView -> Void] = []

enum T<B: UIView> {
    
    static func device(d: String) -> (v: B) -> Bool {
        return {(_: B) -> Bool in
            let ex = try? NSRegularExpression(pattern: d, options: NSRegularExpressionOptions.CaseInsensitive)
            let current = UIDevice.currentDevice().systemName
            let match = ex?.firstMatchInString(current, options: [], range:NSMakeRange(0, current.characters.count))
            let matched = match?.rangeAtIndex(0)
            return matched != nil
        }
    }
    
    static func orientation(d: String) -> (v: B) -> Bool {
        return {(_: B) -> Bool in
            if d.lowercaseString == "landscape" && (UIApplication.sharedApplication().statusBarOrientation == .LandscapeLeft ||
                UIApplication.sharedApplication().statusBarOrientation == .LandscapeRight) {
                    return true
            }
            if d.lowercaseString == "portrait" && (UIApplication.sharedApplication().statusBarOrientation == .PortraitUpsideDown ||
                UIApplication.sharedApplication().statusBarOrientation == .Portrait) {
                    return true
            }
            if d.lowercaseString == "landscapeleft" && UIApplication.sharedApplication().statusBarOrientation == .LandscapeLeft {
                    return true
            }
            if d.lowercaseString == "landscaperight" && UIApplication.sharedApplication().statusBarOrientation == .LandscapeRight {
                return true
            }
            if d.lowercaseString == "portrait" && UIApplication.sharedApplication().statusBarOrientation == .Portrait {
                return true
            }
            if d.lowercaseString == "portraitupsidedown" && UIApplication.sharedApplication().statusBarOrientation == .PortraitUpsideDown {
                return true
            }
            return false
        }
    }
    
    static func orientation(d: UIInterfaceOrientation) -> (v: B) -> Bool {
        return {(_: B) -> Bool in
            return UIApplication.sharedApplication().statusBarOrientation == d
        }
    }

}


extension UIView {
    
    func setAppearanceFunc(_: String) {
        for q in queryList {
            q(self)
        }
    }
    
}

class TAppearance<B: UIView> {
    
    init(_ q: TQueryable<B>) {
        self.q = q
    }
    
    var q: TQueryable<B>
    
    func appearence(b: B -> Void) {
        let i = queryList.count
        queryList.append({
            if self.q.matches($0) {
                b($0 as! B)
            }
        })
        if i == 0 {
            UIView.appearance().setAppearanceFunc("")
        }
    }
}

protocol IQueryable {
    func matches(view: AnyObject) -> Bool
}

class TQueryable<B: AnyObject>: NSObject, IQueryable {
    
    func matches(view: AnyObject) -> Bool {
        if view.isKindOfClass(self.b) {
            return true
        }
        return false
    }
    
    var b: B.Type
        
    required init(_ b: B.Type) {
        self.b = b
    }
    
    override var description: String {
        get {
            return "object is \(self.b)"
        }
    }
}

class TSibling<B: UIView>: TQueryable<B> {
    var q: IQueryable
    
    init(_ query: IQueryable, _ b: B.Type) {
        self.q = query
        super.init(b)
    }
    
    override func matches(view: AnyObject) -> Bool {
        if let v = view as? UIView {
            return self.matchesView(v)
        }
        return false
    }
    
    func enumerate(view: UIView) -> [B] {
        var result: [B] = []
        if let parent = view.superview {
            let siblings = parent.subviews
            for s in siblings {
                if self.q.matches(s) {
                    result.append(s as! B)
                }
            }
        }
        return result
    }
    
    func matchesView(view: UIView) -> Bool {
        // first check to make sure view is of correct type
        if let parent = view.superview where super.matches(view) {
            let siblings = parent.subviews
            for s in siblings {
                if self.q.matches(s) {
                    return true
                }
            }
        }
        return false
    }
    
    override var description: String {
        get {
            return "sibling matches \(self.q)"
        }
    }
}

class TChild<B: UIView>: TQueryable<B> {
    var q: IQueryable
    
    init(_ query: IQueryable, _ b: B.Type) {
        self.q = query
        super.init(b)
    }
    
    private func getVC(view: UIView) -> UIViewController? {
        var nextResponder: UIResponder? = view.nextResponder()
        while nextResponder != nil {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            nextResponder = nextResponder?.nextResponder()
        }
        return nil
    }
    
    func enumerate(view: UIView) -> [B] {
        var result: [B] = []
        let children = view.subviews
        for s in children {
            if self.q.matches(s) {
                result.append(s as! B)
            }
            result.appendContentsOf(self.enumerate(s))
        }
        return result
    }
    
    override func matches(view: AnyObject) -> Bool {
        if let v = view as? UIView {
            return self.matchesView(v)
        }
        return false
    }
    
    func matchesView(view: UIView) -> Bool {
        // first check to make sure view is of correct type
        if super.matches(view) {
            // self.a can be a view controller type or another view type
            if self.getVC(view) != nil && self.q.matches(self.getVC(view)!) {
                return true
            }
            else {
                var parent = view
                while parent.superview != nil {
                    parent = parent.superview!
                    if self.q.matches(parent) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    
    override var description: String {
        get {
            return "child of \(self.q)"
        }
    }

}

class TImmediateChild<B: UIView>: TQueryable<B> {
    var q: IQueryable
    
    init(_ query: IQueryable, _ b: B.Type) {
        self.q = query
        super.init(b)
    }
    
    override func matches(view: AnyObject) -> Bool {
        if let v = view as? UIView {
            return self.matchesView(v)
        }
        return false
    }
    
    func matchesView(view: AnyObject) -> Bool {
        // first check to make sure view is of correct type
        if super.matches(view) {
            // self.a can be a view controller type or another view type
            if view.nextResponder() != nil && (self.q.matches(view.nextResponder()!) ||
                view.nextResponder()!.nextResponder() != nil && self.q.matches(view.nextResponder()!.nextResponder()!)) {
                return true
            }
            else if let parent = view.superview where parent != nil {
                if self.q.matches(parent!) {
                    return true
                }
            }
        }
        return false
    }
    
    override var description: String {
        get {
            return "immediate child of \(self.q)"
        }
    }
}


class TMatching<B: AnyObject>: TQueryable<B> {
    var q: IQueryable
    
    init(_ query: IQueryable, _ matches: B -> Bool) {
        self.matching = matches
        self.q = query
        super.init(B.self)
    }
    
    var matching: (B) -> Bool
    
    override func matches(view: AnyObject) -> Bool {
        if super.matches(view) {
            if self.matching(view as! B) && self.q.matches(view) {
                return true
            }
        }
        return false
    }
    
    override var description: String {
        get {
            return "matches \(self.matching) and \(self.q)"
        }
    }
}

class TCombination<B: UIView> :TQueryable<B> {
    
    init(queries: [IQueryable]) {
        self.queries = queries
        super.init(B.self)
    }
    
    var queries: [IQueryable]
    
    override func matches(view: AnyObject) -> Bool {
        if super.matches(view) {
            let match = self.queries.filter({
                return $0.matches(view)
            })
            if match.count > 0 {
                return true
            }
        }
        return false
    }
    
    override var description: String {
        get {
            let queries = self.queries.map({"\($0)"}).joinWithSeparator(" or ")
            return "any of \(queries)"
        }
    }
}

