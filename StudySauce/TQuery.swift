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
    
    case first
    case firstOfType
    case last
    case lastOfType
    
    static func nthChild(i: Int) -> (v: B) -> Bool {
        return {(v: B) -> Bool in
            let ofTypes = v.superview!.subviews
            if i < 0 {
                return v.superview != nil && ofTypes.indexOf(v) == ofTypes.count - i
            }
            return v.superview != nil && ofTypes.indexOf(v) == i
        }
    }
    
    static func nthOfType(i: Int) -> (v: B) -> Bool {
        return {(v: B) -> Bool in
            let ofTypes = v.superview!.subviews.filter({return $0 is B})
            if i < 0 {
                return v.superview != nil && ofTypes.indexOf(v) == ofTypes.count - i
            }
            return v.superview != nil && ofTypes.indexOf(v) == i
        }
    }
    
    static func device(d: String) -> TQueryable<B> {
        return TQueryable(B) ~* {(_: B) -> Bool in
            let ex = try? NSRegularExpression(pattern: d, options: NSRegularExpressionOptions.CaseInsensitive)
            let match = ex?.firstMatchInString(UIDevice.currentDevice().name, options: [], range:NSMakeRange(0, d.utf16.count))
            let matched = match?.rangeAtIndex(0)
            return matched != nil
        }
    }
    
    func get() -> (v: B) -> Bool {
        switch self {
        case first:
            return T.nthChild(0)
        case last:
            return T.nthChild(-1)
        case firstOfType:
            return T.nthOfType(0)
        case lastOfType:
            return T.nthOfType(-1)
        }
    }
}


extension UIView {
    
    func setAppearanceFunc(i: String) {
        queryList[Int(i)!](self)
    }
    
}

class TAppearance<B: UIView> {
    
    init(_ q: TQueryable<B>) {
        self.q = q
    }
    
    var q: TQueryable<B>
    
    func appearence(b: B -> Void) {
        let a = B.appearance()
        let i = queryList.count
        queryList.append({
            if self.q.matches($0) {
                b($0 as! B)
            }
        })
        a.setAppearanceFunc("\(i)")
    }

}

protocol IQueryable {
    func matches(view: AnyObject) -> Bool
}

class TQueryable<B: AnyObject>: NSObject, IQueryable {
    
    func matches(view: AnyObject) -> Bool {
        if view is B && view.isKindOfClass(self.b) {
            return true
        }
        return false
    }
    
    var b: B.Type
        
    required init(_ b: B.Type) {
        self.b = b
    }
}

class TSibling<B: UIView>: TQueryable<B> {
    var q: IQueryable? = nil
    
    init(_ query: IQueryable, _ b: B.Type) {
        super.init(b)
        self.q = query
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
                if self.q != nil && self.q!.matches(s) {
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
                if self.q != nil && self.q!.matches(s) {
                    return true
                }
            }
        }
        return false
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
            else if let parent = view.superview {
                if self.q.matches(parent!) {
                    return true
                }
            }
        }
        return false
    }
}


class TMatching<B: AnyObject>: TQueryable<B> {
    var q: IQueryable? = nil
    
    init(_ query: IQueryable, _ matches: B -> Bool) {
        self.matching = matches
        super.init(B.self)
        self.q = query
    }
    
    var matching: (B) -> Bool
    
    override func matches(view: AnyObject) -> Bool {
        if super.matches(view) {
            if self.matching(view as! B) && self.q!.matches(view) {
                return true
            }
        }
        return false
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
}

