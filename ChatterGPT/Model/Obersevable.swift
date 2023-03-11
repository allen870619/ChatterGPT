//
//  Obersevable.swift
//  ChatterGPT
//
//  Created by Lee Yen Lin on 2023/3/9.
//

import Foundation

class Observable<T> {
    typealias BindAction = (T) -> Void
    var listener: BindAction?

    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(todo: @escaping (T) -> Void) {
        listener = todo
    }
}
