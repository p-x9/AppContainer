//
//  UserDefaults.swift
//  
//
//  Created by p-x9 on 2022/09/17.
//  
//

import Foundation

extension UserDefaults {
    func sync(with plistUrl: URL) {
        self.synchronize()
        
        let udDictionary = self.dictionaryRepresentation()
        guard let plistDictionary = NSDictionary(contentsOf: plistUrl) as? [String : Any] else {
            udDictionary.keys.forEach {
                self.set(nil, forKey: $0)
            }
            return
        }
        
        udDictionary.keys.forEach {
            self.set(plistDictionary[$0], forKey: $0)
        }
        
        for (key, value) in plistDictionary {
            self.set(value, forKey: key)
        }
    }
}
