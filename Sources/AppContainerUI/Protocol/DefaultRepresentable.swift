//
//  DefaultRepresentable.swift
//  
//
//  Created by p-x9 on 2022/10/17.
//  
//

import Foundation

protocol DefaultRepresentable {
    static var `default`: Self { get }
}

extension String: DefaultRepresentable {
    static var `default`: String {
        ""
    }
}
extension Int: DefaultRepresentable {
    static var `default`: Int {
        0
    }
}

extension Double: DefaultRepresentable {
    static var `default`: Double {
        0.0
    }
}

extension Bool: DefaultRepresentable {
    static var `default`: Bool {
        false
    }
}

extension Date: DefaultRepresentable {
    static var `default`: Date {
        .init()
    }
}
