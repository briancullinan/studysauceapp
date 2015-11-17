//
//  TQueryOperators.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/13/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

// |>

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

infix operator |> {associativity left precedence 140}

func |> <A: AnyObject, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TQueryable<A>(a) |> b
}

func |> <A: AnyObject, B: UIView>(q: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TChild<A,B>(q, b)
}

// |>>

infix operator |>> {associativity left precedence 140}

func |>> <A: AnyObject, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TQueryable<A>(a) |>> b
}

func |>> <A: AnyObject, B: UIView>(q: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TImmediateChild<A,B>(q, b)
}

// |+

infix operator |+ {associativity left precedence 140}

func |+ <A: UIView, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TQueryable<A>(a) |+ b
}

func |+ <A: UIView, B: UIView>(a: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TSibling<A,B>(a, b)
}

// |^

infix operator |^ {associativity left precedence 140}

func |^ <B>(b: B.Type, matches: B -> Bool) -> TQueryable<B> {
    return TQueryable<B>(b) |^ matches
}

func |^ <B>(b: TQueryable<B>, matches: B -> Bool) -> TQueryable<B> {
    return TMatching<B>(b, matches)
}

func |^ <B>(b: B.Type, type: T<B>) -> TQueryable<B> {
    return TQueryable<B>(b) |^ type
}

func |^ <B>(q: TQueryable<B>, type: T<B>) -> TQueryable<B> {
    return TMatching<B>(q, type.get())
}

// |#
//prefix operator |^ {}
func |^ <B: UIView>(b: B.Type, id: String) -> TMatching<B> {
    return TMatching<B>(TQueryable<B>(b), {$0.restorationIdentifier == id})
}

func |^ <B: UIViewController>(b: B.Type, id: String) -> TMatching<B> {
    return TMatching<B>(TQueryable<B>(b), {$0.restorationIdentifier == id})
}

func |^ <B: UIView>(b: TQueryable<B>, id: String) -> TMatching<B> {
    return TMatching<B>(b, {$0.restorationIdentifier == id})
}

func |^ <B: UIViewController>(b: TQueryable<B>, id: String) -> TMatching<B> {
    return TMatching<B>(b, {$0.restorationIdentifier == id})
}

// $

func $<B: UIView>(b: B.Type, _ set: B -> Void) {
    $(TQueryable<B>(b), set)
}

func $<B: UIView>(b: TQueryable<B>, _ set: B -> Void) {
    TAppearance(b).appearence(set)
}

func $<B: UIView>(queries: [IQueryable], _ set: B -> Void) {
    $(TCombination<B>(queries: queries), set)
}

func $<B: UIView>(b: [B.Type], _ set: B -> Void) {
    let queries = b.map({return TQueryable<B>($0) as IQueryable})
    $(queries, set)
}

/*
func |+ <A: UIView, B: UIView>(a: A, b: B.Type) -> [B] {
    return TSibling<A, B>(a: A.self, b: b).matching(a) as! [B]
}

func $<B: UIView>(b: [B], _ set: B -> Void) {
    for i in b {
        set(i)
    }
}
*/