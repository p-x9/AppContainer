//
//  WritableKeyPathWithValue.swift
//  
//
//  Created by p-x9 on 2022/10/02.
//  
//

import Foundation

public struct WritableKeyPathWithValue<Root> {
    public let keyPath: PartialKeyPath<Root>
    public let value: AnyHashable
    public let apply: (inout Root) -> Void

    public init<Value>(_ keyPath: WritableKeyPath<Root, Value>, _ value: Value) where Value: Hashable {
        self.keyPath = keyPath
        self.value = value
        self.apply = { $0[keyPath: keyPath] = value }
    }
}
