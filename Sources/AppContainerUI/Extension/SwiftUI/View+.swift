//
//  View+.swift
//  
//
//  Created by p-x9 on 2022/10/18.
//  
//

import SwiftUI

@available(iOS 13, *)
extension View {
    @ViewBuilder
    func when<Content: View>(_ condition: Bool, @ViewBuilder transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
