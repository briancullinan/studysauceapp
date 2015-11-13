//
//  TQuery.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

// |>

infix operator |> {associativity left precedence 140}

func |> <A: AnyObject, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TChild<A,B>(a: a, b: b)
}

func |> <A: UIView, B: UIView>(a: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TChild<TQueryable<A>,B>(b: b, query: a)
}

// |+

infix operator |+ {associativity left precedence 140}

func |+ <A: AnyObject, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TSibling<A,B>(a: a, b: b)
}

func |+ <A: UIView, B: UIView>(a: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TSibling<TQueryable<A>,B>(b: b, query: a)
}

// |:

infix operator |^ {associativity none precedence 150}

func |^ <B: UIView>(b: B.Type, matches: B -> Bool) -> TQueryable<B> {
    return TMatching<B>(query: TQueryable<B>(b: b), matches: matches)
}

func |^ <B: UIView>(a: TQueryable<B>, matches: B -> Bool) -> TQueryable<B> {
    return TMatching<B>(query: a, matches: matches)
}

// $

func $<B: UIView>(var q: TQueryable<B>? = nil, _ b: B.Type? = nil, _ set: (B -> Void)? = nil) -> B? {
    if b != nil {
        q = TQueryable<B>(b: b!)
    }
    if q != nil {
        let a = q!.appearence()
        set?(a)
        return a
    }
    return nil
}

func $<B: UIView>(b: B.Type) -> B {
    return $(nil, b, nil)!
}

func $<B: UIView>(q: TQueryable<B>) -> B {
    return $(q, nil, nil)!
}

func $<B: UIView>(b: B.Type, _ set: B -> Void) -> B {
    return $(nil, b, set)!
}

func $<B: UIView>(q: TQueryable<B>, _ set: B -> Void) -> B {
    return $(q, nil, set)!
}

func $(b: [UIView.Type]) -> UIView {
    // combination queryable
    let queries = b.map({return TQueryable<UIView>(b: $0)})
    let q = TCombination<UIView>(queries: queries)
    return $(q, nil, nil)!
}

func $(b: [UIView.Type], _ set: UIView -> Void) -> UIView {
    let a = $(b)
    set(a)
    return a
}

//

protocol IQueryable {
    func matches(view: UIView) -> Bool
}

class Queryable: IQueryable {
    static var queryList: [Queryable] = []
    
    private init() {
        
    }
    
    func matches(view: UIView) -> Bool {
        return true
    }
}

class TQueryable<B: UIView>: Queryable {
    
    func appearence() -> B {
        let a = B.appearance()
        let i = Queryable.queryList.count
        Queryable.queryList.append(self)
        a.setAppearance(i)
        return a
    }
    
    override func matches(view: UIView) -> Bool {
        if view is B && view.isKindOfClass(self.b) {
            return true
        }
        return false
    }
    
    var b: B.Type
    
    init(b: B.Type) {
        self.b = b
    }
    
    var q: Queryable? = nil
}

class TSibling<A,B: UIView>: TQueryable<B> {
    
    init(a: A.Type, b: B.Type) {
        self.a = a
        super.init(b: b)
    }
    
    convenience init(b: B.Type, query: Queryable) {
        self.init(a: A.self, b: b)
        self.q = query
    }
    
    var a: A.Type
    
    override func matches(view: UIView) -> Bool {
        // first check to make sure view is of correct type
        if let parent = view.superview where super.matches(view) {
            let siblings = parent.subviews
            for s in siblings {
                if s is A || self.q != nil && self.q!.matches(s) {
                    return true
                }
            }
        }
        return false
    }
}

class TChild<A: AnyObject,B: UIView>: TQueryable<B> {
    
    init(a: A.Type, b: B.Type) {
        self.a = a
        super.init(b: b)
    }
    
    convenience init(b: B.Type, query: Queryable) {
        self.init(a: A.self, b: b)
        self.q = query
    }
    
    var a: A.Type
    
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
    
    override func matches(view: UIView) -> Bool {
        // first check to make sure view is of correct type
        if super.matches(view) {
            // self.a can be a view controller type or another view type
            if self.getVC(view) is A {
                return true
            }
            else {
                var parent = view
                while parent.superview != nil {
                    parent = parent.superview!
                    if parent is A || self.q != nil && self.q!.matches(parent) {
                        return true
                    }
                }
            }
        }
        return false
    }
}

class TMatching<B: UIView>: TQueryable<B> {
    
    init(query: Queryable, matches: B -> Bool) {
        self.matching = matches
        super.init(b: B.self)
        self.q = query
    }
    
    var matching: (B) -> Bool
    
    override func matches(view: UIView) -> Bool {
        if super.matches(view) {
            if self.matching(view as! B) && self.q!.matches(view) {
                return true
            }
        }
        return false
    }
}

class TCombination<B: UIView> :TQueryable<B> {
    
    init(queries: [Queryable]) {
        self.queries = queries
        super.init(b: B.self)
    }
    
    var queries: [Queryable]
    
    override func matches(view: UIView) -> Bool {
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

