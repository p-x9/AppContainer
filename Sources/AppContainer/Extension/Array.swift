//
//  Array.swift
//  
//
//  Created by p-x9 on 2022/09/24.
//  
//

import Foundation

extension Array {
    init(_ array: CFArray) {
        self = (0..<CFArrayGetCount(array)).map {
            unsafeBitCast(
                CFArrayGetValueAtIndex(array, $0),
                to: Element.self
            )
        }
    }
}
