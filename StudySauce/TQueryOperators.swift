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

infix operator |> {associativity left precedence 140}

func |> <A: AnyObject, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TQueryable<A>(a) |> b
}

func |> <A: AnyObject, B: UIView>(q: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TChild<B>(q, b)
}

// |>>

infix operator |>> {associativity left precedence 140}

func |>> <A: AnyObject, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TQueryable<A>(a) |>> b
}

func |>> <A: AnyObject, B: UIView>(q: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TImmediateChild<B>(q, b)
}

// |+

infix operator |+ {associativity left precedence 140}

func |+ <A: UIView, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TQueryable<A>(a) |+ b
}

func |+ <A: UIView, B: UIView>(a: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TSibling<B>(a, b)
}

func |+ <B: UIView>(v: UIView, b: B.Type) -> [B] {
    return v |+ TQueryable<B>(b)
}

func |+ <B: UIView>(v: UIView, b: TQueryable<B>) -> [B] {
    return TSibling<B>(b, B.self).enumerate(v)
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

func $(b: [UIView.Type], _ set: UIView -> Void) {
    $(b.map({return TQueryable<UIView>($0)}), set)
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
