//
//  UserDefaults.swift
//  Example
//
//  Created by p-x9 on 2022/09/19.
//  
//

import Foundation

extension UserDefaults {
    enum ValueType {
        case int
        case double
        case string
        case bool
        case data
        
        indirect case array(ValueType)
        indirect case dictionary(ValueType, ValueType)
        
        case unknown
        
        var typeName: String {
            switch self {
            case .int:
                return "Int"
            case .double:
                return "Double"
            case .string:
                return "String"
            case bool:
                return "Bool"
            case .data:
                return "Data"
            case let .array(content):
                return "[\(content.typeName)]"
            case let .dictionary(key, value):
                return "[\(key.typeName): \(value.typeName)]"
            case .unknown:
                return "Any"
            }
        }
    }
    
    func extractValueType(forKey key: String) -> ValueType? {
        guard let value = self.value(forKey: key) else { return nil }
        
        return self.extractType(for: value)
    }
    
    private func extractType(for value: Any) -> ValueType {
        if let _ = value as? Int {
            return .int
        }
        if let _ = value as? Double {
            return .double
        }
        if let _ = value as? String {
            return .string
        }
        if let array = value as? Array<Any> {
            var type: ValueType = .unknown
            if let data = array.first  {
                type = extractType(for: data)
            }
            return .array(type)
        }
        if let dictionary = value as? Dictionary<AnyHashable, Any> {
            var key: ValueType = .unknown
            var value: ValueType = .unknown
            if let data = dictionary.first {
                key = extractType(for: data.key)
                value = extractType(for: data.value)
            }
            
            return .dictionary(key, value)
        }
        
        return .unknown
    }
}


extension UserDefaults.ValueType {
    // FIXME: - support More Types
    func value(from stringValue: String) -> Any? {
        switch self {
        case .int:
            return Int(stringValue)
        case .double:
            return Double(stringValue)
        case .string:
            return stringValue
        default:
            return nil
        }
    }
}
