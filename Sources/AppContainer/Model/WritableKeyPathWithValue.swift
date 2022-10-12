//
//  WritableKeyPathWithValue.swift
//  
//
//  Created by p-x9 on 2022/10/02.
//  
//

import Foundation

/// Writable KeyPath and value
public struct WritableKeyPathWithValue<Root> {
    /// KeyPath to which you want to assign a value
    public let keyPath: PartialKeyPath<Root>
    /// Value to be assigned
    public let value: AnyHashable
    /// assign value
    public let apply: (inout Root) -> Void

    /// initialize with keyPath and value
    public init<Value>(_ keyPath: WritableKeyPath<Root, Value>, _ value: Value) where Value: Hashable {
        self.keyPath = keyPath
        self.value = value
        self.apply = { $0[keyPath: keyPath] = value }
    }
}
