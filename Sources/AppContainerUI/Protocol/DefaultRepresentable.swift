//
//  DefaultRepresentable.swift
//  
//
//  Created by p-x9 on 2022/10/17.
//  
//

import Foundation

public protocol DefaultRepresentable {
    static var defaultValue: Self { get }
}

extension String: DefaultRepresentable {
    public static var defaultValue: String {
        ""
    }
}
extension Int: DefaultRepresentable {
    public static var defaultValue: Int {
        0
    }
}

extension Double: DefaultRepresentable {
    public static var defaultValue: Double {
        0.0
    }
}

extension Bool: DefaultRepresentable {
    public static var defaultValue: Bool {
        false
    }
}

extension Date: DefaultRepresentable {
    public static var defaultValue: Date {
        .init()
    }
}
