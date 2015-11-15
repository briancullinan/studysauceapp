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
    case last
    
    func get(query: TQueryable<B>) -> TMatching<B> {
        switch self {
        case first:
            return TMatching<B>(query, {(v: B) -> Bool in
                return v.superview != nil && v.superview!.subviews.indexOf(v) == 0
            })
        case last:
            return TMatching<B>(query, {(v: B) -> Bool in
                return v.superview != nil && v.superview!.subviews.indexOf(v) == v.superview!.subviews.count - 1
            })
        }
    }
}

infix operator |> {associativity left precedence 140}

func |> <A: AnyObject, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TChild<A,B>(a, b)
}

func |> <A: UIView, B: UIView>(q: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TChild<TQueryable<A>,B>(q, b)
}

// |>>

infix operator |>> {associativity left precedence 140}

func |>> <A: AnyObject, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TImmediateChild<A,B>(a, b)
}

func |>> <A: UIView, B: UIView>(q: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TImmediateChild<TQueryable<A>,B>(q, b)
}

// |+

infix operator |+ {associativity left precedence 140}

func |+ <A: UIView, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TQueryable<A>(a) |+ b
}

func |+ <A: UIView, B: UIView>(a: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TSibling<TQueryable<A>,B>(a, b)
}

// |^

infix operator |^ {associativity left precedence 140}

func |^ <B: UIView>(b: B.Type, matches: B -> Bool) -> TQueryable<B> {
    return TQueryable<B>(b) |^ matches
}

func |^ <B: UIView>(b: TQueryable<B>, matches: B -> Bool) -> TQueryable<B> {
    return TMatching<B>(b, matches)
}

// |&

infix operator |& {associativity left precedence 140}

func |& <B: UIView>(b: B.Type, type: T<B>) -> TQueryable<B> {
    return TQueryable<B>(b) |& type
}

func |& <B: UIView>(a: TQueryable<B>, type: T<B>) -> TQueryable<B> {
    return type.get(a)
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
