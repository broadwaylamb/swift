// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -emit-module -o %t %S/Inputs/asdf.swift
// RUN: %target-swift-frontend -emit-module -o %t/extends_int_1.swiftmodule -I %t %S/Inputs/extends_int_1.swift
// RUN: %target-swift-frontend -emit-module -o %t/extends_int_2.swiftmodule -I %t %S/Inputs/extends_int_2.swift
// RUN: %target-swift-frontend -typecheck %s -I %t -verify

import asdf
import extends_int_1
import extends_int_2

public func foo(_ a: A) -> (S, S) {

    let s1 = a.getS() // expected-error {{ambiguous use of 'getS()'}}

    let s2 = a.s // expected-error {{ambiguous use of 's'}}

    return (s1, s2)
}

public func bar1(_ a: A) -> (S, S) {

    let s1 = a.(extends_int_1)getS()

    let s2 = a.(extends_int_1)s

    return (s1, s2)
}

public func baz(_ a: A) {
    _ = a.(NonExistent)member // expected-error {{no such module 'NonExistent'}}
}

typealias Wrong = A.Nested // expected-error {{ambiguous type name 'Nested' in 'A'}}

typealias Right = A.(extends_int_1)Nested

typealias Wut = A.(NonExistent)Nested // expected-error {{no such module 'NonExistent'}}

public func wrongSyntax1(_ a: A) {
    _ = a.(extends_int_1())s // expected-error {{expected ')' after module name}}
}

public func wrongSyntax2(_ a: A) {
    _ = a.(13)s // expected-error {{expected module name}}
}

public func modulePath(_ a: A) {
    _ = a.(extends_int_1.submodule)s // expected-error {{no such module 'extends_int_1.submodule'}}
}
