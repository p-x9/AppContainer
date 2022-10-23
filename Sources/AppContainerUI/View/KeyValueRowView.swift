//
//  KeyValueRowView.swift
//  
//
//  Created by p-x9 on 2022/10/16.
//  
//

import SwiftUI

@available(iOS 13, *)
struct KeyValueRowView: View {
    let key: String
    let value: Any?
    var action: (() -> Void)?
    
    var body: some View {
        Button {
            action?()
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

    }
    
    private func stringValue() -> String {
        var stringValue = String()
        if let value = value as? CustomStringConvertible {
            stringValue = value.description
        }
        return stringValue
    }
}

#if DEBUG
@available(iOS 13, *)
struct KeyValueRowView_Preview: PreviewProvider {
    static var previews: some View {
        KeyValueRowView(key: "Name", value: "Default")
            .previewLayout(.sizeThatFits)
    }
}
#endif
