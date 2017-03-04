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

infix operator ~> : MultiplicationPrecedence

infix operator ~>> : MultiplicationPrecedence

infix operator ~+ : MultiplicationPrecedence

infix operator ~* : MultiplicationPrecedence

// TODO: address a view controller directly, instead of UIViewController.view
// TODO: descendents to allow addressed of views within view controllers of UIView.subviews contains > UIViewController.view

func ~> <A: AnyObject, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TQueryable<A>(a) ~> b
}

func ~> <A: AnyObject, B: UIView>(q: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TChild<B>(q, b)
}

func ~> <B: UIView>(v: UIView, b: B.Type) -> [B] {
    return v ~> TQueryable<B>(b)
}

func ~> <B: UIView>(v: UIView, b: TQueryable<B>) -> [B] {
    return TChild<B>(b, B.self).enumerate(v)
}

// |>>

func ~>> <A: AnyObject, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TQueryable<A>(a) ~>> b
}

func ~>> <A: AnyObject, B: UIView>(q: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TImmediateChild<B>(q, b)
}

// |+

func ~+ <A: UIView, B: UIView>(a: A.Type, b: B.Type) -> TQueryable<B> {
    return TQueryable<A>(a) ~+ b
}

func ~+ <A: UIView, B: UIView>(a: TQueryable<A>, b: B.Type) -> TQueryable<B> {
    return TSibling<B>(a, b)
}

func ~+ <B: UIView>(v: UIView, b: B.Type) -> [B] {
    return v ~+ TQueryable<B>(b)
}

func ~+ <B: UIView>(v: UIView, b: TQueryable<B>) -> [B] {
    return TSibling<B>(b, B.self).enumerate(v)
}

// |^

func ~* <B>(b: B.Type, matches: @escaping (B) -> Bool) -> TQueryable<B> {
    return TQueryable<B>(b) ~* matches
}

func ~* <B>(b: TQueryable<B>, matches: @escaping (B) -> Bool) -> TQueryable<B> {
    return TMatching<B>(b, matches)
}

func ~* <B: UIView>(b: B.Type, tag: Int) -> TMatching<B> {
    return TQueryable<B>(b) ~* tag
}

func ~* <B: UIView>(b: TQueryable<B>, tag: Int) -> TMatching<B> {
    return TMatching<B>(b, {$0.tag == tag})
}

func ~* <B: UIView>(b: B.Type, id: String) -> TMatching<B> {
    return TQueryable<B>(b) ~* id
}

func ~* <B: UIViewController>(b: B.Type, id: String) -> TMatching<B> {
    return TQueryable<B>(b) ~* id
}

func ~* <B: UIView>(b: TQueryable<B>, id: String) -> TMatching<B> {
    return TMatching<B>(b, {$0.restorationIdentifier == id || ($0 as? UITableViewCell)?.reuseIdentifier == id})
}

func ~* <B: UIViewController>(b: TQueryable<B>, id: String) -> TMatching<B> {
    return TMatching<B>(b, {$0.restorationIdentifier == id})
}

// $

func $<B: UIView>(_ b: B.Type, _ set: @escaping (B) -> Void) {
    $(TQueryable<B>(b), set)
}

func $<B: UIView>(_ b: TQueryable<B>, _ set: @escaping (B) -> Void) {
    TAppearance(b).appearence(set)
}

func $<B: UIView>(_ queries: [IQueryable], _ set: @escaping (B) -> Void) {
    $(TCombination<B>(queries: queries), set)
}

func $(_ b: [UIView.Type], _ set: @escaping (UIView) -> Void) {
    $(b.map({return TQueryable<UIView>($0)}), set)
}

// @

prefix operator |^

prefix func |^ (media: @escaping (UIDevice) -> Bool) -> TQueryable<UIDevice> {
    return TMatching(TQueryable(UIDevice.self), {(_: UIDevice) in
        return media(UIDevice.current)
    })
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
