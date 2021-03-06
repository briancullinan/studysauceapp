//
//  TQuery.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

private var queryList: [(UIView) -> Void] = []

enum T<B: UIView> {
    
    static func device(_ d: String) -> (_ v: B) -> Bool {
        return {(_: B) -> Bool in
            let ex = try? NSRegularExpression(pattern: d, options: NSRegularExpression.Options.caseInsensitive)
            let current = UIDevice.current.modelName
            let match = ex?.firstMatch(in: current, options: [], range:NSMakeRange(0, current.characters.count))
            let matched = match?.rangeAt(0)
            return matched != nil
        }
    }
    
    static func size(_ hor: UIUserInterfaceSizeClass, _ ver: UIUserInterfaceSizeClass) -> (_ v: B) -> Bool {
        return {(_: B) -> Bool in
            return (UIScreen.main.traitCollection.horizontalSizeClass == hor && ver == .unspecified) ||
            (hor == .unspecified && UIScreen.main.traitCollection.verticalSizeClass == ver) ||
            (UIScreen.main.traitCollection.horizontalSizeClass == hor && UIScreen.main.traitCollection.verticalSizeClass == ver)
        }
    }
    
    static func orientation(_ d: String) -> (_ v: B) -> Bool {
        return {(_: B) -> Bool in
            if d.lowercased() == "landscape" && (UIApplication.shared.statusBarOrientation == .landscapeLeft ||
                UIApplication.shared.statusBarOrientation == .landscapeRight) {
                    return true
            }
            if d.lowercased() == "portrait" && (UIApplication.shared.statusBarOrientation == .portraitUpsideDown ||
                UIApplication.shared.statusBarOrientation == .portrait) {
                    return true
            }
            if d.lowercased() == "landscapeleft" && UIApplication.shared.statusBarOrientation == .landscapeLeft {
                    return true
            }
            if d.lowercased() == "landscaperight" && UIApplication.shared.statusBarOrientation == .landscapeRight {
                return true
            }
            if d.lowercased() == "portrait" && UIApplication.shared.statusBarOrientation == .portrait {
                return true
            }
            if d.lowercased() == "portraitupsidedown" && UIApplication.shared.statusBarOrientation == .portraitUpsideDown {
                return true
            }
            return false
        }
    }
    
    static func orientation(_ d: UIInterfaceOrientation) -> (_ v: B) -> Bool {
        return {(_: B) -> Bool in
            return UIApplication.shared.statusBarOrientation == d
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
    
    func appearence(_ b: @escaping (B) -> Void) {
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
    func matches(_ view: AnyObject) -> Bool
}

class TQueryable<B: AnyObject>: NSObject, IQueryable {
    
    func matches(_ view: AnyObject) -> Bool {
        if view.isKind(of: self.b) {
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

    required init(_ b: B.Type) {
        fatalError("init has not been implemented")
    }
    
    override func matches(_ view: AnyObject) -> Bool {
        if let v = view as? UIView {
            return self.matchesView(v)
        }
        return false
    }
    
    func enumerate(_ view: UIView) -> [B] {
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
    
    func matchesView(_ view: UIView) -> Bool {
        // first check to make sure view is of correct type
        if let parent = view.superview , super.matches(view) {
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

    required init(_ b: B.Type) {
        fatalError("init has not been implemented")
    }
    
    fileprivate func getVC(_ view: UIView) -> UIViewController? {
        var nextResponder: UIResponder? = view.next
        while nextResponder != nil {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            nextResponder = nextResponder?.next
        }
        return nil
    }
    
    func enumerate(_ view: UIView) -> [B] {
        var result: [B] = []
        let children = view.subviews
        for s in children {
            if self.q.matches(s) {
                result.append(s as! B)
            }
            result.append(contentsOf: self.enumerate(s))
        }
        return result
    }
    
    override func matches(_ view: AnyObject) -> Bool {
        if let v = view as? UIView {
            return self.matchesView(v)
        }
        return false
    }
    
    func matchesView(_ view: UIView) -> Bool {
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

    required init(_ b: B.Type) {
        fatalError("init has not been implemented")
    }
    
    override func matches(_ view: AnyObject) -> Bool {
        if let v = view as? UIView {
            return self.matchesView(v)
        }
        return false
    }
    
    func matchesView(_ view: AnyObject) -> Bool {
        // first check to make sure view is of correct type
        if super.matches(view) {
            let nr = view.next
            // self.a can be a view controller type or another view type
            if nr! != nil && (self.q.matches(nr!!)
                || nr!!.next != nil
                && nr!!.next! is UIViewController
                && self.q.matches(nr!!.next!)) {
                return true
            }
            else if let parent = view.superview , parent != nil {
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
    
    init(_ query: IQueryable, _ matches: @escaping (B) -> Bool) {
        self.matching = matches
        self.q = query
        super.init(B.self)
    }

    required init(_ b: B.Type) {
        fatalError("init has not been implemented")
    }
    
    var matching: (B) -> Bool
    
    override func matches(_ view: AnyObject) -> Bool {
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

    required init(_ b: B.Type) {
        fatalError("init has not been implemented")
    }
    
    var queries: [IQueryable]
    
    override func matches(_ view: AnyObject) -> Bool {
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
            let queries = self.queries.map({"\($0)"}).joined(separator: " or ")
            return "any of \(queries)"
        }
    }
}

