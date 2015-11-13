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

// |>>

infix operator |>> {associativity left precedence 140}

func |>> <A: AnyObject, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TImmediateChild<A,B>(a: a, b: b)
}

func |>> <A: UIView, B: UIView>(a: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TImmediateChild<TQueryable<A>,B>(b: b, query: a)
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

infix operator |^ {associativity left precedence 140}

func |^ <B: UIView>(b: B.Type, matches: B -> Bool) -> TQueryable<B> {
    return TMatching<B>(query: TQueryable<B>(b: b), matches: matches)
}

func |^ <B: UIView>(a: TQueryable<B>, matches: B -> Bool) -> TQueryable<B> {
    return TMatching<B>(query: a, matches: matches)
}

// |&

infix operator |& {associativity left precedence 140}

func |& <B: UIView>(b: B.Type, type: T<B>) -> TQueryable<B> {
    return type.get(TQueryable<B>(b: b))
}

func |& <B: UIView>(a: TQueryable<B>, type: T<B>) -> TQueryable<B> {
    return type.get(a)
}

enum T<B: UIView> {
    
    case first
    case last
    
    func get(query: TQueryable<B>) -> TMatching<B> {
        switch self {
        case first:
            return TMatching<B>(query: query, matches: {(v: B) -> Bool in
                return v.superview != nil && v.superview!.subviews.indexOf(v) == 0
            })
        case last:
            return TMatching<B>(query: query, matches: {(v: B) -> Bool in
                return v.superview != nil && v.superview!.subviews.indexOf(v) == v.superview!.subviews.count - 1
            })
        }
    }
}

// $

func $<B: UIView>(b: B.Type, _ set: B -> Void) {
    TQueryable<B>(b: b).appearence(set)
}

func $<B: UIView>(b: TQueryable<B>, _ set: B -> Void) {
    b.appearence(set)
}

func $(b: [UIView.Type], _ set: UIView -> Void) {
    let queries = b.map({return TQueryable<UIView>(b: $0)})
    TCombination<UIView>(queries: queries).appearence(set)
}

func $(queries: [Queryable], _ set: UIView -> Void) {
    TCombination<UIView>(queries: queries).appearence(set)
}

//

protocol IQueryable {
    func matches(view: UIView) -> Bool
}

class Queryable {
    static var queryList: [UIView -> Void] = []
    
    private init() {
        
    }
    
    private func matches(view: UIView) -> Bool {
        return true
    }
}

class TQueryable<B: UIView>: Queryable {
    
    func appearence(b: B -> Void) {
        let a = B.appearance()
        let i = Queryable.queryList.count
        Queryable.queryList.append({
            if self.matches($0) {
                b($0 as! B)
            }
        })
        //a.setFontName("Text")
        a.setAppearanceFunc("\(i)")
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

class TImmediateChild<A: AnyObject,B: UIView>: TQueryable<B> {
    
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
        if super.matches(view) {
            // self.a can be a view controller type or another view type
            if view.nextResponder() is A || view.superview?.nextResponder() is A {
                return true
            }
            else if let parent = view.superview {
                if parent is A || self.q != nil && self.q!.matches(parent) {
                    return true
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

