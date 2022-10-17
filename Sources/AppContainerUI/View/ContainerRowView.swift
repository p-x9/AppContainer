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

    init(container: Container) {
        self.container = container
    }
    
    var body: some View {
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
        let container: Container =  .init(name: "Default",
                                          uuid: UUID().uuidString,
                                          description: "This container is default.\nこんにちは")
        ContainerRowView(container: container)
            .previewLayout(.sizeThatFits)
    }
}
#endif
