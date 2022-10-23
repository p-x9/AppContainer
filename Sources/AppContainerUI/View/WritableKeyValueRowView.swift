//
//  WritableKeyValueRowView.swift
//  
//
//  Created by p-x9 on 2022/10/24.
//  
//

import SwiftUI
import EditValueView

@available(iOS 13, *)
struct WritableKeyValueRowView<Content>: View where Content: View {
    let key: String
    let value: Any?
    let isEditable: Bool
    var destination: Content?
    
    @State private var isPresentedSheet = false
    
    init(key: String, value: Any?, isEditable: Bool, destination: (() -> Content)? = nil) {
        self.key = key
        self.value = value
        self.isEditable = isEditable
        self.destination = destination?()
    }
    
    var body: some View {
        Button {
            isPresentedSheet.toggle()
        } label: {
            HStack(alignment: .center) {
                Text(key)
                    .foregroundColor(.primary)
                Spacer()
                Text(stringValue())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .when(destination != nil && isEditable) {
            $0.sheet(isPresented: $isPresentedSheet) {
                destination
            }
        }
    }
    
    private func stringValue() -> String {
        var stringValue = String()
        if let value = value as? CustomStringConvertible {
            stringValue = value.description
        }
        return stringValue
    }
}
