//
//  TQuery.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

// >

func ><A: UIView,B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TChild<A,B>()
}

func ><A,B>(a: A.Type, b: TQueryable<B>) -> TQueryable<B> {
    return TChild<A,B>()
}

func ><A,B>(a: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TChild<TQueryable<A>,B>()
}

func ><A,B>(a: TQueryable<A>, b: TQueryable<B>) -> TQueryable<B> {
    return TChild<A,B>()
}

// +

func +<A,B>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TSibling<A,B>()
}

func +<A,B>(a: A.Type, b: TQueryable<B>) -> TQueryable<B> {
    return TSibling<A,B>()
}

func +<A,B>(a: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TSibling<TQueryable<A>,B>()
}

func +<A,B>(a: TQueryable<A>, b: TQueryable<B>) -> TQueryable<B> {
    return TSibling<A,B>()
}

// $

func $<B: UIView>(b: B.Type) -> B {
    let query = TQueryable<B>()
    return query.appearence()
}

func $<B>(q: TQueryable<B>) -> B {
    return q.appearence()
}

//

protocol IQueryable {
    func matches(view: UIView) -> Bool
    init()
}

class Queryable: IQueryable {
    static var queryList: [Queryable] = []
    
    required init() {
    }
   
    func matches(view: UIView) -> Bool {
        return true
    }
}

class TQueryable<B: UIView>: Queryable {
    
    required init() {
        super.init()
    }
    
    func appearence() -> B {
        let a = B.appearance()
        let i = Queryable.queryList.count
        Queryable.queryList.append(self)
        a.setAppearance(i)
        return a
    }
    
    override func matches(view: UIView) -> Bool {
        if view.self is B {
            return true
        }
        return false
    }
}

class TQuery<A,B: UIView>: TQueryable<B> {
    
    required init () {
        self.a = A.self
        self.b = B.self
        super.init()
    }
    
    var a: A.Type
    var b: B.Type
    
    override func matches(view: UIView) -> Bool {
        if B.self == Queryable.self {
            //css(b as! TQueryable).matches(view)
        }
        
        return super.matches(view)
    }
}

class TSibling<A,B: UIView>: TQuery<A,B> {
    
    required init () {
        super.init()
    }
    
    override func matches(view: UIView) -> Bool {
        let parent = view.superview
        let isChild = parent!.subviews.filter{v in
            return v.self is A
            }.count > 0
        if isChild {
            return super.matches(view)
        }
        return false
    }
}

class TChild<A,B: UIView>: TQuery<A,B> {
    
    required init () {
        super.init()
    }
    
    override func matches(view: UIView) -> Bool {
        let parent = view.superview
        let isChild = parent! is A
        if isChild {
            return super.matches(view)
        }
        return false
    }
}

