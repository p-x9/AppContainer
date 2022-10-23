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
    public let value: Any
    public let apply: (inout Root) -> Void
    
    public init<Value>(_ keyPath: WritableKeyPath<Root, Value>, _ value: Value) {
        self.keyPath = keyPath
        self.value = value
        self.apply = { $0[keyPath: keyPath] = value }
    }
}

public struct WritableKeyPathValueApplier<Root> {
    public let keyPath: PartialKeyPath<Root>
    public let apply: (Any, inout Root) -> Void
    
    public init<Value>(_ keyPath: WritableKeyPath<Root,Value>) {
        self.keyPath = keyPath
        self.apply = {
            guard let value = $0 as? Value else { return }
            $1[keyPath: keyPath] = value
        }
    }
}


extension WritableKeyPathWithValue {
    public init(_ keyValueApplier: WritableKeyPathValueApplier<Root>, value: Any) {
        self.keyPath = keyValueApplier.keyPath
        self.value = value
        self.apply = {
            keyValueApplier.apply(value, &$0)
        }
    }
}

