//
//  WeakHashTable.swift
//  
//
//  Created by p-x9 on 2023/03/10.
//

import Foundation

public class WeakHashTable<T> {
    public var objects: [T] {
        accessQueue.sync { _objects.allObjects.compactMap { $0 as? T } }
    }

    private var _objects: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    private let accessQueue: DispatchQueue = DispatchQueue(label:"com.p-x9.appcintainer.WeakHashTable.\(T.self)",
                                                           attributes: .concurrent)

    public init() {}

    public init(_ objects: [T]) {
        for object in objects {
            _objects.add(object as AnyObject)
        }
    }

    public func add(_ object: T?) {
        accessQueue.sync(flags: .barrier) {
            _objects.add(object as AnyObject)
        }
    }

    public func remove(_ object: T?) {
        accessQueue.sync(flags: .barrier) {
            _objects.remove(object as AnyObject)
        }
    }
}


extension WeakHashTable : Sequence {
    public typealias Iterator = Array<T>.Iterator

    public func makeIterator() -> Iterator {
        return objects.makeIterator()
    }
}
