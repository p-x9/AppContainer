//
//  ContainerRowView.swift
//  
//
//  Created by p-x9 on 2022/10/15.
//  
//

import SwiftUI
import AppContainer

@available(iOS 13, *)
struct ContainerRowView: View {

    private var container: Container
    private var isActive: Bool

    init(container: Container, isActive: Bool = false) {
        self.container = container
        self.isActive = isActive
    }

    var body: some View {
        HStack(alignment: .center) {
            content
            if isActive {
                Color(UIColor.green)
                    .frame(width: 8, height: 8)
            }
        }
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(container.name ?? "")
                Text(container.description ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }

            HStack {
                Text(container.uuid)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }
}

#if DEBUG
@available(iOS 13, *)
struct ContainerRowView_Preview: PreviewProvider {
    static var previews: some View {
        let container: Container = .init(name: "Default",
                                         uuid: UUID().uuidString,
                                         description: "This container is default.\nこんにちは")
        Group {
            ContainerRowView(container: container)
                .previewLayout(.sizeThatFits)
            ContainerRowView(container: container, isActive: true)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
